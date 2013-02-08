==========================
R Bridge for MultiNest
==========================

Author: Johannes Buchner (C) 2012

About
---------------------
This code allows likelihood functions written in R (http://www.r-project.org) to be used by MultiNest.


How does it work
---------------------
The main program will connect to R using Rserve, and call R through that for 
each point evaluation.


Installation
---------------------------

If you haven't already, download and build MultiNest (e.g. from https://github.com/JohannesBuchner/MultiNest)
Make sure libnest3.so is in your library path if it is not already::

	$ export LD_LIBRARY_PATH=/mnt/data/daten/PhD/programming/large/MultiNest/


.. hint:: Quick installation::
	
	   $ R --no-save
	   > install.packages("Rserve")
	   > quit()
	   $ make rbridge test
	
	If that doesn't go through smoothly, follow the manual steps 0-4. 

Please report issues at https://github.com/JohannesBuchner/RMultiNest/issues

0. Download this package (latest at https://github.com/JohannesBuchner/RMultiNest).

Building Rserve C++ client
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Otherwise, follow these manual steps.

1. Download Rserve (the tar file, Rserve_xxxx.tar.gz) from http://www.rforge.net/Rserve/ and extract it into this directory. You should now have::

     $ ls
     Makefile
     README.rst
     multinest.h
     rbridge.cc
     Rserve/

2. Configure Rserve::

     $ ./Rserve/configure 
   
2. Configure and build the Rserve C++ client (in Rserve/clients/cxx/)::

     $ cd Rserve/clients/cxx/
     $ ./configure && make
     $ cd ../../../

Building Rbridge
~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Run make to compile Rbridge::

     $ make

Installing Rserve in R
~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. In R, install RServe using the instructions on the website. In short::

     $ R
     > install.packages("Rserve")

Running
---------------------

The "runtest.sh" script runs the steps below for testing whether the installation worked.
But you probably want to understand how to run your own code, so follow these steps.

1. Write log likelihood function in a R file (has to be called "log_likelihood"),
   and a prior transformation (has to be called "prior")
    
   test.r::

       prior <- function(cube) cube
       
       log_likelihood <- function(params) { 
       print (params);
       0
       }

   This is an example flat log_likelihood, and a flat prior.

2. Write a config file that tells which file to load

   conf.rs::
   
       source test.r
 
3. Run Rserve
   ::
 
    $ R
    > library(Rserve) # you installed this package before using install.packages
    > Rserve(args=c("--RS-conf", "conf.rs", "--no-save"))
 
4. run ./rbridge in shell
   ::

   $ ./rbridge

   This will connect to R using Rserve, and call R through that for each point evaluation.

5. Finally, terminate Rserve
   ::
 
   $ killall Rserve-bin.so



