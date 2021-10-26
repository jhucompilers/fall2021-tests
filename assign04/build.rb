#! /usr/bin/env ruby

require 'open3'

testname = ARGV.shift
raise "Usage: build.rb <testname>" if testname.nil?

raise "ASSIGN04_DIR environment variable must be defined" if !ENV.has_key?('ASSIGN04_DIR')
compiler_exe = "#{ENV['ASSIGN04_DIR']}/compiler"
raise "#{compiler_exe} does not exist or is not executable" if !FileTest.executable?(compiler_exe)

out, err, status = Open3.capture3(compiler_exe, "input/#{testname}.in", :stdin_data => '')
#puts "out is #{out}"
if !status.success?
  STDERR.puts "compiler command failed"
  exit 1
end

asm_src = "out/#{testname}.S"
gen_exe = "out/#{testname}"

system("mkdir -p out")
File.open("out/#{testname}.S", 'w') do |outf|
  outf.print out
end

rc = system("gcc -g -no-pie -o #{gen_exe} #{asm_src}")
if !rc
  STDERR.puts "Generated code could not be assembled"
  exit 1
end

# Success!
puts "Generated code successfully assembled, output exe is #{gen_exe}"
exit 0
