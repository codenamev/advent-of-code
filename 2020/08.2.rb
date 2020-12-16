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

    def nop?
      action == "nop"
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
    ) until already_processed? || complete?

    self
  end

  def already_processed?
    processed_instructions.include?(@cursor)
  end

  def complete?
    instructions[@cursor].nil?
  end

  def execute_instruction(instruction)
    processed_instructions << @cursor

    @accumulator += instruction.change if instruction.acc?
    @cursor += instruction.jmp? ? instruction.change : 1
  end
end

class BootLoadFixer
  def self.fix(instructions)
    boot_loader = nil
    instructions.each.with_index do |raw_instruction, index|
      instruction = GameBootLoader::Instruction.parse(raw_instruction)
      next if instruction.acc?

      instruction.action = instruction.nop? ? "jmp" : "nop"

      new_instructions = instructions.dup
      new_instructions[index] = instruction.to_s

      boot_loader = GameBootLoader.load(new_instructions)
      break if boot_loader.complete?
    end

    boot_loader
  end
end

class TestBootLoaderFixer < Minitest::Test
  def test_returns_accumulator_on_first_duplicate_instruction

    boot_loader = BootLoadFixer.fix([
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

    assert_equal 8, boot_loader.accumulator
  end
end

boot_loader = BootLoadFixer.fix File.readlines("08-input.txt", chomp: true)
if boot_loader.complete?
  p "Program terminated with: #{boot_loader.accumulator}."
else
  p "Duplicate instruction at #{boot_loader.cursor}: #{boot_loader.accumulator}"
end
