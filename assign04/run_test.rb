#! /usr/bin/env ruby

require 'open3'

# Run a test for assignment 3.
# The ASSIGN04_DIR environment variable must be set to the directory
# containing the "compiler" executable.

# ----------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------

def check_actual_vs_expected_output(actual_output_filename, expected_output_filename)
  # Diff actual output against expected output
  cmd = ['diff', actual_output_filename, expected_output_filename]
  stdout_str, stderr_str, status = Open3.capture3(*cmd, stdin_data: '')
  if status.success?
    puts "Test passed!"
    exit 0
  else
    puts "Test failed"
    puts "Diff output:"
    puts stdout_str
    exit 1
  end
end

# ----------------------------------------------------------------------
# Main script
# ----------------------------------------------------------------------

# command line argument is the test name
raise "Usage: ./run_test.rb <testname>" if ARGV.length != 1
testname = ARGV.shift

# Make sure that input file exists (otherwise, the test doesn't exist)
input_file = "input/#{testname}.in"
raise "No such test input #{input_file}" if !(FileTest.readable?(input_file))

# Make sure that expected output file exists
expected_output_filename = "expected_output/#{testname}.out"
if !FileTest.readable?(expected_output_filename)
  STDERR.puts "Expected output file '#{expected_output_filename}' does not exist"
  exit 1
end

# Make sure that input data file exists
input_data_filename = "data/#{testname}.in"
if !FileTest.readable?(input_data_filename)
  STDERR.puts "Input data file '#{input_data_filename}' does not exist"
  exit 1
end

# Build the target program
rc = system("./build.rb #{testname} > /dev/null 2> /dev/null")
if !rc
  STDERR.puts "Compiler command failed"
  exit 1
end

# Make sure actual_output directory exists
rc = system("mkdir -p actual_output")
if !rc
  STDERR.puts "Couldn't create actual_output directory"
  exit 1
end
actual_output_filename = "actual_output/#{testname}.out"

# Run the target program
target_exe = "out/#{testname}"
pid = Process.spawn(target_exe, :in => input_data_filename, :out => actual_output_filename)
Process.wait(pid)
status = $?

if !status.exited?
  if status.signaled?
    puts "Compiled program was killed by a signal (possible segfault)"
  else
    puts "Compiled program did not exit normally"
  end
  exit 1
end

if status.exitstatus != 0
  puts "Compiled program exited with a non-zero exit code"
  exit 1
end

check_actual_vs_expected_output(expected_output_filename, actual_output_filename)
