SRCPATH = standalone-earth/src

VPATH = $(SRCPATH)/blas $(SRCPATH)/R $(SRCPATH)
CFLAGS= -DSTANDALONE -DMAIN -Wall -pedantic -Wextra -O3 -std=gnu99 -fPIC
OBJS = earth.o d_sign.o daxpy.o dcopy.o ddot.o dnrm2.o dqrls.o dqrsl.o dscal.o dtrsl.o dqrdc2.o


libearth.so: $(OBJS)
	$(CC) -shared -o libearth.so $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *o

cleanbuild: clean
	rm -rf standalone-earth
	rm -f standalone-earth-*.tar.gz

cleanall: cleanbuild
	rm -rf usr
	rm -f deps.jl
