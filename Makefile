
FC = gfortran
NESTLIBDIR = $(MULTINEST)

LIBS := -L$(NESTLIBDIR) -lmultinest $(LAPACKLIB) -lstdc++ -ldl -lcrypt -llapack

OBJFILES = rbridge.o

all: rbridge

$(NESTLIBDIR)/multinest.so:
	@echo "WARNING ----"
	@echo "You should have built multinest.so in $(NESTLIBDIR)"
	@echo "Trying to be smart and build it now ..."
	make -C $(NESTLIBDIR) libmultinest.so WITHOUT_MPI=1

Rserve/configure:
	wget https://www.rforge.net/Rserve/snapshot/Rserve_1.7-0.tar.gz -O - | tar -xvz

Rserve/clients/cxx/config.h: Rserve/configure
	cd Rserve && ./configure
	cd Rserve/clients/cxx/ && ./configure

Rserve/clients/cxx/Rconnection.o: Rserve/clients/cxx/config.h
	cd Rserve/clients/cxx/ && make Rconnection.o

%.o: %.cc Rserve/clients/cxx/config.h
	$(CXX) $(CFLAGS) -c $*.cc -I Rserve/clients/cxx/ -Wall -Wextra -pedantic

rbridge: $(OBJFILES) Rserve/clients/cxx/Rconnection.o $(NESTLIBDIR)/libmultinest.so
	$(FC) $(FFLAGS) -o rbridge Rserve/clients/cxx/Rconnection.o $(OBJFILES) $(LIBS)

clean:
	rm -f *.o *.mod rbridge

test: rbridge
	bash runtest.sh

