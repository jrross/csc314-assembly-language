#!/bin/bash

# You will need to change BASETIME if you are not using an original
# Raspberry Pi.  BASETIME is the time taken for the program after the
# adc function was written in assembly, but before any other changes.
BASETIME=10.730

# The Raspberry Pi II is faster:
# BASETIME=10.730

TIME=`(time for i in 1 2 3 4 5 6 7 8 9 10 ; do ./bigfact > /dev/null; done) 2>&1| grep user | cut -f 2 | cut -d m -f 2 | cut -d s -f 1`

echo Time was $TIME seconds
SPEEDUP=`echo "6 k $BASETIME $TIME / 0.005 + 2 k 1 / p" | dc`
echo "Speedup is $SPEEDUP"
