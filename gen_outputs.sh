#!/bin/bash

source ./gen_inputs.sh

output_foldername='outputs_test7'
numsteps=$(echo "($gammaV_init-$gammaV_fin)/$increment + 1" | bc)
replicates=1
threads=32

while [[ "$#" -gt 0 ]]; do
    case $1 in
	-r|--replicates) replicates="$2"; shift ;;
	-n|--threads) threads="$2"; shift ;;
    esac
    shift
done

mkdir -p $output_foldername
cd $output_foldername

for j in $(seq 1 $replicates); do
    for i in $(seq 1 $numsteps); do
        # Calculate gammaV value
        gammaV=$(echo "$gammaV_init - ($i-1) * $increment" | bc)
        filenameIndex=$(echo "$gammaV * 100" | bc | awk '{print int($1)}')
        filenameAppend="gammaV$filenameIndex"
        
        # Create and move to the output directory
        mkdir -p output_${filenameAppend}_$j
        cd output_${filenameAppend}_$j || exit 1  # Exit if directory change fails
        
        # Set random seed
        seed=$RANDOM
        
        # Copy input file to the new directory
        cp ../../$input_foldername/input_$filenameAppend.dts .
        
        # Calculate the absolute difference to check
        difference=$(echo "$gammaV - $gammaV_init" | bc)
        abs_difference=$(echo "if ($difference < 0) -1*$difference else $difference" | bc)
        
        # Perform actions based on the difference
        if (( $(echo "$abs_difference > 0.001" | bc -l) )); then
            # Subtract 1 from filenameIndex for the previous directory
            previousIndex=$(echo "$filenameIndex + 1" | bc)
            
            # Find the last `output_X.tsi` file in the previous directory
            last_output_file=$(ls ../output_gammaV${previousIndex}_1/TrajTSI/dts*.tsi 2>/dev/null | sort -V | tail -n 1)
            
            if [[ -n "$last_output_file" ]]; then
                # Use the found last output_X.tsi file
                cp "$last_output_file" ./output_last.tsi
                ../../DTS -in input_$filenameAppend.dts -top output_last.tsi -nt $threads
            else
                echo "No previous dtsX.tsi files found in output_gammaV${previousIndex}_1/TrajTSI."
                exit 1
            fi
        else
            cp ../../$input_foldername/topol.q .
            cp ../../$input_foldername/top.top .
            ../../DTS -in input_$filenameAppend.dts -top top.top -nt $threads
        fi
        
        cd ..  # Go back to the previous directory for the next iteration
    done
done

cd ..
