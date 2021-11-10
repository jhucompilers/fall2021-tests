#! /usr/bin/env ruby

opt = ''
if ARGV.length > 0 && ARGV[0].start_with?('-')
  opt = ARGV.shift
end

testcases = []

IO.popen("ls input/*.in") do |f|
  f.each_line do |line|
    line.chomp!
    if m = /^input\/(.*)\.in$/.match(line)
      testcases.push(m[1])
    end
  end
end

num_passed = 0

testcases.each do |testname|
  #puts testname
  print "#{testname}..."
  STDOUT.flush
  cmd = "./run_test.rb #{opt} #{testname} > /dev/null 2> /dev/null"
  #puts "Running command: #{cmd}"
  rc = system(cmd)
  if rc
    puts "passed!"
    num_passed += 1
  else
    puts "FAILED"
  end
end

if num_passed == testcases.length
  puts "All tests passed!"
  exit 0
else
  puts "#{num_passed}/#{testcases.length} tests passed"
  exit 1
end
