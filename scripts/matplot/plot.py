# plot.py

import matplotlib.pyplot as plt

def plot_genome_differences(genomes, differences):
    plt.bar(genomes, differences, color='skyblue')
    plt.title('Genom Farklılıkları')
    plt.xlabel('Genomlar')
    plt.ylabel('Farklılık Miktarı')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

# GCF_ra ve GCF_sa
genomes = ["GCF_ra", "GCF_sa"]
differences = [7560, 6454]  #  unreal data

# Çubuk grafiği
plot_genome_differences(genomes, differences)