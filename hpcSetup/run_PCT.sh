#!/bin/bash
module load apps/matlab
# Array of argument variable names

waveNums=(1 2 3 4)
aboveWaterMasses=(-20 0 20 40)
cdSurge=(2 4 6 8)
cdHeave=(2 4 6 8)
cdPitch=(2 4 6 8)

waveVec=()
massVec=()
surgeVec=()
heaveVec=()
pitchVec=()

# set it up as for each variable combo, we run all heights and periods:
for mass in "${aboveWaterMasses[@]}"; do
    for cdS in "${cdSurge[@]}"; do
        for cdH in "${cdHeave[@]}"; do
            for cdP in "${cdPitch[@]}"; do
                for wave in "${waveNums[@]}"; do
                    waveVec+=("$wave")
                    massVec+=("$mass")
                    surgeVec+=("$cdS")
                    heaveVec+=("$cdH")
                    pitchVec+=("$cdP")
done
done
done
done
done

numPar=50

printf "${waveVec[*]} \n ${massVec[*]} \n ${surgeVec[*]} \n ${heaveVec[*]} \n ${pitchVec[*]}" > mcrCases.txt

let z=$((${#waveVec[@]} / numPar))+1
for parCount in $(seq 1 $z); do 
	echo $parCount;
	rm -rf '/ascldap/users/jtgrasb/.matlab/local_cluster_jobs'
	matlab -nodisplay -nodesktop -nosplash -r "runComparisonPCT("$parCount","$numPar"); exit" 
done
