# Genom verileri
genomes = ["GCF_ra", "GCF_sa"]
# Türler
species = {
    "GCF_ra": "Deinococcus radiodurans",
    "GCF_sa": "Salmonella enterica"
}

env = "env.yaml"

rule all:
    input:
        # barrnap çıktıları
        expand("output/barrnap/{genome}_rrna_count.gff", genome=genomes),

        # RepeatModeler ve RepeatMasker için veritabanı oluşturma
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nhr", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nin", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nnd", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nni", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nog", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db.nsq", genome=genomes),

        # RepeatModeler çıktıları
        expand("output/repeatmodeler/{genome}_rm/{genome}_db-families.fa", genome=genomes),
        expand("output/repeatmodeler/{genome}_rm/{genome}_db-families.stk", genome=genomes),

        # RepeatMasker çıktıları
        expand("output/repeatmasker/{genome}_masked/{genome}_genome.fasta.masked", genome=genomes),
        expand("output/repeatmasker/{genome}_masked/{genome}_genome.fasta.out", genome=genomes),
        expand("output/repeatmasker/{genome}_masked/{genome}_genome.fasta.tbl", genome=genomes),

        # prokka ile genomların anotasyonu
        expand("output/prokka_annotation/{genome}_prokka/{genome}.gff", genome=genomes),
        expand("output/prokka_annotation/{genome}_prokka/{genome}.gbk", genome=genomes),

rule barrnap:
    input:
        genome="resource/Genome/{genome}_genomic.fasta"
    output:
        barrnap_gff="output/barrnap/{genome}_rrna_count.gff"
    log: "logs/barrnap/{genome}_rna.log"
    conda: env
    shell:
        """(barrnap --kingdom bac --quiet {input.genome} > {output.barrnap_gff}) >{log} 2>&1"""

rule repeatmodeler:
    input:
        fasta="resource/Genome/{genome}_genomic.fasta"
    output:
        # .fa ve .stk RepeatModeler'ın çıktılarıdır.
        fa="output/repeatmodeler/{genome}_rm/{genome}_db-families.fa",
        stk="output/repeatmodeler/{genome}_rm/{genome}_db-families.stk"
    conda: env
    shell:
        # RepeatModeler ile aynı olan dizine git.
        # RepeatModeler'ı çalıştır.
        """
        cd output/repeatmodeler/{wildcards.genome}_rm
        RepeatModeler -database {wildcards.genome}_db -engine ncbi -pa 8
        """

rule repeatmasker:
    input:
        fasta=lambda wildcards: f"resource/Genome/{wildcards.genome}_genomic.fasta"
    output:
        # Aşağıdaki üç dosya türü RepeatMasker'ın çıktılarıdır.
        masked="output/repeatmasker/{genome}_masked/{genome}_genome.fasta.masked",
        out="output/repeatmasker/{genome}_masked/{genome}_genome.fasta.out",
        tbl="output/repeatmasker/{genome}_masked/{genome}_genome.fasta.tbl"
    conda: env
    shell: "RepeatMasker -dir output/repeatmasker/{wildcards.genome}_masked -lib output/repeatmodeler/{wildcards.genome}_rm/{wildcards.genome}_db-families.fa -pa 8 {input.fasta}"
# Snakefile

rule plot_genome_differences:
    output:
        "output/genome_differences.png"
    script:
        "plot.py"
