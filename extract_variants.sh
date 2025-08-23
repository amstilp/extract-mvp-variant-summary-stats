#! /bin/bash
#SBATCH -o ./logs/%x.%J.out # STDOUT

set -e

remote_file=$1
variant_file=$2
results_directory=$3
file_basename=$(basename $remote_file)
file_basename_no_extension="${file_basename%.analysis-PI.MULTI.tar}"
local_file=$TMPDIR/$file_basename

mkdir -p results/

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

# List variants of interest
echo "Variants in $variant_file:"
cat $variant_file
echo "Done!"

# Grep for variants in a loop over the files.
mkdir $TMPDIR/results
for file in $TMPDIR/*/*.txt.gz; do
    echo "Extracting variants from $file..."
    results_file=$TMPDIR/results/$(basename $file).txt
    # This line causes a pipefail so we can't set -o pipefail
    # https://stackoverflow.com/questions/41516177/bash-zcat-head-causes-pipefail
    zcat $file | head -n 1 > $results_file
    zgrep -w --file=$variant_file $file >> $results_file
done
echo "Done!"

echo "Listing results..."
ls -lh $TMPDIR/results/*.txt
echo "Done!"

echo "Copying results to final final location: ${results_directory}..."
mkdir -p $results_directory
cp $TMPDIR/results/* $results_directory
echo "Done!"
