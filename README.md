# Unix_Task-4
Repository for processing and submitting of task 4 -- the final task of course on Unix and work with genomic data MB170C47

### Description of the task
> Distribution of read depth (DP) qualities INDELS vs. SNPs

### workflow.sh
In next paragraphs I describe, what's going on with the code so you can make it step by step or you can choose to have prepared the file for analyzis instantly.
If you chose the second option, just copy-paste the code for this paragraph. It makes a data/popdata.tsv file for you, which is processible by rscript.R in project directory.
```sh
chmod +x workflow.sh
./workflow.sh
```

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

### Popdata file for rscript
In order to visualize the data in R, we are going to prepare a simple .tsv file with all data needed for the visualisation
We will make a `data` directory for it.
```sh
mkdir -p data
```

##### Make a temp directory for it:
Because we need a few files to paste into the final one, we are going to make our own temporary directory:
```sh
TEMPDIR=$(mktemp -d)
```

##### Prepare files
We prepare the files by `touch` command:
```sh
touch data/popdata.tsv $TEMPDIR/indels $TEMPDIR/indel_DP $TEMPDIR/SNPs $TEMPDIR/SNP_DP
```

##### Header
Now we put a header to our `popdata.tsv` file, the rest we will append to it.
```sh
echo "TYPE DP" > data/popdata.tsv
```
It is clear, that in first column it is stored, if the variant is INDEL or SNP and the depth of read is in the second column.

##### Preparing files for paste to popdata.tsv
Now we prepare temporary files of data to be put into the `popdata.tsv` file.
We process the INDELs first - `indels` contains n lines with "INDEL" string, where n is number of INDEL variants. The `indel_DP` contains DPs of the variants.
```sh
<$INPUT zcat | grep -v "#" | cut -f8 | grep -o "INDEL" >> $TEMPDIR/indels # 99537 lines
<$INPUT zcat | grep -v "#" | cut -f8 | grep "INDEL" | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" >> $TEMPDIR/indel_DP
```
The SNPs are processed similarly, only we choose inverse selection in `grep` and we must make the `SNPs` file more difficultly, because there is no "SNP" string in SNP rows. Similarly as for INDELs, the `SNP_DP` file contains DPs for SNP variants.
```sh 
for i in $( seq $( <$INPUT zcat | grep -v "#" | cut -f8 | grep -v "INDEL" | wc -l ) )
do
echo "SNP" >> $TEMPDIR/SNPs # 354671 lines
done
<$INPUT zcat | grep -v "#" | cut -f8 | grep -v "INDEL" | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" >> $TEMPDIR/SNP_DP
```

##### Paste data to popdata.tsv
Finally, now we append pasted data we made in prewious steps to the `popdata.tsv` file which will be now prepared for R.
```sh
paste $TEMPDIR/indels $TEMPDIR/indel_DP >> data/popdata.tsv
paste $TEMPDIR/SNPs $TEMPDIR/SNP_DP >> data/popdata.tsv
```

##### Clean the $TEMPDIR
We must clean also the `$TEMPDIR` after ourselves:
```sh 
rm -rf $TEMPDIR
```
