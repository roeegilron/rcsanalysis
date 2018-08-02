Code to analyze RC+S data
==========================

This code parses RC+S time domain data into human readable CSV's. 
RC+S streams data in packet form, such that if you have gaps between packets, this can adversely affect the computation of PSD's or other event related measures. 
Since most algorithms used on RC+S data rely on data in matrix form this can be useful. 

This code also serves a repo to help understand some of the headers associated with each packet in the RC+S data. Below is a schematic example we will work with: 

![RC+S schematics](figures/packet-loss.jpg)



Contents: 
-------------

* `python`    - Folder with Python code to read RC+S data 
* `Matlab` - Folder with Matlab code to do the same 



