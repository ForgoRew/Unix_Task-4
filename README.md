# Unix_Task-4
Repository for processing and submitting of task 4 -- the final task of course on Unix and work with genomic data MB170C47

### Description of the task
> Distribution of read depth (DP) qualities INDELS vs. SNPs

### Note:
In this case, the data are stored in a .gz file, so I use `zcat` for getting the plain text instead of `cat` as is usual.

### Recognizing INDELs and SNPs
The SNPs have only one nucleotide in both REF and ALT columns, while INDELs have always more than one nucleotide, so we can distinguish between them this way. We can also recognize INDELs because they have the "INDEL" string in the INFO column. I decided to use this method.

We can get the INDELs by this command:
```sh
<$INPUT zcat | grep -v "#" | grep "INDEL" | less
```

Similarly, we can get SNPs by this command:
```sh
<$INPUT zcat | grep -v "#" | grep -v "INDEL" | less
```

### Getting the Depth of Read
The Depth of Read is placed in the INFO column (the 8th one). It is signed by "DP=" sequence.
We can get the depths by this command:
```sh
<$INPUT zcat | grep -v "#" | cut -f8 | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" | less
```

### Getting the data
In this task, the data is placed in `/data-shared/vcf_examples/luscinia_vars.vcf.gz`, so I make a variable for that.
```sh
INPUT=/data-shared/vcf_examples/luscinia_vars.vcf.gz
```

### workflow.sh
In the next paragraphs, I describe, what's going on with the code so you can make it step by step or you can choose to have prepared the file for analysis instantly.
If you chose the second option, just copy-paste the code for this paragraph. It makes a data/popdata.tsv file for you, which is processible by rscript.R in the project directory.
```sh
chmod +x workflow.sh
./workflow.sh
```

### Popdata file for rscript
To visualize the data in R, we are going to prepare a simple .tsv file with all data needed for the visualization
We will make a `data` directory for it.
```sh
mkdir -p data
```

##### Make a temp directory for it:
Because we need a few files to paste into the final one, we are going to make our temporary directory:
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
It is clear, that in the first column it is stored if the variant is INDEL or SNP and the depth of read is in the second column.

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

### Rstudio visualisation
To get human-readable and useful information, we will use Rstudio to make a plot from our data.
Everything from here is in `rscript.R` in the project repository.

At first, we must set our working directory, assuming that you cloned the repository to `~/projects/` folder. If not, change this path so it leads to the project repository then.
```r
setwd('~/projects/Unix_Task-4')
```
We are going to use the `tidyverse` library so we have to import it.
```r
library(tidyverse)
```
And the data produced in prewious steps we store into `d`.
```r
read_tsv('data/popdata.tsv') -> d
```

##### Making the plot
I put there two options to be used. Both are useful but they have different pros and cons. The first is a non-logarithmic histogram, but the data are quite high density on the left, so it is not so clear. However, it is clear exactly how the DP is high.
```r
# DP non logarithmic
ggplot(d, aes(x=DP, fill=TYPE)) + geom_histogram(binwidth=.5, alpha=.5, position="identity")
```
The second one is logarithmic, so it shows nicer distribution, but you must note, that the DP is in logarithm.
```r
# DP logarithmic
ggplot(d, aes(x=log(DP), fill=TYPE)) +
  geom_histogram(binwidth=.5, alpha=.5, position="identity")
```

Both these graphs show you how many records of each INDEL/SNP are in the example.

### Credits
Thank you, Vaclav Janousek and Libor Morkovsky for this course so I could (quite easily) make this task.
Thank you very much!
