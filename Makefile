# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
TARGETS = ape
SOURCE  = ape.pl

LDIRT   = ape.c ape.po ape1.pl ape.c ape1.c ape ape1.po ape_bootstrap *~
LCINCS  = -I.
LCLIBS  = -lperl -lm
LCOPTS  = -g

ExtUtilsCCopts = `perl -MExtUtils::Embed -e ccopts`
ExtUtilsLDopts = `perl -MExtUtils::Embed -e ldopts`

all:	ape

perlxsi.c:
	perl -MExtUtils::Embed -e xsinit 

perlxsi.o: perlxsi.c
	$(CC) $(LCOPTS) $(LCINCS) -c perlxsi.c $(ExtUtilsCCopts)

ape1.c: ape.pl
	cp ape.pl ape1.pl
	./ape.pl -c ape1.pl

ape_bootstrap: ape1.c perlxsi.o
	$(CC) $(LCOPTS) $(LCINCS) -c ape1.c $(ExtUtilsCCopts)
	$(CC) $(LCOPTS) $(LCINCS) -o ape_bootstrap perlxsi.o ape1.o $(ExtUtilsLDopts)

ape.c: ape_bootstrap
	./ape_bootstrap -c ape.pl

ape:	ape.c perlxsi.o
	$(CC) $(LCOPTS) $(LCINCS) -c ape.c $(ExtUtilsCCopts)
	$(CC) $(LCOPTS) $(LCINCS) -o ape perlxsi.o ape.o $(ExtUtilsLDopts)

install: ape
	$(INSTALL) /usr/local/bin ape
	$(INSTALL) /usr/local/include ape.h

clean: 
	rm -f *.c *.po ape1.* *.o *~ ape_bootstrap ape
