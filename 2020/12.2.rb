# frozen_string_literal: true

require "minitest/autorun"

Position = Struct.new(:x, :y)
NORTH = 0.freeze
EAST = 90.freeze
SOUTH = 180.freeze
WEST = 270.freeze

class Ship
  # @waypoint – An imaginary marker to head the ship toward
  # @position – Distance in x,y from Origin (0,0)
  attr_reader :position

  def initialize(position = Position.new(0, 0))
    @position = Position.new(0, 0)
  end

  def move_to(position:, times: 1)
    @position.x += position.x * times
    @position.y += position.y * times
    position
  end

  def manhattan_distance
    position.x.abs + position.y.abs
  end
end

class Waypoint
  attr_reader :position

  def initialize(position = Position.new(10, 1))
    @position = position
  end

  def rotate!(degrees)
    # The calc assumes a clockwise rotation provides negative degrees.
    # To keep things sane, we'll reverse that
    radian_rotation = degrees_to_radians(degrees) * -1

    new_x = (
      position.x * Math.cos(radian_rotation) -
      position.y * Math.sin(radian_rotation)
    ).round
    new_y = (
      position.x * Math.sin(radian_rotation) +
      position.y * Math.cos(radian_rotation)
    ).round

    @position = Position.new(new_x, new_y)
  end

  def move(direction, distance)
    case direction
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

  private

  def degrees_to_radians(degrees)
    degrees * Math::PI / 180
  end
end

class Navigator
  attr_reader :waypoint, :ship

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

  def initialize(ship, waypoint)
    @ship = ship
    @waypoint = waypoint
  end

  def process_instruction!(instruction)
    instruction_abbr, distance = instruction.to_s.scan(/([NSEWLRF]{1})([0-9]+)/).flatten

    case ACTIONS[instruction_abbr]
    when LEFT
      waypoint.rotate!(distance.to_i * -1)
    when RIGHT
      waypoint.rotate!(distance.to_i)
    when FORWARD
      ship.move_to(position: waypoint.position, times: distance.to_i)
    else
      waypoint.move(ACTIONS[instruction_abbr], distance.to_i)
    end

    self
  end
end

class TestNavigator < Minitest::Test
  def setup
    @navigator = Navigator.new(Ship.new, Waypoint.new)
  end

  def test_move_forward
    @navigator.process_instruction!("F10")
    assert_equal Position.new(100, 10), @navigator.ship.position
    assert_equal Position.new(10, 1), @navigator.waypoint.position
  end

  def test_move_north
    @navigator.process_instruction!("N5")
    assert_equal Position.new(10, 6), @navigator.waypoint.position
    assert_equal Position.new(0, 0), @navigator.ship.position
  end

  def test_move_east
    @navigator.process_instruction!("E6")
    assert_equal Position.new(16, 1), @navigator.waypoint.position
    assert_equal Position.new(0, 0), @navigator.ship.position
  end

  def test_move_south
    @navigator.process_instruction!("S6")
    assert_equal Position.new(10, -5), @navigator.waypoint.position
    assert_equal Position.new(0, 0), @navigator.ship.position
  end

  def test_move_west
    @navigator.process_instruction!("W6")
    assert_equal Position.new(4, 1), @navigator.waypoint.position
    assert_equal Position.new(0, 0), @navigator.ship.position
  end

  def test_turn_right
    @navigator.process_instruction!("R90")
    assert_equal Position.new(1, -10), @navigator.waypoint.position
  end

  def test_turn_left
    @navigator.process_instruction!("L90")
    assert_equal Position.new(-1, 10), @navigator.waypoint.position
  end
end

ship = Ship.new
waypoint = Waypoint.new(Position.new(10, 1))
navigator = Navigator.new(ship, waypoint)
File.foreach("12-input.txt", chomp: true) do |instruction|
  navigator.process_instruction!(instruction)
end

p "Manhattan distance: #{ship.manhattan_distance}"
