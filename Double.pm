# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
=pod
=head1 MODULE

Double.pm - ape double quote handler

This module contains functions for glueing together double
quoted strings

=cut

sub processDouble {
    my $instance = shift;

    if (($instance->{'clossure'} ne "\\") &&
	($instance->{'inputCode'} =~ /^\\/o)) { # ignore things escaped
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if


    if ($instance->{'clossure'} eq "\\") {
	$instance->{'pCode'} .= "\\"
	    if (($instance->{'inputCode'} =~ /^\"/o) &&
		($instance->{'pCode'} !~ /\\$/o))
	    } # if

#
# grabby things can be stacked !!
#
    if ($instance->{'tink'} && 
	(substr($instance->{'inputCode'}, 0, 1) eq $instance->{'opener'})) {
	$instance->{'tink'}++;
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if


#
# returns inside doublequoted strings are packed as \n
#
    if (substr($instance->{'inputCode'}, 0, 1) eq "\n") {
	$instance->{'pCode'} .= "\\n";
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if


    if (substr($instance->{'inputCode'}, 0, 1) eq $instance->{'clossure'}) {
	if ($instance->{'tink'} > 1) {
	    $instance->{'tink'}--;
	} # if
	else {
	    delete $instance->{'STATE'};
	    delete $instance->{'tink'};
	    if ($instance->{'clossure'} eq "\\") {
		$instance->{'pCode'} .= "\"";
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
		return;
	    } # if
	} # else
    } # if
    $instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
} # processDouble
1;





