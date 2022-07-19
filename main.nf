#!/usr/bin/env workflow

params.blacklist_bed = file("https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz")
params.H3K27ac_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_H3K27ac_peaks.broadPeak")
params.YAP1_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_YAP1_peaks.broadPeak")
params.YAP1_summits = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_YAP1_summits.bed")
// http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/
params.hg19_chrom = file("/scratch/applied-genomics/references/UCSC_hg19_genome.fa")

include { cps } from './modules/cps.nf' 
include { yoh } from './modules/yoh.nf'
include { amp } from './modules/amp.nf'
include { motif_analysis } from './modules/motif_analysis.nf'
workflow{
    cps(
    params.blacklist_bed, 
    params.H3K27ac_peaks, 
    params.YAP1_peaks
    )
    yoh(
        cps.out.H3K27ac,
        cps.out.YAP1
    )
    amp ( 
    params.H3K27ac_peaks,
    params.YAP1_peaks
    )
    motif_analysis (
    params.YAP1_summits,
    params.hg19_chrom
    )
}