# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
package Loader;

=pod
=head1 MODULE

Loader.pm - ape loader

This is just a simple module to read in a file and stuff it into a string.
Few if any surprises here.  

=cut

sub loader {
    $fileName = shift;
    my ($buf, $bigBuf);

    open(F1, "< $fileName");
    while (read F1, $buf, 65535) {
	$bigBuf .= $buf;
    } # while
    return($bigBuf);
} # loader
;1
