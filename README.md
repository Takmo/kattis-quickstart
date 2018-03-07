# Kattis Quickstart

Just a handy little script to quickly setup a problem environment for Kattis.

You probably don't need to clone this repository, just see download init.sh.

`./init.sh [problem_name: required] [number of sample files: optional]`

If you don't specify a number of samples files, the script will automatically
download sample files from the Kattis website.

If sample files are specified, you will be asked to paste the following
information for each sample file.:

1. The Sample Input

2. The Sample Output

In either case, this script will automatically setup a folder named after
the problem with a starter C++ file and a Makefile configured to test against
all of the associated problem samples.
