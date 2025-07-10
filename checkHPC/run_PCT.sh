#!/bin/bash
# module load apps/matlab
# Array of argument variable names

waveNums=(1 2 3 4)
aboveWaterMasses=(0)
cdSurge=(2 4 6 8) #(8 10 12 14 16)
cdHeave=(0.5 1 1.5 2) #(0 1 2 3)
cdPitch=(0.5 1 1.5 2) #(4 5 6 7 8)
cdYaw=(7 8 9 10)

waveVec=()
massVec=()
surgeVec=()
heaveVec=()
pitchVec=()
yawVec=()

# set it up as for each variable combo, we run all heights and periods:
for cdS in "${cdSurge[@]}"; do
    for cdH in "${cdHeave[@]}"; do
        for cdP in "${cdPitch[@]}"; do
            for cdY in "${cdYaw[@]}"; do
                for wave in "${waveNums[@]}"; do
                    waveVec+=("$wave")
                    surgeVec+=("$cdS")
                    heaveVec+=("$cdH")
                    pitchVec+=("$cdP")
                    yawVec+=("$cdY")
done
done
done
done
done

numPar=50

printf "${waveVec[*]} \n ${surgeVec[*]} \n ${heaveVec[*]} \n ${pitchVec[*]} \n ${yawVec[*]}" > mcrCases.txt

let z=$((${#waveVec[@]} / numPar))+1
for parCount in $(seq 1 $z); do 
	echo $parCount;
	rm -rf '/ascldap/users/jtgrasb/.matlab/local_cluster_jobs'
	/usr/local/matlab/R2023b/bin/matlab -nodisplay -nodesktop -nosplash -r "runComparisonPCT("$parCount","$numPar"); exit" 
done
