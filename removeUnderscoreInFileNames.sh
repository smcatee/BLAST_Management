#!/bin/bash

inputFolder="/Users/smcatee/Downloads/Merai-CSV/"
for file in $inputFolder*; do
	mv "${file}" "${inputFolder}${file#*_}"
done
