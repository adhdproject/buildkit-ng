#!/bin/bash

# Time to install Artillery!

git clone https://github.com/BinaryDefense/artillery.git
pushd artillery > /dev/null
./setup.py -y
popd > /dev/null
rm -rf artillery
