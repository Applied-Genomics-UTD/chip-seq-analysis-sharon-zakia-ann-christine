process motif_analysis {
    conda 'bedtools'

    input:
    path YAP1_summits
    path fasta 

    output:
    path "YAP1_500bp.fa"

    script:
    """
    # get the coordinates of 500bp centered on the summit of the YAP1 peaks
    cat ${YAP1_summits} | awk '\$2=\$2-249, \$3=\$3+250' OFS="\t" > YAP1_500bp_summits.bed

    # cat *fa.gz > UCSC_hg19_genome.fa.gz
    # gunzip UCSC_hg19_genome.fa.gz

    # Use betools get fasta http://bedtools.readthedocs.org/en/latest/content/tools/getfasta.html 
    bedtools getfasta -fi UCSC_hg19_genome.fa -bed ${YAP1_summits} -fo YAP1_500bp.fa
"""
}