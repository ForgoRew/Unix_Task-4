INPUT=/data-shared/vcf_examples/luscinia_vars.vcf.gz

# Show DPs
#<$INPUT zcat | grep -v "#" | cut -f8 | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" | less


# Make a new file for data for R script

## Make a temp directory for it:
TEMPDIR=$(mktemp -d)

## Prepare files
touch data/popdata.tsv $TEMPDIR/indels $TEMPDIR/indel_DP $TEMPDIR/SNPs $TEMPDIR/SNP_DP

## Header
echo "INDEL/SNP	DP" > data/popdata.tsv

## Preparing files for paste to popdata.tsv
<$INPUT zcat | grep -v "#" | cut -f8 | grep -o "INDEL" >> $TEMPDIR/indels # 99537 lines
<$INPUT zcat | grep -v "#" | cut -f8 | grep "INDEL" | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" >> $TEMPDIR/indel_DP

for i in $( seq $( <$INPUT zcat | grep -v "#" | cut -f8 | grep -v "INDEL" | wc -l ) )
do
echo "SNP" >> $TEMPDIR/SNPs # 354671 lines
done
<$INPUT zcat | grep -v "#" | cut -f8 | grep -v "INDEL" | grep -o "DP=[0-9]*;" | grep -o "[0-9]*" >> $TEMPDIR/SNP_DP

## Paste data for INDELs
paste $TEMPDIR/indels $TEMPDIR/indel_DP >> data/popdata.tsv

## Paste data for SNPs
paste $TEMPDIR/SNPs $TEMPDIR/SNP_DP >> data/popdata.tsv

## Clean temp directory:
rm -rf $TEMPDIR
