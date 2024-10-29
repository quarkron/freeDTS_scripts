#!/bin/bash

# Identify and go to the output folder to extract the VTU frames.
test_number=4
cd outputs_test$test_number

#Copy only the ith frame per gammaV
frequency=20

# Set the replicate number
replicate=1

# Create a folder containing all the VTU frames in the outputs_test$test_number folder.
mkdir -p vtu_allFrames_$replicate
cd vtu_allFrames_$replicate

# Detect the maximum gammaV value by listing and sorting the folder names in reverse order
max_gammaV=$(ls -d ../output_gammaV*_$replicate | sed -n "s/.*output_gammaV\([0-9]*\)_$replicate.*/\1/p" | sort -nr | head -n 1)
min_gammaV=$(ls -d ../output_gammaV*_$replicate | sed -n "s/.*output_gammaV\([0-9]*\)_$replicate.*/\1/p" | sort -n | head -n 1)

#Convert to integers
max_gammaV=$((max_gammaV))
min_gammaV=$((min_gammaV))


# Loop through all the output_gammaV$gammaV_$replicate folders from max_gammaV down to 1
for ((gammaV=max_gammaV; gammaV>=min_gammaV; gammaV--)); do
    # Define the directory name for the current gammaV
    dir="../output_gammaV${gammaV}_$replicate/VTU_F"
    #echo $dir
    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Find the highest conf*.vtu file in the current directory
        highest_conf=$(ls "$dir"/conf*.vtu 2>/dev/null | sed -n "s/.*conf\([0-9]*\)\.vtu/\1/p" | sort -n | tail -n 1)
       #echo $highest_conf

	# Copy every nth (.vtu) file, defined by frequency, excluding conf-1.vtu
        for ((j=0; j<=highest_conf; j+=frequency)); do
            file="$dir/conf$j.vtu"
            if [ -f "$file" ] && [[ "$file" != *conf-1.vtu ]]; then
                # Zero-pad the counter for naming
                new_idx=$(printf "%04d" $counter)
                cp "$file" "conf$new_idx.vtu"
                counter=$((counter + 1))  # Increment the counter after each file copy
            fi
	done
    fi
done

cd ..

