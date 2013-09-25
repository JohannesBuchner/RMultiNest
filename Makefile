
FC = gfortran
NESTLIBDIR = $(MULTINEST)/lib/

LIBS := -L$(NESTLIBDIR) -lmultinest $(LAPACKLIB) -lstdc++ -ldl -lcrypt -llapack
INCS := -I $(MULTINEST)/includes/ 

OBJFILES = rbridge.o

all: rbridge

$(NESTLIBDIR)/multinest.so:
	@echo "ERROR ----"
	@echo "You should have built multinest.so in $(NESTLIBDIR)"
	@echo "Set MULTINEST to point to the directory you compiled MultiNest in ..."
	@echo "${MULTINEST}/lib should contain libmultinest.so."

$(MULTINEST)/includes/multinest.h:
	@echo "ERROR ----"
	@echo "Set MULTINEST to point to the directory you compiled MultiNest in."
	@echo "${MULTINEST}/includes should contain multinest.h."

Rserve/configure:
	wget https://www.rforge.net/Rserve/snapshot/Rserve_1.7-0.tar.gz -O - | tar -xvz

Rserve/clients/cxx/config.h: Rserve/configure
	cd Rserve && ./configure
	cd Rserve/clients/cxx/ && ./configure

Rserve/clients/cxx/Rconnection.o: Rserve/clients/cxx/config.h
	cd Rserve/clients/cxx/ && make Rconnection.o

rbridge: $(OBJFILES) Rserve/clients/cxx/Rconnection.o $(NESTLIBDIR)/libmultinest.so
	$(FC) $(FFLAGS) -o rbridge Rserve/clients/cxx/Rconnection.o $(OBJFILES) $(INCS) $(LIBS)

%.o: %.cc Rserve/clients/cxx/config.h
	$(CXX) $(CFLAGS) -c -I Rserve/clients/cxx/ -Wall -Wextra -pedantic $(INCS) $*.cc 

clean:
	rm -f *.o *.mod rbridge

test: rbridge
	bash runtest.sh

