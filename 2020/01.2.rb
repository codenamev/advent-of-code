# frozen_string_literal: true

expenses = File.readlines("01-input.txt", chomp: true).map(&:to_i)

matching_expenses = expenses.permutation(3).select { |combo| combo.sum == 2020 }
p matching_expenses.map { |e| e.reduce(&:*) }.uniq
