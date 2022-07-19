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
