FIRST_NAME=jeffrey
LAST_NAME=ross

ASMOBJS = MainSimon.o Mastermind.o IO.o WhackAMole.o
DEFINES = -DUSE_ASM

CC = gcc
COBJS = time.o
DEPENDFLAGS = -M 
INCLUDES = -I.
LIBDIRS = 
LIBS =

CFLAGS = -Wall -marm -O2 -g
LFLAGS = -marm -O2

simon: $(COBJS) $(ASMOBJS)
	$(CC) $(CFLAGS) $(LFLAGS) -o  $@ $(COBJS) $(ASMOBJS) $(LIBDIRS) $(LIBS) -lm -lrt

.S.o:
	$(CC) -c $(DEFINES) $(CFLAGS) $(INCLUDES) $<

.c.o:
	$(CC) -c $(DEFINES) $(CFLAGS) $(INCLUDES) $<

tarfile: realclean
	rm -f $(LAST_NAME)_$(FIRST_NAME).tgz
	cp -rp . /tmp/$(LAST_NAME)_$(FIRST_NAME)
	cd /tmp; tar cfz $(LAST_NAME)_$(FIRST_NAME).tgz $(LAST_NAME)_$(FIRST_NAME)
	mv /tmp/$(LAST_NAME)_$(FIRST_NAME).tgz .
	rm -rf /tmp/$(LAST_NAME)_$(FIRST_NAME)
	make depend

depend:
	rm -f .depend
	$(CC) $(DEFINES) $(INCLUDES) $(DEPENDFLAGS) $(COBJS:.o=.c) > .depend

realclean: clean
	rm -f *~ .depend

clean:
	rm -f *.o core.*

# if we have a .depend file, include it
ifeq (.depend,$(wildcard .depend))
include .depend
endif
