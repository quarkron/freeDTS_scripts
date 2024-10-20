#!/bin/bash

for j in {1..5}; do
	for i in {1..11}; do
	  mkdir output_$((81-i))_$j
	  cd output_$((81-i))_$j || exit 1  # Exit if directory change fails
	  cp ../../inputs/input_$((20+i)).dts .
          if [ $j -eq 1 ]; then
	    cp ../../outputs/output_$((20+i))/TrjTSI/output10.tsi .
          fi
          ../../dts_src/DTS -in input_$((20+i)).dts -top output10.tsi
	  cd ..  # Go back to the previous directory for the next iteration
	done
done

