# frozen_string_literal: true

def valid_password?(password_with_policy)
  min, max, character, password = password_with_policy.scan(/(\d+)-(\d+) ([a-z]+): (\w+)/).flatten
  password.count(character).between?(min.to_i, max.to_i)
end

valid_passwords = []
File.readlines("02-input.txt", chomp: true).each do |line|
  valid_passwords << line if valid_password?(line)
end

p valid_passwords.size
