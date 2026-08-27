import os
import ftplib
import argparse
import subprocess
import re

regex = r"GIA\.(.+?)\.analysis-PI.MULTI.tar"

def submit_job(file, variant_file, results_subdirectory, job_name="extract_variants"):
    # This function would contain the logic to submit the job.
    # For now, we will just print the file name.
    subprocess.run(
        [
            'sbatch',
#            "--dependency=singleton",
            f"--job-name={job_name}",
            # "--ntasks=1",
            # "--ntasks-per-node=1",
            # "--spread-job",
            # "-p topmed-16c128g",
            "--exclude=gac-p127",
            "--exclusive",
            'extract_variants.sh',
            file,
            variant_file,
            results_subdirectory,
        ],
        check=True
    )
    pass

if __name__ == "__main__":

    # Parse command line arguments.
    parser = argparse.ArgumentParser(description='Submit jobs to extract variants from data files.')
    parser.add_argument('--ftp_server', type=str, default='ftp.ncbi.nlm.nih.gov',
                        help='FTP server to connect to.')
    parser.add_argument('--ftp_path', type=str, default='dbgap/studies/phs002453/analyses/GIA/',
                        help='Path on the FTP server to look for data files.')
    parser.add_argument("--variant-file", type=str, default='variants.txt',
                        help='File containing the list of variants to extract.')
    file_parser = parser.add_mutually_exclusive_group(required=False)
    file_parser.add_argument("--n-files", type=int, default=None,
                        help='Number of files to process from the FTP server.')
    file_parser.add_argument("--remote-file", type=str, default=None,
                        help='Specific file to process from the FTP server.')
    parser.add_argument("--dry-run", action="store_true", default=False,
                        help='If set, will not submit jobs, only print what would be done.')
    args = parser.parse_args()

    #Get the list of files from the FTP server.
    ftp = ftplib.FTP(args.ftp_server)
    ftp.login()
    ftp.cwd(args.ftp_path)
    files = ftp.nlst()
    ftp.close()

    # Select data files.
    data_files = [f for f in files if f.endswith('.tar')]

    if args.remote_file:
        data_files = [f for f in data_files if f == args.remote_file]
    elif args.n_files:
        if len(data_files) < args.n_files:
            print(f"Warning: Requested {args.n_files} files, but only {len(data_files)} available. Processing all available files.")
            i = len(data_files)
        else:
            i = args.n_files
        data_files = data_files[:i]

    n_files = len(data_files)
    print(f"Processing {n_files} file...")

    print("Starting job submission...")

    # Check if output for each file exist.
    for file in data_files:
        matches = re.search(regex, file)
        infix = matches[1]
        results_directory = os.path.join("results", infix)
        job_name = f"extract_variants_{infix}"
        if os.path.exists(results_directory):
            print(f"{file}: already run!")
        else:
            # Submit the job to extract the variants.
            if args.dry_run:
                print(f"Dry run: would submit job {job_name} for {file}.")
            else:
                print(f"Submitting job {job_name} for {file}...")
                submit_job(os.path.join(args.ftp_server, args.ftp_path, file), args.variant_file, results_directory, job_name=job_name)
        # else:
        #     print(f"Skipping {file}, limit reached.")
