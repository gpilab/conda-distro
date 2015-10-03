#!/bin/bash

cp -R bin/ $PREFIX/bin
cp -R lib/ $PREFIX/lib
cp -R include/ $PREFIX/include
cp -R launch/gpi.command $PREFIX/bin/gpi

cp LICENSE $PREFIX/lib/gpi
cp COPYING $PREFIX/lib/gpi
cp COPYING.LESSER $PREFIX/lib/gpi
cp AUTHORS $PREFIX/lib/gpi
