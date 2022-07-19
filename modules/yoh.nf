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