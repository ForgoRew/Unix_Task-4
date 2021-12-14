# Unix_Task-4
Repository for processing and submitting of task 4 -- the final task of course on Unix and work with genomic data MB170C47

### Description of the task
> Distribution of read depth (DP) qualities INDELS vs. SNPs

### Note:
In this case the data are stored in .gz file, so I use `zcat` for getting the plain text instead of `cat` as is usual.

### Recognizing INDELs and SNPs
The SNPs have only one nucleotide in both REF and ALT columns, while INDELs have always more than one nucleotide, so we can distinguish between them this way. We can also recognize INDELs, because they have the "INDEL" string in INFO column. I decided to use this method.

We can get the INDELs by this command:
```sh
<$INPUT zcat | grep -v "#" | grep "INDEL" | less
```

Similarly, we can get SNPs by this command:
```sh
<$INPUT zcat | grep -v "#" | grep -v "INDEL" | less
```

### Getting the Depth of Read
The Depth of Read is placed in INFO column (the 8th one). It is signed by "DP=" sequence.
We can get the depths by this command:
```sh
<$INPUT zcat | grep -v "#" | cut -f8 | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" | less
```
🔥🔥🔥

### Getting the data
In this task, the data is placed in `/data-shared/vcf_examples/luscinia_vars.vcf.gz`, so I make a variable for that.
```sh
INPUT=/data-shared/vcf_examples/luscinia_vars.vcf.gz
```

