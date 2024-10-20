#!/bin/bash

for j in {2..5}; do
	for i in {1..11}; do
	  mkdir -p output_$((81-i))_$j
	  cd output_$((81-i))_$j || exit 1  # Exit if directory change fails
	  seed=$RANDOM
	  cp ../../inputs/input_$((20+i)).dts input_seed$seed.dts
          sed -i "s/^Seed.*/Seed                            = $seed/" input_seed$seed.dts
	  cp ../../outputs/output_$((20+i))/TrjTSI/output10.tsi .
          ../../dts_src/DTS -in input_seed$seed.dts -top output10.tsi
	  cd ..  # Go back to the previous directory for the next iteration
	done
done

