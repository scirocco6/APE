# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#

package Compile;

=pod
=head1 MODULE

Compile.pm - ape code compiler

This module encapsulates all the nastyness needed to actually compile
the C output of ape

=cut

sub compile {
    my $newFile = shift;
    my $oFile = $newFile;
    my $poFile = $newFile;
    $oFile =~ s/\.c$/\.o/;
    $poFile =~ s/\.c$/\.po/;
    
    my $ccopts = `perl -MExtUtils::Embed -e ccopts`;
    my $ldopts = `perl -MExtUtils::Embed -e ldopts`;
    chomp($ldopts);
    $ldopts .= " -static -shared-libgcc" if ($MAIN::Link_Type eq "STATIC");

    `perl -MExtUtils::Embed -e xsinit`;
    `gcc -c perlxsi.c $ccopts`;

    if ($MAIN::OutputName) {
	print "\t\tCompiling";
	`gcc -I. -c $newFile $ccopts`;
	print "\n\t\tLinking";
	`gcc -I. -o $MAIN::OutputName $oFile perlxsi.o $ldopts`;
    } # if
    else {
	print "\t\tCompiling";
	`gcc -I. -c $newFile $ccopts`;
	print "\n\t\tLinking";
	`gcc -I. $oFile perlxsi.o $ldopts`;
    } # else
    `rm perlxsi.c perlxsi.o $newFile $oFile $poFile`;
    print "\n";
} # compiler
;1




