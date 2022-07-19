process amp {
    conda './envs/annotate_peaks.yml'
    publishDir 'results/annotate_peaks' 

    input:
    path H3K27ac
    path YAP1

    output:
    path "YAP1_peaks_anno.txt"
    path "Rplots.pdf"

    shell:
    '''
    #!/usr/bin/env Rscript
    library(ChIPseeker)
    library(TxDb.Hsapiens.UCSC.hg19.knownGene)
    library(rtracklayer)
    library("org.Hs.eg.db")
    
    # read in the peaks for YAP1
    txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
    #read in the peaks for YAP1
    YAP1 <- readPeakFile("!{YAP1}",as="GRanges")
    YAP1
    
    YAP1_anno<- annotatePeak(YAP1, tssRegion=c(-3000, 3000), TxDb=txdb, level = "gene", annoDb="org.Hs.eg.db", sameStrand = FALSE, ignoreOverlap = FALSE, overlap = "TSS")
    #some nice visualization you can do
    plotAnnoPie(YAP1_anno)
    upsetplot(YAP1_anno, vennpie=FALSE)
    
    # check the annotation
    head(as.data.frame(YAP1_anno))
    write.table(as.data.frame(YAP1_anno), "YAP1_peaks_anno.txt", row.names =F, col.names=T, sep ="\t", quote = F)
    '''
}