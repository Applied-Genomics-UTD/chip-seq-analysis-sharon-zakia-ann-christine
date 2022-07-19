#!bin/bash.sh
#notes for the chip seq section

##Creating a directory for the data including refs and bam
mkdir -p data
mkdir -p refs
mkdir -p bam

#Search for the information that is to be ran
esearch -db sra -query PRJNA306490  | efetch -format runinfo > runinfo.csv

#Check the csv file for what is in it
cat runinfo.csv | cut -d , -f 1,2,3 | head

#If you want to follow this, use on every run, but not doing this: without the pound
#fastq-dump -O data --split-files -F SRR3033154 

##Or you could automate that into a single line, by cutting the first column for SRR ids then piping the result into fastq-dump

# Isolate just the run ids for the run.
cat runinfo.csv | cut -f 1 -d , | grep SRR > runids.txt

# Download the fastq files.
cat runids.txt | parallel --eta --verbose  "fastq-dump -O data --split-files -F {}"

#Run Entrez Direct tool called esummary to connect the SRA numbers (raw sequencing data) which will connect run ids to sample names
esearch -db sra -query PRJNA306490  | esummary > summary.xml

#To read the XML file created above called summary, it is hard to view in a tabular way. A tool called xtract tabularizes it in a bioinformatices friendly manner. For example, the following command generates a new row on each element called named DocumentSummary then extracts the acc attribute of the Run element and prints that with the title. 
#Investigate the XML file to see where this information is present.
cat summary.xml | xtract -pattern DocumentSummary -element Run@acc Title

#Get the reference genome for the analysis for chipseq
# Reference genome.
REF=refs/saccer3.fa

#Download the chromosomes and build a genome. The sequences are stored by chromosome:
#Type in the following sequentially
URL=http://hgdownload.cse.ucsc.edu/goldenPath/sacCer3/bigZips/chromFa.tar.gz
curl $URL | tar zxv

# Get the chromosome sizes. Will be used later.
curl http://hgdownload.cse.ucsc.edu/goldenPath/sacCer3/bigZips/sacCer3.chrom.sizes > refs/sacCer3.chrom.sizes

# Move the files
mv *.fa refs

# Create genome.
cat refs/chr*.fa > $REF

#Index the reference
bwa index $REF
samtools faidx $REF

#We assume that by this time your fastq-dump programs above have finished. The alignment commands will all be of the form:
bwa mem $REF data/SRR3033154_1.fastq | samtools sort > SRR3033154.bam

#The above is only for one file; to automate for all the files, do the following
cat runids.txt | parallel --eta --verbose "bwa mem -t 4 $REF data/{}_1.fastq | samtools sort -@ 8 > bam/{}.bam"

#Because chip seq focuses on the borders of the data and not necessarily the middle, for analysis, it is good to keep the unessential information from the algorithm/tool
#To edit this information, you can do the following.
# Trim each bam file.
cat runids.txt | parallel --eta --verbose "bam trimBam bam/{}.bam bam/temp-{}.bam -R 70 --clip"

# We also need to re-sort the alignments.
cat runids.txt | parallel --eta --verbose "samtools sort -@ 8 bam/temp-{}.bam > bam/trimmed-{}.bam"

# Get rid of temporary BAM files.
rm -f bam/temp*

# Reindex trimmed bam files.
cat runids.txt | parallel --eta --verbose "samtools index bam/trimmed-{}.bam"

#Make bedgraph files here to visualize the data
# Create an genome file that bedtools will require.
samtools faidx $REF

# Create a bedgraph file out of the BAM file.
bedtools genomecov -ibam bam/SRR3033154.bam  -g $REF.fai -bg > bam/SRR3033154.bedgraph 

#Automate creating the bedgraphs
# Create the coverage files for all BAM files.
ls bam/*.bam | parallel --eta --verbose "bedtools genomecov -ibam {} -g $REF.fai -bg | sort -k1,1 -k2,2n > {.}.bedgraph"

# Generate all bigwig coverages from bedgraphs.
ls bam/*.bedgraph | parallel --eta --verbose "bedGraphToBigWig {} $REF.fai {.}.bw"

##Another way to create bigwig files
# Create a new environment.
conda create --name bioinfo

# Activate the environment.
source activate bioinfo

# Install the deeptools.
conda install deeptools

# Counts within a window of 50bp.
bamCoverage -b bam/SRR3033154.bam -o bam/SRR3033154-digitized.bw

# Smooth the signal in a window.
bamCoverage -b bam/SRR3033154.bam --smoothLength 300 -o bam/SRR3033154-smooth.bw

##Peak Calling
#Summarizing the data. Not a required step but useful to identify the characteristics of the data
samtools merge -r bam/glucose.bam bam/SRR3033154.bam bam/SRR3033155.bam
samtools merge -r bam/ethanol.bam bam/SRR3033156.bam bam/SRR3033157.bam
samtools index bam/glucose.bam 
samtools index bam/ethanol.bam 

#Generate the coverages for each, here you may skip making bigwig files since these files are not as large and IGV will handle them as is:
#These are the codes for the analysis and the result will be in bedgraphs. not big wig files
bedtools genomecov -ibam bam/glucose.bam  -g $REF.fai -bg > bam/glucose.bedgraph
bedtools genomecov -ibam bam/ethanol.bam  -g $REF.fai -bg > bam/ethanol.bedgraph

#tools used for predicting peaks
# Create a namespace for the tool
conda create --name macs python=2.7

# Activate the new environment.
source activate macs

# Install the tools.
conda install numpy
conda install macs2

#Instead of the above three, do this
conda create -n macs bioconda::macs2=2.2.7.12

#Then prepare the data below
# Glucose samples.
GLU1=bam/trimmed-SRR3033154.bam
GLU2=bam/trimmed-SRR3033155.bam

# Ethanol samples.
ETH1=bam/trimmed-SRR3033156.bam
ETH2=bam/trimmed-SRR3033157.bam