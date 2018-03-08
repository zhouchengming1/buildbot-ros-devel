#! /bin/bash

for line in $(reprepro list xenial); do
	pkg=$(echo $line | cut -d" " -f2)
	reprepro remove xenial $pkg
done

