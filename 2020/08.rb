# frozen_string_literal: true

require "minitest/autorun"

class GameBootLoader
  attr_reader :accumulator, :cursor, :instructions, :processed_instructions

  Instruction = Struct.new(:action, :change_str) do
    def self.parse(raw_instruction)
      new *raw_instruction.split(" ")
    end

    def to_s
      "#{action} #{change_str}"
    end

    def change
      change_str.to_i
    end

    def jmp?
      action == "jmp"
    end

    def acc?
      action == "acc"
    end
  end

  def initialize(instructions)
    @cursor = 0
    @accumulator = 0
    @instructions = instructions
    @processed_instructions = []
  end

  def self.load(instructions)
    new(instructions).load
  end

  def load
    execute_instruction(
      Instruction.parse(instructions[@cursor])
    ) until repeated_instruction?

    self
  end

  def execute_instruction(instruction)
    processed_instructions << @cursor

    @accumulator += instruction.change if instruction.acc?
    @cursor += instruction.jmp? ? instruction.change : 1
  end

  def repeated_instruction?
    processed_instructions.include?(@cursor)
  end
end

class TestGameBootLoader < Minitest::Test
  def test_returns_accumulator_on_first_duplicate_instruction

    boot_loader = GameBootLoader.load([
      "nop +0",
      "acc +1",
      "jmp +4",
      "acc +3",
      "jmp -3",
      "acc -99",
      "acc +1",
      "jmp -4",
      "acc +6"
    ])

    assert_equal 5, boot_loader.accumulator
  end
end

boot_loader = GameBootLoader.load File.readlines("08-input.txt", chomp: true)

p "Duplicate instruction at #{boot_loader.cursor}: #{boot_loader.accumulator}"
