# frozen_string_literal: true

TREE = "#"
slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2]
]

def tree_at?(line:, position:)
  # Extend the map as needed for the current position
  line *= (position.to_f / (line.length - 1)).ceil unless position.zero?
  line[position] == TREE
end

total_trees = 1
slopes.each do |right, down|
  # adjust for first line read
  down_remaining = down - 1
  trees = 0
  position = 0

  File.foreach("03-input.txt", chomp: true) do |line|
    down_remaining -= 1 and next if down_remaining > 1

    trees += 1 if tree_at?(line: line, position: position)
    position += right
    down_remaining = down
  end

  p "Slope #{right},#{down} – #{trees} trees."
  total_trees *= trees
end

p total_trees
