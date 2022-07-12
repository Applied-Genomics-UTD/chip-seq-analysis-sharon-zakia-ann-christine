#!/usr/bin/env workflow

params.blacklist_bed = file("https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz")
params.H3K27ac_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_H3K27ac_peaks.broadPeak")
params.YAP1_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_YAP1_peaks.broadPeak")
process cps {
    conda 'bedtools'
    input:
    path blacklist
    path H3K27ac
    path YAP1 

    output:
    path "H3K27ac_filtered_peaks.bed", emit: H3K27ac
    path "YAP1_filtered_peaks.bed", emit: YAP1

    script:
    """
    # How many H3K27ac peaks overlap with black-listed regions?
bedtools intersect -a ${H3K27ac} -b ${blacklist} -wa | wc -l
#14

# exclude those peaks
bedtools intersect -a ${H3K27ac} -b ${blacklist} -v > H3K27ac_filtered_peaks.bed 

# do the same for YAP1
bedtools intersect -a ${YAP1} -b ${blacklist} -v > YAP1_filtered_peaks.bed
    """
}

process yoh {
    conda 'bedtools'

    input:
    path H3K27ac
    path YAP1 

    output:
    stdout
    //path "H3K27ac_filtered_peaks.bed", emit: H3K27ac
    //path "YAP1_filtered_peaks.bed", emit: YAP1

    script:
    """
    bedtools intersect -a ${YAP1} -b ${H3K27ac} -wa | wc -l
#1882

bedtools intersect -a ${YAP1} -b ${H3K27ac} -wa | sort | uniq | wc -l
#1882

bedtools intersect -a ${H3K27ac} -b ${YAP1} -wa | wc -l
#1882

bedtools intersect -a ${H3K27ac} -b ${YAP1} -wa | sort | uniq | wc -l
bedtools intersect -a ${H3K27ac} -b ${YAP1} -wa | sort | uniq -c | sort -k1,1nr | head

#1772 """
}

workflow{
    cps(
    params.blacklist_bed, params.H3K27ac_peaks, params.YAP1_peaks
    )
    yoh(
        cps.out.H3K27ac,
        cps.out.YAP1
    ) | view
}