#!/bin/sh
cc Test.cpp -o test -std=c++17 -L/opt/homebrew/lib ../build/libjbuff.a  -lstdc++