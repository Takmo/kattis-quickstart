#!/bin/bash

KattisEnvironment="https://tamu.kattis.com/"

# we need at least one argument (problem name) but can also take the number of sample files
ArgCount=$#
if [ $ArgCount == 0 ]
then
	echo "Must provide problem name, and optionally the number of sample files."
	exit -1
fi

# make sure not to name the problem after the script - bad things might happen
ProblemName=$1
ScriptName=`basename "$0"`
if [ $ProblemName == $ScriptName ]
then
	echo "You cannot name your problem after this script."
	exit -1
fi

# if we need to paste in samples, do that
if [ $ArgCount == 2 ]
then
	mkdir $ProblemName
	SampleCount=$2
	for ((Sample=1; Sample <= $SampleCount; Sample++))
	do
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
if [ $ArgCount == 1 ]
then
	SamplesUrl="${KattisEnvironment}problems/${ProblemName}/file/statement/samples.zip"
	wget ${SamplesUrl} &> /dev/null

	if [ ! -f "samples.zip" ]
	then
		echo "Could not download samples for \"${ProblemName}\" - are you sure it exists?"
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

${ProblemName}: ${ProblemName}.cpp
	g++ -Wall -g --std=c++11 ${ProblemName}.cpp -o ${ProblemName}
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

# generate the final generator for running all tests
cat >> ${ProblemName}/Makefile << EOF

test: ${ProblemName}${AllSamples}
	@echo -----------------------------------------------
	@echo " All Tests Finished"
	@echo -----------------------------------------------

.PHONY: all test${AllSamples}

EOF

# put a friendly little starter file in the directory :)
cat > ${ProblemName}/${ProblemName}.cpp << EOF
#include <iostream>

int main(int argc, char **argv)
{
	int testcases = 1;
	std::cin >> testcases;

	while (testcases--)
	{
		std::cout << "Hello, Kattis." << std::endl;
	}

	return 0;
}
EOF

# all done!
echo "Initialized problem ${ProblemName}..."
