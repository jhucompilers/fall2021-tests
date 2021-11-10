#! /usr/bin/env ruby

$N = ARGV.length > 0 ? ARGV[0].to_i : 10

$N.times do
  $N.times do
    print "#{rand(100)} "
  end
  puts ''
end
