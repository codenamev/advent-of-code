require "ostruct"
require "minitest/autorun"
require "set"

class Passport < OpenStruct
  REQUIRED_ATTRIBUTES = %i[byr iyr eyr hgt hcl ecl pid].freeze
  VALID_EYE_COLORS = %w[amb blu brn gry grn hzl oth].freeze

  def self.validations
    @validations ||= Set.new
  end

  def self.validate(attribute, opts)
    validations << proc { |obj|
      valid = true
      valid = !"#{obj.public_send(attribute)}".empty? if opts[:presence]
      valid &&= opts[:within].include?(obj.public_send(attribute).to_i) if opts[:within] && (opts[:if] || proc { true }).call(obj)
      valid &&= opts[:one_of].include?(obj.public_send(attribute)) if opts[:one_of]
      valid &&= obj.public_send(attribute) =~ opts[:format] if opts[:format]
      valid
    }
  end

  validate :byr, presence: true, within: 1920..2002
  validate :iyr, presence: true, within: 2010..2020
  validate :eyr, presence: true, within: 2020..2030
  validate :hgt, presence: true, format: /\A[0-9]{2,3}(in|cm)\Z/i
  validate :hgt, within: 150..193, if: ->(passport) { passport.hgt.to_s.include?("cm") }
  validate :hgt, within: 59..76, if: ->(passport) { passport.hgt.to_s.include?("in") }
  validate :hcl, presence: true, format: /\A#[0-9a-f]{6}\Z/i
  validate :ecl, presence: true, one_of: VALID_EYE_COLORS
  validate :pid, presence: true, format: /\A[0-9]{9}\Z/i

  def self.scan(raw_data)
    new Hash[raw_data.scan(/(\w+):([\w#]+)*/)]
  end

  def attributes
    to_h
  end

  def valid?
    self.class.validations.all? { |v| v.call(self) }
  end
end

input_file = File.new("04-input.txt")
passport_data = ""
valid_passports = 0
input_file.each_line(chomp: true) do |line|
  if line.empty? || input_file.eof?
    passport_data << " #{line}" unless line.empty?
    valid_passports += 1 if Passport.scan(passport_data).valid?
    passport_data = ""
  else
    passport_data << " #{line}"
  end
end

p "#{valid_passports} valid passports."

class TestPassport < Minitest::Test
  def test_all_required_attributes_present
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal true, Passport.scan(input).valid?
  end

  def test_optional_attribute
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 hgt:183cm"
    assert_equal true, Passport.scan(input).valid?
  end

  def test_missing_one_required_attribute
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_missing_more_than_one_required_attribute
    input = "elc:gry eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_min_birth_year
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1919 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_max_birth_year
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:2003 iyr:2017 cid:147 hgt:183cm"
    ps = Passport.scan(input)
    assert_equal false, Passport.scan(input).valid?
  end

  def test_min_issue_year
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:2001 iyr:2009 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_max_issue_year
    input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:2001 iyr:2021 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_min_expiration_year
    input = "ecl:gry pid:860033327 eyr:2019 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_max_expiration_year
    input = "ecl:gry pid:860033327 eyr:2031 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_height_unit_presence
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:183"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_min_cm_height
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:149cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_max_cm_height
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:194cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_min_in_height
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:58in"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_max_in_height
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffd byr:2001 iyr:2020 cid:147 hgt:77in"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_hair_color
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffffz byr:2001 iyr:2020 cid:147 hgt:76in"
    assert_equal false, Passport.scan(input).valid?
    input = "ecl:gry pid:860033327 eyr:2030 hcl:#fffff byr:2001 iyr:2020 cid:147 hgt:76in"
    assert_equal false, Passport.scan(input).valid?
    input = "ecl:gry pid:860033327 eyr:2030 hcl:fffffa byr:2001 iyr:2020 cid:147 hgt:76in"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_eye_color
    Passport::VALID_EYE_COLORS.each do |color|
      input = "ecl:#{color} pid:860033327 eyr:2030 hcl:#fffffa byr:2001 iyr:2020 cid:147 hgt:76in"
      assert_equal true, Passport.scan(input).valid?
    end

    input = "ecl:gray pid:860033327 eyr:2030 hcl:#fffffa byr:2001 iyr:2020 cid:147 hgt:76in"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_passport_id
    input = "ecl:gry pid:000000000 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal true, Passport.scan(input).valid?
    input = "ecl:gry pid:0000000010 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
    input = "ecl:gry pid:00000001 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
    input = "ecl:gry pid:a00000001 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end
end
