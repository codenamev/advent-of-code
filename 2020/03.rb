# frozen_string_literal: true

TREE = "#"
trees = 0
position = 0

def tree_at?(line:, position:)
  # Extend the map as needed for the current position
  line *= (position.to_f / (line.length - 1)).ceil unless position.zero?
  line[position] == TREE
end

File.readlines("03-input.txt", chomp: true).each do |line|
  trees += 1 if tree_at?(line: line, position: position)
  position += 3
end

 p trees
