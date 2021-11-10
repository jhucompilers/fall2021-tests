#! /usr/bin/env ruby

require 'open3'

opt = nil
if ARGV.length > 0 && ARGV[0].start_with?('-')
  opt = ARGV.shift
end

testname = ARGV.shift
raise "Usage: build.rb <testname>" if testname.nil?

raise "ASSIGN05_DIR environment variable must be defined" if !ENV.has_key?('ASSIGN05_DIR')
compiler_exe = "#{ENV['ASSIGN05_DIR']}/compiler"
raise "#{compiler_exe} does not exist or is not executable" if !FileTest.executable?(compiler_exe)

cmd = [compiler_exe, "input/#{testname}.in"]
if !opt.nil?
  # test InstructionSequence -> CFG -> InstructionSequence transformation
  cmd.insert(1, opt)
end

#puts "cmd=#{cmd.join(' ')}"

out, err, status = Open3.capture3(*cmd, :stdin_data => '')
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
