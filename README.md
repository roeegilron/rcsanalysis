Code to analyze RC+S data
==========================

This code parses RC+S time domain data into human readable CSV's. 
RC+S streams data in packet form, such that if you have gaps between packets, this can adversely affect the computation of PSD's or other event related measures. 
Since most data analysis steps likely used on RC+S data rely on getting time domain data into matrix form this can be useful. 

This code also serves a resource to help understand some of the headers associated with each packet in the RC+S data. Below is a schematic example we will work with: 

![RC+S schematics](figures/packet-loss.jpg)

You will find the following data in packet headers in the `RawDataTD.json` file exported by Summit system:
`systemTick` INS clock-driven tick counter, 16bits, LSB is 100microseconds, (highly accurate, high resolution, rolls over)
`timestamp`  INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over). This represents the time since March 1st 2000 at midnight in seconds. 
To convert this raw number to a human readable form in Matlab use: 
`datetime(datevec(timeuse./86400 + datenum(2000,3,1,0,0,0)))`
`TdSampleRates`  0x00 is 250Hz, 0x01 is 500Hz, 0x02 is 1000Hz, 0xF0 is disabled
`dataTypeSequence` - packet counter, counts to 255 and roles over. 

In above example, we are streaming data at 1000Hz. Our first packet (labeled `packet #` in figure, actually named `dataTypeSequence` in header) we stream packets 0-2 but then miss packet #3. This represents a small packet loss and we can compute how much time was lost by subtracting the time of the last sample in packet 4 from the last sample on packet 3 (7537-6539). 

XXXX 



Contents: 
-------------

* `python`    - Folder with Python code to read RC+S data 
* `Matlab` - Folder with Matlab code to do the same 



