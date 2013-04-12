# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
=pod
=head1 MODULE

Single.pm - ape single quote handler

This module contains functions for glueing together single
quoted strings

=cut

sub processSingle {
    my $instance = shift;
    if ((($instance->{'inputCode'} =~ /^\\\\/o) ||
	 ($instance->{'inputCode'} =~ /^\\\'/o)) &&
	($instance->{'clossure'} ne "\\")) {
	$instance->{'pCode'} .= sprintf("\\\%03o",
				  ord(substr($instance->{'inputCode'}, 1, 1)));
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if
#
# grabby things can be stacked !!
# I think I can get away with not escaping these here
#
    if ($instance->{'tink'} && 
	(substr($instance->{'inputCode'}, 0, 1) eq $instance->{'opener'})) {
	$instance->{'tink'}++;
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if

    if (substr($instance->{'inputCode'}, 0, 1) eq $instance->{'clossure'}) {
	if ($instance->{'tink'} > 1) {
	    $instance->{'tink'}--;
	} # if
	else {
	    delete $instance->{'STATE'};
	    $instance->{'pCode'} .= "\"";
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    return;
	} # else
    } # if

    $instance->{'pCode'} .= 
	sprintf("\\\%03o", ord(substr($instance->{'inputCode'}, 0, 1)));
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    return;
} # processSingle
;1
