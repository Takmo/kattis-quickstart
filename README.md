# Kattis Quickstart

Just a handy little script to quickly setup a problem environment for Kattis.

If you want updates, I recommend just cloning the repository and pulling
from time to time. If you don't care about updates, you probably should
just download init.sh. Oh, and make sure it's executable.

Command usage looks like this...

`./init.sh [problem_name: required] [language: required] [number of sample files: optional]`

The language can either be `cpp`, `py2`, or `py3`.

If you don't specify a number of samples files, the script will automatically
download sample files from the Kattis website.

If sample files are specified, you will be asked to paste the following
information for each sample file.:

1. The Sample Input

2. The Sample Output

In either case, this script will automatically setup a folder named after
the problem with a starter code file and a Makefile configured to test against
all of the associated problem samples.
