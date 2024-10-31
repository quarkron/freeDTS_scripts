#!/bin/bash

input_foldername='inputs1'
init_steps=100000
consequent_steps=100000
gammaV_init=1.0
gammaV_fin=0.70
increment=0.01
template='input_template_weria2.dts' #set template file, use protein inclusion parameters set by Zane
activate_inc=1.0 #set the gammaV in which to turn on inclusions
inc_density=0.02

while [[ "$#" -gt 0 ]]; do
    case $1 in
	-f|--foldername) input_foldername="$2"; shift ;;
	-i|--init_steps) init_steps="$2"; shift ;;
	-s|--increment) increment="$2"; shift ;;
	-t|--template) template="$2"; shift ;;
	-a|--activate_inc) activate_inc="$2"; shift;;
	-d|--inc_density) inc_density="$2"; shift;;
	*) echo "Unknown parameter, exiting program: $1"; exit 1
;;
    esac
    shift
done

pass_to_output='vars.sh'
{
        echo "input_foldername=$input_foldername"
        echo "init_steps=$init_steps"
        echo "consequent_steps=$consequent_steps"
        echo "gammaV_init=$gammaV_init"
        echo "gammaV_fin=$gammaV_fin"
        echo "increment=$increment"
        echo "template=$template" #set template file, use protein inclusion parameters set by Zane
        echo "activate_inc=$activate_inc" #set the gammaV in which to turn on inclusions
        echo "inc_density=$inc_density"
        echo "kappa=$kappa"
} > "$pass_to_output"


mkdir -p $input_foldername
cd $input_foldername

log_file="input_log.txt"
{
	echo "Initial Steps for Equilibriation: $init_steps"
	echo "Consequent Steps after Equilibriation: $consequent_steps"
	echo "Initial GammaV: $gammaV_init"
	echo "Final GammaV: $gammaV_fin"
	echo "Decrement: 0.01"
	echo "Input file template: $template"
	echo "gammaV to activate inclusion: $activate_inc"
	echo "Inclusion density: $inc_density"
} > "$log_file"

if [[ -f ../$template ]]; then
  cp ../$template .
else
  echo "input template file not found"
fi

if [[ -f ../topol.q ]]; then
  cp ../topol.q .
else
  echo "topol.q file not found"
fi

if [[ -f ../top.top ]]; then
  cp ../top.top .
else
  echo "top.top file not found"
fi


num_steps=$(echo "($gammaV_init-$gammaV_fin)/$increment + 1" | bc)

for i in $(seq 1 $num_steps); do
 gammaV=$(echo "$gammaV_init - ($i-1) * $increment" | bc)
 filename_append=$(echo "$gammaV * 100" | bc | awk '{print int($1)}')
 filename="input_gammaV$filename_append.dts"
 cp $template $filename
 sed -i "s/^VolumeCoupling.*/VolumeCoupling = SecondOrder 0 10000 $gammaV/" $filename
 
 #turn on membrane protein inclusions only near cell division
 difference=$(echo "$gammaV - $activate_inc" | bc)
 abs_difference=$(echo "if ($difference < 0) -1*$difference else $difference" | bc) 
 if (( $(echo "$abs_difference > 0.001" | bc -l) )); then
    sed -i "s/^Density.*/Density  0/" $filename #turn on membrane protein inclusions exactly at activate_inc, with density inc_density
 else
    sed -i "s/^Density.*/Density  $inc_density/" $filename  
 fi


 #Higher number of steps from spherical topology to gammaV_init for equilibration
 if [ $i -eq 1 ]; then
    sed -i "s/^Set_Steps.*/Set_Steps = 1 $init_steps/" $filename
 else
    sed -i "s/^Set_Steps.*/Set_Steps = 1 $consequent_steps/" $filename
 fi
done

rm $template

cd ..
