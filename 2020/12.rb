# frozen_string_literal: true

require "minitest/autorun"

class Ship
  # @bearing – The number of degrees from North (0)
  # @position – Distance in x,y from Origin (0,0)
  attr_reader :bearing, :position

  Position = Struct.new(:x, :y)
  NORTH = 0.freeze
  EAST = 90.freeze
  SOUTH = 180.freeze
  WEST = 270.freeze
  FULL_ROTATION = 360.freeze
  FORWARD = :forward.freeze
  RIGHT = :right.freeze
  LEFT = :left.freeze

  ACTIONS = {
    "N" => NORTH,
    "E" => EAST,
    "S" => SOUTH,
    "W" => WEST,
    "L" => LEFT,
    "R" => RIGHT,
    "F" => FORWARD
  }.freeze

  def initialize(bearing = EAST)
    @bearing = bearing
    @position = Position.new(0, 0)
  end

  def move(direction, distance)
    case direction
    when FORWARD
      move bearing, distance
    when NORTH
      position.y += distance
    when EAST
      position.x += distance
    when SOUTH
      position.y -= distance
    when WEST
      position.x -= distance
    end

    position
  end

  def turn(direction, degrees)
    case direction
    when RIGHT
      @bearing = (bearing + degrees) % FULL_ROTATION
    when LEFT
      @bearing = (bearing - degrees) % FULL_ROTATION
    else
      bearing
    end
  end

  def manhattan_distance
    position.x.abs + position.y.abs
  end
end

class Navigator
  def self.move_ship!(ship, instruction)
    direction_abbr, distance = instruction.to_s.scan(/([NSEWLRF]{1})([0-9]+)/).flatten
    ship.turn(Ship::ACTIONS[direction_abbr], distance.to_i)
    ship.move(Ship::ACTIONS[direction_abbr], distance.to_i)
  end
end

class TestNavigator < Minitest::Test
  def setup
    @ship = Ship.new
  end

  def test_move_forward
    assert_equal Ship::Position.new(5, 0), Navigator.move_ship!(@ship, "F5")
  end

  def test_move_north
    assert_equal Ship::Position.new(0, 5), Navigator.move_ship!(@ship, "N5")
  end

  def test_move_east
    assert_equal Ship::Position.new(6, 0), Navigator.move_ship!(@ship, "E6")
  end

  def test_move_south
    assert_equal Ship::Position.new(0, -6), Navigator.move_ship!(@ship, "S6")
  end

  def test_move_west
    assert_equal Ship::Position.new(-6, 0), Navigator.move_ship!(@ship, "W6")
  end

  def test_turn_right
    Navigator.move_ship!(@ship, "R90")
    assert_equal Ship::SOUTH, @ship.bearing
  end

  def test_turn_left
    Navigator.move_ship!(@ship, "L90")
    assert_equal Ship::NORTH, @ship.bearing
  end
end

ship = Ship.new
File.foreach("12-input.txt", chomp: true) do |command|
  Navigator.move_ship!(ship, command)
end

p "Manhattan distance: #{ship.manhattan_distance}"
