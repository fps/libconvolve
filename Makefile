PREFIX=/usr/local

COMPILE_FLAGS  = -fPIC `pkg-config fftw3f samplerate sndfile --cflags`
#COMPILE_FLAGS += -g
COMPILE_FLAGS += -O3 -funroll-loops -funroll-all-loops 

LINK_FLAGS    = `pkg-config fftw3f samplerate sndfile --libs` 

# uncomment the following line if libDSP is not available for
# your platform (power pc etc.)...

# COMPILE_FLAGS += -DC_CMUL

# ...and comment this one out:

LINK_FLAGS += -L/usr/local/lib -ldsp -lstdc++


ST_TARGET = libconvolve.a
TARGET    = libconvolve.so.0.0.8
SONAME    = libconvolve.so.0
SMALLNAME = libconvolve.so
STUFF     = complex_mul convolution_init convolution_process convolution_destroy auto_remove_silence load_response threaded_convolve libconvolve_init ringbuffer
SOURCES   = $(STUFF:%=%.c)
OBJECTS   = $(STUFF:%=%.o)
HEADERS   = convolve.h

all: $(TARGET) $(ST_TARGET)

$(TARGET): $(OBJECTS) $(HEADERS)
	$(CC) -shared -Wl,-soname,$(SONAME) -o $(TARGET) $(OBJECTS) $(LINK_FLAGS)

$(ST_TARGET): $(OBJECTS) $(HEADERS)
	ar rcs $(ST_TARGET) $(OBJECTS)

$(OBJECTS): %.o: %.c 
	$(CC) -c $< $(COMPILE_FLAGS)

ringbuffer_test: ringbuffer.o ringbuffer_test.c convolve.c
	$(CC) -o ringbuffer_test ringbuffer_test.c ringbuffer.o -O3

.PHONY: clean
clean:
	rm -f $(TARGET) *~ *.o core* *.lst ringbuffer_test || true
	rm doc/* -r || true

.PHONY: doc
doc:
	doxygen doxygen.conf

.PHONY: install
install: $(TARGET)
	cp $(TARGET) $(PREFIX)/lib/
	cp $(ST_TARGET) $(PREFIX)/lib/
	cp convolve.h $(PREFIX)/include/
	ldconfig -n $(PREFIX)/lib
	ln -s $(PREFIX)/lib/$(SONAME) $(PREFIX)/lib/$(SMALLNAME) || true
