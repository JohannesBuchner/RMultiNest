==========================
R Bridge for MultiNest
==========================

Author: Johannes Buchner (C) 2012

About
---------------------
This code allows likelihood functions written in R to be used by MultiNest.


How does it work
---------------------
The main program will connect to R using Rserve, and call R through that for 
each point evaluation.


Installation
---------------------

 1. Download Rserve from http://www.rforge.net/Rserve/ and put into this directory.
 
 2. go to Rserve/clients/ and compile the Rserve client.
 
   > ./configure && make 
 
 3. run make to compile Rbridge
   
   > make

 4. In R, install RServe using the instructions on the website. In short:
 
   > R
   >> install.packages("Rserve")


Running
---------------------

 1. Write log likelihood function in a R file (has to be called "log_likelihood"),
    and a prior transformation (has to be called "prior")
    
  test.r:
   
    prior <- function(cube) cube
    
    log_likelihood <- function(params) { 
    print (params);
    0
    }
   
   This is an example flat log_likelihood, and a flat prior.

 2. Write a config file that tells which file to load

   conf.rs:
   
     source test.r
  
 3. Run Rserve
    
    $ R
    > library(Rserve)
    > Rserve(args=c("--RS-conf", "conf.rs", "--no-save"))

 4. run ./rbridge in shell

   $ ./rbridge

   This will connect to R using Rserve, and call R through that for each point evaluation.

 5. Finally, terminate Rserve
 
   $ killall Rserve-bin.so



