#!/bin/bash

ScriptName=`basename "$0"`

ArgCount=$#
SampleCount=1

if [ $ArgCount == 0 ]
then
	echo "Must provide problem name, and optionally the number of sample files."
	exit -1
fi

ProblemName=$1

if [ $ProblemName == $ScriptName ]
then
	echo "You cannot name your problem after this script."
	exit -1
fi

if [ $ArgCount == 2 ]
then
	ArgCount=$2
fi

mkdir $ProblemName

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

cat > ${ProblemName}/Makefile << EOF
# auto-generated makefile plz don't edit

all: ${ProblemName} test

clean:
	rm -f hello

${ProblemName}: ${ProblemName}.cpp
	g++ -Wall -g --std=c++11 ${ProblemName}.cpp -o ${ProblemName}
EOF

AllFiles=""
AllSamples=""

for ((Sample=1; Sample <= $ArgCount; Sample++))
do
	SampleName="sample${Sample}"

	LocalResultFile="${SampleName}.out"
	LocalSampleFile="${SampleName}.txt"

	LongResultFile="${ProblemName}/${LocalResultFile}"
	LongSampleFile="${ProblemName}/${LocalSampleFile}"

	touch ${LongResultFile}
	touch ${LongSampleFile}

	vim ${LongSampleFile}
	vim ${LongResultFile}

	AllFiles="${AllFiles} ${LocalSampleFile}"
	AllSamples="${AllSamples} ${SampleName}"

	cat >> ${ProblemName}/Makefile << EOF

sample${Sample}: ${ProblemName}
	@echo -----------------------------------------------
	@echo " ${LocalSampleFile} (actual, expected)"
	@echo -----------------------------------------------
	@./${ProblemName} < ${LocalSampleFile}
	@echo ---
	@cat ${LocalResultFile}
EOF
done

cat >> ${ProblemName}/Makefile << EOF

test: ${ProblemName}${AllSamples}
	@echo -----------------------------------------------
	@echo " All Tests Finished"
	@echo -----------------------------------------------

.PHONY: all test${AllSamples}

EOF

echo "Initialized problem ${ProblemName}..."
