#!/usr/bin/env workflow

params.blacklist_bed = file("https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz")
params.H3K27ac_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_H3K27ac_peaks.broadPeak")
params.YAP1_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_YAP1_peaks.broadPeak")

include { cps } from './modules/cps.nf' 
include { yoh } from './modules/yoh.nf'


workflow{
    cps(
    params.blacklist_bed, params.H3K27ac_peaks, params.YAP1_peaks
    )
    yoh(
        cps.out.H3K27ac,
        cps.out.YAP1
    ) | view
}