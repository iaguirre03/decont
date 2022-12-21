#save working directory in a variable for convinience
echo 'export WD=$(pwd)'
#install needed programs
echo 'mamba install -y fastqc'
echo 'mamba install -y seqtk'
echo 'mamba install -y cutadapt'
echo 'mamba install -y multiqc'
echo 'mamba install -y star'
#Download all the files specified in data/filenames
echo 'for url in {https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz}'  #TODO
echo 'do'
    echo 'bash scripts/download.sh $url data'
echo 'done'

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
echo 'bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res' 

echo 'gunzip -k res/contaminants.fasta.gz'

echo 'conda install -c bioconda seqtik'

echo 'contaminants.fasta.gz=seqtik grep -f small nucleolar RNA contaminants.fasta.gz $WD/res' 

# Index the contaminants file
echo 'bash scripts/index.sh res/contaminants.fasta res/contaminants_idx'

# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq) #TODO
do
bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
#     -o <trimmed_file> <input_file> > <log_file>

# TODO: run STAR for all trimmed files
echo 'for fname in out/trimmed/*.fastq.gz'
echo 'do'
    # you will need to obtain the sample ID from the filename
    echo 'sid=#TODO'
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <output_directory>
echo 'done' 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
