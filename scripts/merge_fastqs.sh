# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

for sample in $1
do
cat $3.5dpp.1.1s_sRNA.fastq.gz $3.5dpp.1.2s_sRNA.fastq.gz > $2/$3.fastq.gz
done
