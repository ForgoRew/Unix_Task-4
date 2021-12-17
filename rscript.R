setwd('~/projects/Unix_Task-4')

library(tidyverse)

read_tsv('popdata.tsv') -> d

ggplot(d, aes(INDEL/SNP)) + geom_bar()
