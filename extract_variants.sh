#! /usr/bin/bash
#SBATCH -o ./logs/%x.%J.out # STDOUT

set -e -o pipefail

remote_file=$1
variant_file=$2
results_file=$3
file_basename=$(basename $remote_file)
file_basename_no_extension="${file_basename%.*}"
local_file=$TMPDIR/$file_basename

mkdir -p variants/

# Download the file
echo "Downloading $remote_file..."
wget --no-verbose $remote_file -O $local_file
echo "Done!"


# Extract the file
echo "Untarring $local_file..."
(cd $TMPDIR && tar -xvf $local_file)
echo "Done!"

# Remove the tar file.
rm $local_file

# List contents
echo "Listing text files..."
ls -lh $TMPDIR/*/*.txt.gz
echo "Done!"

# Grepping for variants
echo "Variants in $variant_file:"
cat $variant_file
echo "Done!"

echo "Extracting variants from $variant_file..."
zgrep -w -H --file=$variant_file $TMPDIR/*/*.txt.gz > $TMPDIR/tmp.txt
echo "Done!"

echo "Printing the head of results..."
head $TMPDIR/tmp.txt
echo "Done!"

echo "Copying results to final final location..."
cp $TMPDIR/tmp.txt $results_file
echo "Done!"
