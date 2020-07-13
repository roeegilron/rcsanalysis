Attempt at faster PAC code  
==========================

Files: 
-------------

* `computePAC()`    - Functional version to implement in code 
* `CallerRoutine()` - Example function - contains core elements of code with inputs of functional version  
* `ModIndex_v3()`   - Function that computes MI  
* `ExtractHGHFOOpenField,mat` - sample data 
* `eegfilt()` - filtering from eeglab   


Main changes used to speed up PAC computation: 
-------------

* Use logical indexing 
* Pre compute values for MI function 
* Largest dimension first arrays 
* Linearize `Comodulogram` variable for faster `parfor` performance 

Tried and failed / modest gains: 
-------------
* Vectorizing code by pre computing indexing arrays 

To do: 
-------------
* Try using `gpuArray` 
* Implement surragtes as option (stats) 



