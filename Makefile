all: speex.c

speex.c: speex.pyx speex.pxd
	cython -o speex.c speex.pyx

clean:
	rm -f speex.c

.PHONY: clean all
