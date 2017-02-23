#!/bin/bash

START=1
END=8000
for i in $(seq $START $END); do 
  URL="https://p1pe.doe.virginia.gov/reportcard/excel.do?division=All&schoolName=$i"
  echo $URL
  curl $URL -o $i.xls
done
