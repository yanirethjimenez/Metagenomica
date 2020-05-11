#! /bin/bash
# Yanireth Jimenez




#### Asignación de taxonomía usando AMPtk con datos de ITS2 (hongos) generados por Illumina MiSeq Conéctados al clúster de CONABIO

## Los datos usados para este análisis son 24 muestras (12 muestras con forward R1 y reverse R2) de suelo rizosférico recolectados en sitios de bosque nativo (N) y mixto (M) de Quercus (Q) y de Juniperus (J) está ubicado en metagenomica/fastq

## crear el directorio de trabajo 

 mkdir yjimenez 
 cd yjimenez

### Pre-processing FASTQ files
## En ese paso se ensamblan los reads forward y reverse, además de eliminar los primers y secuencias cortas. Usando un min_len de 200

amptk illumina -i ../metagenomica/fastq -o amptk/ -f GTGARTCATCRARTYTTTG -r CCTSCSCTTANTDATATGC -l 300 --min_len 200 --full_length --cleanup


## Clustering at 97% similarity with UPARSE
 ## En ese paso se hace un filtro de cualidad (incluso de las secuencias chimericas) y se agrupan las secuencias en OTUs

amptk cluster -i amptk.demux.fq.gz -o cluster -m 2 --uchime_ref ITS


## Filtering the OTU table (index bleed)
## Index bleed = reads asignados a la muestra incorrecta durante el proceso de secuenciación de Illumina. Es frecuente (!!) y además con un grado variable entre varios runs. En ese paso, se puede usar un control positivo (mock) artificial para medir el grado de index bleed dentro de un run. Si el run no incluyó un mock artificial, este umbral se puede definir manualmente (en general se usa 0,005%).

amptk filter -i cluster.otu_table.txt -o filter -f cluster.cluster.otus.fa -p 0.005 --min_reads_otu 2

#### Assign taxonomy to each OTU
### AMPtk utiliza la base de datos de secuencias de [UNITE] (https://unite.ut.ee/) para asignar la taxonomía de los OTUs. Dado que es una base de datos curada, en general da resultados mucho mejores que GenBank (por ejemplo usando QIMME).

amptk taxonomy -i filter.final.txt -o taxonomy -f filter.filtered.otus.fa -m ../metagenomica/amptk.mapping_file.txt -d ITS2 --tax_filter Fungi
