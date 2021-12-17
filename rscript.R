setwd('~/projects/Unix_Task-4')

library(tidyverse)

read_tsv('data/popdata.tsv') -> d

# DP non logarithmic
ggplot(d, aes(x=DP, fill=TYPE)) +
  geom_histogram(binwidth=.5, alpha=.5, position="identity")

# DP logarithmic
ggplot(d, aes(x=log(DP), fill=TYPE)) +
  geom_histogram(binwidth=.5, alpha=.5, position="identity")
