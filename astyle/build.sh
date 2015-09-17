#!/bin/sh

cd build/mac
make && make prefix=$PREFIX install

