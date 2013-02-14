
FC = gfortran
NESTLIBDIR = ..

LIBS := -L$(NESTLIBDIR) -lnest3 $(LAPACKLIB) -lstdc++ -ldl -lcrypt -llapack

OBJFILES = rbridge.o

all: rbridge

$(NESTLIBDIR)/libnest3.so:
	@echo "WARNING ----"
	@echo "You should have built libnest3.so in $(NESTLIBDIR)"
	@echo "Trying to be smart and build it now ..."
	make -C $(NESTLIBDIR) libnest3.so WITHOUT_MPI=1

Rserve/configure:
	wget https://www.rforge.net/Rserve/snapshot/Rserve_1.7-0.tar.gz -O - | tar -xvz

Rserve/clients/cxx/config.h: Rserve/configure
	cd Rserve && ./configure
	cd Rserve/clients/cxx/ && ./configure

Rserve/clients/cxx/Rconnection.o: Rserve/clients/cxx/config.h
	cd Rserve/clients/cxx/ && make

%.o: %.cc Rserve/clients/cxx/config.h
	$(CXX) $(CFLAGS) -c $*.cc -I Rserve/clients/cxx/ -Wall -Wextra -pedantic

rbridge: $(OBJFILES) Rserve/clients/cxx/Rconnection.o $(NESTLIBDIR)/libnest3.so
	$(FC) $(FFLAGS) -o rbridge Rserve/clients/cxx/Rconnection.o $(OBJFILES) $(LIBS)

clean:
	rm -f *.o *.mod rbridge

test: rbridge
	bash runtest.sh

