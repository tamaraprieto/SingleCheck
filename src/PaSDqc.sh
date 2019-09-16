#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 4
#SBATCH -t 02:00:00
#SBATCH --mem 30G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

downsampling_depth=$2

module load astropy/3.2.1-python-3.6.8 plotly/3.10.0-python-3.6.8 seaborn/0.9.0-python-3.6.8
DIR="/mnt/lustre/scratch/home/uvi/be/tpf/APPS/PASDQC/PaSDqc/"
PYTHONPATH=$DIR:$PYTHONPATH

module load gcccore/6.4.0 samtools/1.9
CONFIG=$(basename $1 | sed 's/.txt//' | sed 's/Config.//')
#$DIR/scripts/PaSDqc QC \
#        -d $WORKDIR/PaSDqcTama/ \
#        -n 4 \
#        -c /mnt/netapp1/posadalab/APPS/PaSDqc-1.1.0-source/PaSDqc/db/categorical_spectra_1x.txt \
#        -q 30 \
#        -r ${CONFIG} \
#        --noclean

# Laura's code
$DIR/scripts/PaSDqc QC \
        -i ${WORKDIR}/${SAMPLE}.${downsampling_depth}X.filtered.bam \
        -n 4 \
        -c /mnt/netapp1/posadalab/APPS/PaSDqc-1.1.0-source/PaSDqc/db/categorical_spectra_1x.txt \
        -q 30 \
        -o ${WORKDIR}/PaSDqc_results \
        -r ${WORKDIR}/${SAMPLE}.${downsampling_depth} \
	-b grch37
        #--noclean \

