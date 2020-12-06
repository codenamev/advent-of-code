require "ostruct"
require "minitest/autorun"

class Passport < OpenStruct
  REQUIRED_ATTRIBUTES = %i[byr iyr eyr hgt hcl ecl pid]

  def self.scan(raw_data)
    new Hash[raw_data.scan(/(\w+):([\w#]+)*/)]
  end

  def attributes
    to_h
  end

  def valid?
    REQUIRED_ATTRIBUTES.all? { |a| !public_send(a).nil? }
  end
end

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
    input = "elc:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end

  def test_missing_more_than_one_required_attribute
    input = "elc:gry eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
    assert_equal false, Passport.scan(input).valid?
  end
end


input_file = File.new("04-input.txt")
passport_data = ""
valid_passports = 0
input_file.each_line(chomp: true) do |line|
  if line.empty? || input_file.eof?
    passport_data << " #{line}" unless line.empty?
    p "Testing: #{passport_data}", Passport.scan(passport_data).attributes.keys, Passport.scan(passport_data).valid?
    valid_passports += 1 if Passport.scan(passport_data).valid?
    passport_data = ""
  else
    passport_data << " #{line}"
  end
end

p "#{valid_passports} valid passports."
