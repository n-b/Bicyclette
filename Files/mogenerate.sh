#!/bin/sh

PATH=$PATH:/usr/local/bin\
 mogenerator\
 --model "${SRCROOT}/Files/BicycletteCity.xcdatamodel"\
 --template-var arc=true\
 --machine-dir "${SRCROOT}/Files/BicycletteCity.mogenerated/_machine"\
 --human-dir "${SRCROOT}/Files/BicycletteCity.mogenerated/"\
 --includem "${SRCROOT}/Files/BicycletteCity.mogenerated.m"\
 --includeh "${SRCROOT}/Files/BicycletteCity.mogenerated.h"
