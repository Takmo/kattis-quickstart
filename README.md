# Kattis Quickstart

Just a handy little script to quickly setup a problem environment for Kattis.

If you want updates, I recommend just cloning the repository and pulling
from time to time. If you don't care about updates, you probably should
just download init.sh. Oh, and make sure it's executable.

Command usage looks like this...

`./init.sh [problem_name] [language]`

The language can either be `cpp`, `py2`, or `py3`.

This script will automatically download the sample inputs/outputs for
`[problem_name]` and set up a folder with a basic code file (in either
C++, Python2, or Python3) and a Makefile that automatically builds your code,
runs it with the sample inputs, and shows your output compared to the
expected outputs.
