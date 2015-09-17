#!/bin/sh

CFLAGS="-fPIC" ./configure --enable-threads --prefix $PREFIX
make && make install

CFLAGS="-fPIC" ./configure --enable-threads --enable-float --prefix $PREFIX
make && make install

