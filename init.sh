#!/bin/bash

KattisEnvironment="https://tamu.kattis.com/"

# verify correct number of arguments
ArgCount=$#
if [ $ArgCount -lt 2 ]; then
	echo "Must provide problem name, programming language, and optionally the number of samples."
	echo "Valid programming languages: cpp, py2, py3"
	exit -1
fi

# make sure not to name the problem after the script - bad things might happen
ProblemName=$1
ScriptName=`basename "$0"`
if [ $ProblemName == $ScriptName ]; then
	echo "You cannot name your problem after this script."
	exit -1
fi

# setup language as necessary
Language=$2
CodeFile=""
BuildCommand=""
BaseCode=""
if [ ${Language} = "cpp" ]; then
	CodeFile="${ProblemName}.cpp"
	BuildCommand="g++ -Wall -g --std=c++11 ${CodeFile} -o ${ProblemName}"

elif [ ${Language} = "py2" ]; then
	CodeFile="${ProblemName}.py"
	BuildCommand="@echo \"python2 ${CodeFile}\" >> ${ProblemName}; chmod +x ${ProblemName}"

elif [ ${Language} = "py3" ]; then
	CodeFile="${ProblemName}.py"
	BuildCommand="@echo \"python3 ${CodeFile}\" >> ${ProblemName}; chmod +x ${ProblemName}"

else
	echo "This script only supports these languages: cpp, py2, py3"
	exit -1
fi

# if we need to paste in samples, do that
if [ $ArgCount -gt 2 ]; then
	mkdir $ProblemName
	SampleCount=$3
	for ((Sample=1; Sample <= $SampleCount; Sample++)); do
		SampleName="sample${Sample}"

		LocalResultFile="${ProblemName}_${SampleName}.ans"
		LocalSampleFile="${ProblemName}_${SampleName}.in"

		LongResultFile="${ProblemName}/${LocalResultFile}"
		LongSampleFile="${ProblemName}/${LocalSampleFile}"

		touch ${LongResultFile}
		touch ${LongSampleFile}

		vim ${LongSampleFile}
		vim ${LongResultFile}
	done
fi

# otherwise, download them ourselves
if [ $ArgCount == 2 ]; then
	SamplesUrl="${KattisEnvironment}problems/${ProblemName}/file/statement/samples.zip"
	wget ${SamplesUrl} &> /dev/null

	if [ ! -f "samples.zip" ]; then
		echo "Could not download samples for ${ProblemName} - are you sure it exists?"
		exit -1
	fi

	unzip "samples.zip" -d ${ProblemName} &> /dev/null
	rm "samples.zip"
fi

# get the list of all files in the directory, for the sake of generating tests in Makefile
InputFiles=(${ProblemName}/*.in)

# generate the initial Makefile without tests
cat > ${ProblemName}/Makefile << EOF
# auto-generated makefile plz don't edit

all: ${ProblemName} test

clean:
	rm -f ${ProblemName}

${ProblemName}: ${CodeFile}
	${BuildCommand}
EOF

# generate the testcases for each test input file
AllFiles=""
AllSamples=""
for LongInputFile in "${InputFiles[@]}"; do
	InputFile=`basename ${LongInputFile}`
	OutputFile=`echo ${InputFile} | sed "s/\.in/\.ans/g"`
	SampleName=`echo ${InputFile} | sed "s/\.in//g"`

	AllFiles="${AllFiles} ${InputFile}"
	AllSamples="${AllSamples} ${SampleName}"

	cat >> ${ProblemName}/Makefile << EOF

${SampleName}: ${ProblemName}
	@echo -----------------------------------------------
	@echo " ${InputFile} (actual, expected)"
	@echo -----------------------------------------------
	@./${ProblemName} < ${InputFile}
	@echo ---
	@cat ${OutputFile}
EOF
done

# create the final generator for running all tests
cat >> ${ProblemName}/Makefile << EOF

test: ${ProblemName}${AllSamples}
	@echo -----------------------------------------------
	@echo " All Tests Finished"
	@echo -----------------------------------------------

.PHONY: all test${AllSamples}

EOF

# create the starter C++ file
cat > starter.cpp << EOF
#include <iostream>

using namespace std;

int main(int argc, char **argv)
{
	int testcases = 1;
	cin >> testcases;

	while (testcases--)
	{
		cout << "Hello, Kattis." << endl;
	}

	return 0;
}
EOF

# create the starter Python file
cat > starter.py << EOF
import sys

for line in sys.stdin:
	print(line)
EOF

# set starter file based on language
if [ ${Language} = "cpp" ]; then
	mv starter.cpp ${ProblemName}/${CodeFile}
	rm starter.py
else
	mv starter.py ${ProblemName}/${CodeFile}
	rm starter.cpp
fi

# all done!
echo "Initialized problem ${ProblemName}..."
