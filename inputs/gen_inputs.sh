#!/bin/bash

gammaV=0.98
seed=44
template="input_2.dts"
#output_dir="inputs"

#mkdir -p "$output_dir"

for i in {3..31}; do
 filename="input_$i.dts"
 #filename="$output_dir/input_$i.dts"
 cp $template $filename
 sed -i "s/^Volume_Constraint.*/Volume_Constraint               = SecondOrderCoupling 1 0.0 10000 $gammaV/" $filename
 sed -i "s/^Seed.*/Seed                            = $seed/" $filename

 gammaV=$(echo "$gammaV-0.01" | bc)
 seed=$((seed + 1))
done
