#! /usr/bin/env bash

# This script generates an expected output file or expected error
# file (whichever is appropriate) for a specified input file.

if [ $# -eq 0 ]; then
  echo "No"
  exit 1
fi

testname=$(basename $1 .in)

input_data_file=data/$testname.in
if [ ! -f "$input_data_file" ]; then
  echo "Missing input data $input_data_file"
  exit 1
fi

echo "Building $1..."
./build.rb $testname
if [ $? -ne 0 ]; then
  echo "failed!"
  exit 1
fi
echo "Built $1 successfully"

expected_output_file=expected_output/$testname.out

echo "Running program..."
./out/$testname < $input_data_file > $expected_output_file
if [ $? -ne 0 ]; then
  echo "failed?"
  exit 1
fi
echo "Program executed successfully"
