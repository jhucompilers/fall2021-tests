#! /usr/bin/env ruby

require 'open3'

# Run a test for assignment 1.
# The ASSIGN01_DIR environment variable must be set to the directory
# containing the "minicalc" executable.

# ----------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------

def write_output(dirname, filename, s)
  if !s.empty?
    Dir.mkdir(dirname) if !FileTest.directory?(dirname)

    output_filename = "#{dirname}/#{filename}"
    File.open(output_filename, 'w') do |out|
      # Don't save lines beginning with "Debug:"
      s.lines.each do |line|
        if !/^Debug:/i.match(line)
          out.print line
        end
      end
    end
  end
end

def check_actual_vs_expected_output(actual_output_filename, expected_output_filename, exit_code)
  if exit_code != 0
    puts "Program exited with non-zero exit code"
    exit 1
  end

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

def find_error(filename)
  return nil if !FileTest.readable?(filename)
  tuple = nil
  File.open(filename) do |f|
    f.each_line do |line|
      if tuple.nil? && (m = /^([^:]+):(\d+):(\d+): Error: .*$/.match(line))
        tuple = [m[1], m[2], m[3]]
      end
    end
  end
  return tuple
end

def check_actual_vs_expected_error(actual_error_filename, expected_error_filename, exit_code)
  # By default, error message is considered correct if it is formatted correctly
  # has the correct filename, and (unless -n option is specified) has the correct line number.
  # If the '-c' option is in effect, then the column number must also be
  # within 1 of the correct value.
  actual_error = find_error(actual_error_filename)
  expected_error = find_error(expected_error_filename)

  raise "No error message found in #{expected_error_filename}" if expected_error.nil?

  # Make sure an error message was produced
  if actual_error.nil?
    puts "Missing or invalid error message in #{actual_error_filename}"
    exit 1
  end

  # Check filename
  if actual_error[0] != expected_error[0]
    puts "Filename in error message doesn't match (expected '#{expected_error[0]}', saw '#{actual_error[0]}')"
    exit 1
  end

  # Check line number if (if -n option was NOT used)
  if $OPT != '-n' && actual_error[1] != expected_error[1]
    puts "Line number in error message doesn't match (expected '#{expected_error[1]}', saw '#{actual_error[1]}')"
    exit 1
  end

  # Check column number (-c option was used)
  if $OPT == '-c'
    col_diff = actual_error[2].to_i - expected_error[2].to_i
    if col_diff < -1 || col_diff > 1
      puts "Column number in error message doesn't match (expected '#{expected_error[2]}', saw '#{actual_error[2]}'"
    end
  end

  puts "Test passed!"
  exit 0
end

# ----------------------------------------------------------------------
# Main script
# ----------------------------------------------------------------------

raise 'ASSIGN01_DIR environment variable must be set' if !ENV.has_key?('ASSIGN01_DIR')
exe_dir = ENV['ASSIGN01_DIR']

# make sure executable exists
exe = "#{exe_dir}/minicalc"
raise "#{exe} is not executable" if !FileTest.executable?(exe)

# see if there an option argument was specified on the command line
$OPT = ''
if ARGV.length == 2 && ARGV[0].start_with?('-')
  $OPT = ARGV.shift
end

# command line argument is the test name
raise "Usage: ./run_test.rb <testname>" if ARGV.length != 1
testname = ARGV.shift

# Make sure that input file exists (otherwise, the test doesn't exist)
input_file = "input/#{testname}.in"
raise "No such test input #{input_file}" if !(FileTest.readable?(input_file))

# Make sure that either the expected output file or expected error file exists
expected_output_filename = "expected_output/#{testname}.out"
expected_error_filename = "expected_error/#{testname}.out"
if !FileTest.readable?(expected_output_filename) && !FileTest.readable?(expected_error_filename)
  raise "Neither expected output nor expected error files exist"
end

# If an option was not specified on the command line, see if
# an option file exists, and if so, read it
if $OPT == '' && FileTest.readable?("option/#{testname}.in")
  $OPT = File.read("option/#{testname}.in").rstrip
end

# Run the executable on the named test
cmd = [exe, input_file]
#puts "cmd is: #{cmd.join(' ')}"
stdout_str, stderr_str, status = Open3.capture3(*cmd, stdin_data: '')
if !status.exited?
  puts "Test command failed"
  if !stderr_str.empty?
    puts "Error output is:"
    puts stderr_str
  end
  exit 1
end

# write output to actual_output directory
write_output('actual_output', "#{testname}.out", stdout_str)

# write error outout to actual_error directory
write_output('actual_error', "#{testname}.out", stderr_str)

if FileTest.readable?(expected_output_filename)
  check_actual_vs_expected_output("actual_output/#{testname}.out", expected_output_filename, status.exitstatus)
else
  check_actual_vs_expected_error("actual_error/#{testname}.out", expected_error_filename, status.exitstatus)
end
