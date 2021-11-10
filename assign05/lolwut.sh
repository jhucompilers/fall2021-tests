#! /bin/bash

# This script generates example outputs to link from the
# assignment description.  Note that the "d" option emits
# high-level code, and the "a" option enables the register
# allocator.

if [ $# -ne 1 ]; then
  echo "No"
  exit 1
fi

testname=$1

if [ ! -r "input/$testname.in" ]; then
  echo "input/$testname.in doesn't exist?"
  exit 1
fi

./compiler -d input/$testname.in > ~/git/compilers-fall2021/assign/assign05/ex/$testname-unopt.txt
./compiler input/$testname.in > ~/git/compilers-fall2021/assign/assign05/ex/$testname-unopt.S

./compiler -oad input/$testname.in > ~/git/compilers-fall2021/assign/assign05/ex/$testname-opt.txt
./compiler -oa input/$testname.in > ~/git/compilers-fall2021/assign/assign05/ex/$testname-opt.S

echo "Done?"
