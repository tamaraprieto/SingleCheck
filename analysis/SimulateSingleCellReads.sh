#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 20:00:00
#SBATCH --mem 20G

AMPLICON_LENGTH=$1
INTERAMPLICON_LENGTH=$2

AMPLICON_DEPTH=20
INTERAMPLICON_DEPTH=0
AMPLICON_PLUS_INTER_LENGTH=$((AMPLICON_LENGTH+INTERAMPLICON_LENGTH))
#AMPLICON_PLUS_INTER_MINUS_WINDOW_LENGTH=$((AMPLICON_PLUS_INTER_LENGTH-WINDOW_SIZE))

WORKDIR=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/RESULTS/SIMULATED/
SCRIPTDIR=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts/
FASTADIR=/mnt/netapp1/posadalab/phylocancer/RESOURCES/
NAME=Amp${AMPLICON_LENGTH}.Inter${INTERAMPLICON_LENGTH}

if [ ! -f "${WORKDIR}/chr1.fa" ];then
        head -n 4154179 ${FASTADIR}/hs37d5.fa > ${WORKDIR}/chr1.fa
fi

REFERENCE_LENGTH=$(awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' ${WORKDIR}/chr1.fa | \
	tail -n 1) 

head -n 1 ${WORKDIR}/chr1.fa > ${WORKDIR}/${NAME}.coverage.fa
STATE="A"
COUNTER=0
START=0
while [ $START -le $REFERENCE_LENGTH ]
do
A=$START
B=$((START+1))
if [[ "$STATE" -eq "A" ]];then
        DEPTH=$AMPLICON_DEPTH
else
        DEPTH=$INTERAMPLICON_DEPTH
fi
printf "#${DEPTH}" >> ${WORKDIR}/${NAME}.coverage.fa
if [ $COUNTER -eq $AMPLICON_LENGTH ];then
STATE="B"
elif [ $COUNTER -eq $AMPLICON_PLUS_INTER_LENGTH ];then
STATE="A"
COUNTER=-1
fi
COUNTER=$((COUNTER+1))
START=$B
done

module load gsl/2.5

# HSXt I think is the most similar to the NovaSeq6000 platform in which these 
  DEPTH=20
  /mnt/netapp2/posadalab2/simgle-cell_simulation/src/art_src_MountRainier_Linux/art_illumina\
  -ss HSXt \
  -i ${WORKDIR}/chr1.fa \
  --paired \
  --cvgProf ${WORKDIR}/${NAME}.coverage.fa \
  --len 150 \
  --fcov ${DEPTH} \
  --mflen 320 \
  -s 50 \
  --cigarM \
  --noALN \
  -o ${WORKDIR}/SimulatedReads.${NAME}_

gzip ${WORKDIR}/SimulatedReads.${NAME}_1.fq
gzip ${WORKDIR}/SimulatedReads.${NAME}_2.fq
rm ${WORKDIR}/${NAME}.coverage.fa
