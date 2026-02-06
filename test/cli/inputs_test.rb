# frozen_string_literal: true

require "test_helper"
require "cli/inputs"

class InputsTest < Minitest::Test
  def setup
    @stdin = $stdin
    @stdout = $stdout
  end

  def teardown
    $stdin = @stdin
    $stdout = @stdout
  end

  def object_with_inputs
    Object.new.extend(CLI::Inputs)
  end

  def test_get_input_returns_stripped_line
    $stdin = StringIO.new("  hello \n")
    $stdout = StringIO.new
    result = object_with_inputs.get_input("Name:")
    assert_equal "hello", result
  end

  def test_get_input_skips_empty_lines_until_non_empty
    $stdin = StringIO.new("\n\n  foo  \n")
    $stdout = StringIO.new
    result = object_with_inputs.get_input("Name:")
    assert_equal "foo", result
  end

  def test_get_input_prompts_to_stdout
    $stdin = StringIO.new("x\n")
    $stdout = StringIO.new
    object_with_inputs.get_input("Enter name:")
    assert_includes $stdout.string, "Enter name:"
  end

  def test_select_option_returns_selected_option_by_index
    $stdin = StringIO.new("2\n")
    $stdout = StringIO.new
    options = %w[Apple Banana Cherry]
    result = object_with_inputs.select_option("Pick one:", options)
    assert_equal "Banana", result
  end

  def test_select_option_prompts_and_lists_options
    $stdin = StringIO.new("1\n")
    $stdout = StringIO.new
    options = %w[First Second]
    object_with_inputs.select_option("Choose:", options)
    out = $stdout.string
    assert_includes out, "Choose:"
    assert_includes out, "1."
    assert_includes out, "2."
    assert_includes out, "First"
    assert_includes out, "Second"
    assert_includes out, "Enter your choice:"
  end

  def test_yes_no_input_returns_true_for_yes
    $stdin = StringIO.new("y\n")
    $stdout = StringIO.new
    assert object_with_inputs.yes_no_input("Continue?")
  end

  def test_yes_no_input_returns_true_for_yes_mixed_case
    $stdin = StringIO.new("YES\n")
    $stdout = StringIO.new
    assert object_with_inputs.yes_no_input("Continue?")
  end

  def test_yes_no_input_returns_false_for_no
    $stdin = StringIO.new("n\n")
    $stdout = StringIO.new
    refute object_with_inputs.yes_no_input("Continue?")
  end

  def test_yes_no_input_passes_prompt_with_y_n_suffix
    $stdin = StringIO.new("y\n")
    $stdout = StringIO.new
    object_with_inputs.yes_no_input("Save?")
    assert_includes $stdout.string, "Save? (y/n)"
  end
end
