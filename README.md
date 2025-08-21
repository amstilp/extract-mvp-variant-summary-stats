# extract-mvp-variant-summary-stats

This repository contains code to extract summary stats for a specific set of variants from the MVP [publicly-available on dbGaP](https://ftp.ncbi.nlm.nih.gov/dbgap/studies/phs002453/analyses/GIA/).

## extract_variants.sh

This is a bash script that:

1. Downloads a specific fiel from the dbGaP ftp site to a temporary directory
1. Untars the file
1. Greps the analysis results file contained in the tar file for a specific set of variants
1. Saves the results

The script takes a list of inputs in a specific order:

1. The remote file on the ftp server (e.g., `ftp.ncbi.nlm.nih.gov/dbgap/studies/phs002453/analyses/GIA/phs002453.MVP_R4.1000G_AGR.GIA.PheCodes_Pregnancy.analysis-PI.MULTI.tar`)
2. A filename containing the variants to search for, one rsID per line (see `variants.txt` for an example)
3. The filename in which to store the results for those variants

## submit.py

A python script to submit jobs to the UW-GAC local slurm cluster.
The script obtains the list of available tar files on the dbGaP server in a specific directory, and submits a single job per file to the cluster.
The job runs the `extract_variants.sh` script for each file.
If the results file already exists for the tar file, job submission is skipped.

Log files are stored in `./logs/` and are named using an identifying substring in the filename (e.g., `./logs/extract_varaints_PheCodes_Pregnancy.<job_id>.out`).

Results files are stored in the `./variants/` directory and are named using thes ame identifying substring (e.g., `./variants/PheCodes_Pregnancy.txt`).
