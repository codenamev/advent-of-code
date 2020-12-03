# frozen_string_literal: true

def valid_password?(password_with_policy)
  first_position, second_position, character, password = password_with_policy.scan(/(\d+)-(\d+) ([a-z]+): (\w+)/).flatten
  (
    password[first_position.to_i.pred] + password[second_position.to_i.pred]
  ).count(character) == 1
end

valid_passwords = []
File.readlines("02-input.txt", chomp: true).each do |line|
  valid_passwords << line if valid_password?(line)
end

p valid_passwords.size
