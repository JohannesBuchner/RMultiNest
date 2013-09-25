#include <stdio.h>
#include <math.h>
#include <string.h>
#include <iostream>
#include <stdlib.h>
#include <multinest.h>

#define MAIN
#define SOCK_ERRORS

#include "sisocks.h"
#include "Rconnection.h"

Rconnection * rc;

Rdouble * Reval(const char * str) {
	Rdouble * v = (Rdouble*)rc->eval(str);
	if (!v) {
		fprintf(stderr, "return: %p\n", v); 
		std::cerr << "ERROR: R call (eval) failed!" << std::endl;
		exit(1);
	}
	return v;
}

void LogLike(double *Cube, int &ndim, int &npars, double &lnew, void *context)
{
	int i;
	Rdouble * rd_ret;
	/* hand over point to R */
	Rdouble rd_cube(Cube, npars);
	rc->assign("cube", &rd_cube);
	
	rd_ret = Reval("cube <- prior(cube); cube");
	for (i = 0; i < npars; i++) {
		/* copy over so MultiNest knows transformed param */
		Cube[i] = rd_ret->doubleAt(i);
	}
	
	rd_ret = Reval("log_likelihood(cube)");
	
	lnew = rd_ret->doubleAt(0);
	/* there might be a memory leak here, if we don't free the result */
	/*std::cout << "lnew:" << lnew << std::endl;*/
	delete rd_ret;
	printf("like: %f\n", lnew);
}

void dumper(int &nSamples, int &nlive, int &nPar, double **physLive, double **posterior, double **paramConstr, double &maxLogLike, double &logZ, double &logZerr, void *context)
{
}


int main(int argc, char *argv[])
{
	int i;
	Rconnection c;
	rc = &c;
	i = rc->connect();
	if (i) {
		char msg[128];
		sockerrorchecks(msg, 128, -1);
		fprintf(stderr, "unable to connect (result=%d, socket:%s).\n", i, msg); 
		return i;
	}
	printf("connected to R\n");

	// copied from example_eggbox_C++:
	// set the MultiNest sampling parameters
	
	
	int IS = 1;					// do Nested Importance Sampling?
	
	int mmodal = 1;					// do mode separation?
	
	int ceff = 0;					// run in constant efficiency mode?
	
	int nlive = 400;				// number of live points
	
	double efr = 0.8;				// set the required efficiency
	
	double tol = 0.5;				// tol, defines the stopping criteria
	
	int ndims = 2;					// dimensionality (no. of free parameters)
	
	int nPar = 2;					// total no. of parameters including free & derived parameters
	
	int nClsPar = 2;				// no. of parameters to do mode separation on
	
	int updInt = 1000;				// after how many iterations feedback is required & the output files should be updated
							// note: posterior files are updated & dumper routine is called after every updInt*10 iterations
	
	double Ztol = -1E90;				// all the modes with logZ < Ztol are ignored
	
	int maxModes = 100;				// expected max no. of modes (used only for memory allocation)
	
	int pWrap[ndims];				// which parameters to have periodic boundary conditions?
	for(int i = 0; i < ndims; i++) pWrap[i] = 0;
	
	char root[100] = "chains/rbridge-";			// root for output files
	
	int seed = -1;					// random no. generator seed, if < 0 then take the seed from system clock
	
	int fb = 1;					// need feedback on standard output?
	
	int resume = 0;					// resume from a previous job?
	
	int outfile = 1;				// write output files?
	
	int initMPI = 1;				// initialize MPI routines?, relevant only if compiling with MPI
							// set it to F if you want your main program to handle MPI initialization
	
	double logZero = -1E90;				// points with loglike < logZero will be ignored by MultiNest
	
	int maxiter = 0;				// max no. of iterations, a non-positive value means infinity. MultiNest will terminate if either it 
							// has done max no. of iterations or convergence criterion (defined through tol) has been satisfied
	
	void *context = 0;				// not required by MultiNest, any additional information user wants to pass

	// calling MultiNest

	nested::run(IS, mmodal, ceff, nlive, tol, efr, ndims, nPar, nClsPar, maxModes, updInt, Ztol, root, seed, pWrap, fb, resume, outfile, initMPI,
	logZero, maxiter, LogLike, dumper, context);
	
	return 0;
}

/***********************************************************************************************************************/
