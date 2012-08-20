
FC = gfortran
NESTLIBDIR = ..

LIBS := -L$(NESTLIBDIR) -lnest3 $(LAPACKLIB) -lstdc++ Rserve/clients/Rconnection.o -ldl -lcrypt -llapack

OBJFILES = rbridge.o

all: rbridge 

%.o: %.cc
	$(CXX) $(CFLAGS) -c $*.cc -I Rserve/clients/cxx/ -Wall -Wextra -pedantic

rbridge: $(OBJFILES)
	$(FC) $(FFLAGS) -o ../rbridge $(OBJFILES) $(LIBS)

clean:
	rm -f *.o *.mod ../rbridge


