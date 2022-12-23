
#install needed programs
mamba install -y fastqc
mamba install -y seqtk
mamba install -y cutadapt
mamba install -y multiqc
mamba install -y star
conda install -c bioconda seqtik

#Download all the files specified in data/filenames
for url in {https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz,https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz}  #TODO
do
bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res

gunzip -k res/contaminants.fasta.gz

seqtik grep -v -n -r -p 'small nuclear' res/contaminants.fasta.gz -o res/filtrado.fasta

# Index the contaminants file
bash scripts/index.sh res/filtrado.fasta res/contaminants_idx

# Merge the samples into a single file

mkdir -p out/merged
for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq)
do
bash scripts/merge_fastqs.sh data out/merged $sid
done


#TODO: run cutadapt for all merged files
mkdir -p log/cutadapt
mkdir -p out/trimmed
for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq)
do
cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
	-o out/trimmed/$sid.trimmed.fastq.gz out/merged/$sid.fastq.gz > log/cutadapt/$sid.log
done

#TODO: run STAR for all trimmed files
for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq)
do
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    --outReadsUnmapped Fastx --readFilesIn out/trimmed/$sid.trimmed.fastq.gz \
    --readFilesCommand gunzip -c  --outFileNamePrefix out/star/$sid/
done

#TODO: create a log file containing information from cutadapt and star logs
#(this should be a single log file, and information should be *appended* to it on each run)
#- cutadapt: Reads with adapters and total basepairs
#- star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
#tip: use grep to filter the lines you're interested in

for sid in $(ls data/*.fastq.gz | cut -d "." -f1 | sed 's:data/::' | sort | uniq)
do
grep -e 'Total reads' -e 'Total basepairs' log/cutadapt/$sid.log > log/$sid.cutadapt.log
grep -e 'Uniquely mapped reads %' -e 'Number of reads mapped' out/star/$sid/Log.final.out > log/$sid.star.log
done
cat log/$sid.cutadapt.log log/$sid.star.log > log/$sid.pipeline.log
cat log/$sid.pipeline.log log/$sid.pipeline.log > log/pipeline.log
