# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
=pod
=head1 MODULE

Double.pm - ape handler for HERE is document syntax

    This module is an attempt at proccessing HERE is documents

    The idea is to find the Document, remove it from the input
    stream then re-package it as a qq string

=cut

sub processHere {
    my $instance = shift;
    my ($myTYPE, $stopWord, $buffer, $tail, $needsClose);
#
# swallow white space
#
    while ($instance->{'inputCode'} =~ /^[ \t\r\f]/o) {
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } # while
#
# if no quote type then force " type
#
    unless ($instance->{'inputCode'} =~ /^[\"\'\`]/o) {
	$myTYPE = "\"";
	$needsClose = "yes";
    } # unless
    else {
	$myTYPE = substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	undef $needsClose;
    } # else
#
# OK, walk character by character the stop word into the variable
# then remove that word from the source code
#
    my ($place) = 0;


    if ($needsClose) {
	while (substr($instance->{'inputCode'}, $place, 1) =~ /\w/o) {
	    $stopWord .= substr($instance->{'inputCode'}, $place, 1);
	    $place++;
	} # while
    } # if
    else {
	while (substr($instance->{'inputCode'}, $place, 1) ne $myTYPE) {
	    $stopWord .= substr($instance->{'inputCode'}, $place, 1);
	    $place++;
	    if (substr($instance->{'inputCode'}, $place, 2) eq "\\$myTYPE") {
		$stopWord .= "$myTYPE";
		$place += 2;
	    } # if
	} # while
    } # else
    $stopWord = "\n" unless($stopWord);
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, $place);
#
# find the end of the line
#
    $place = 0;
    while (substr($instance->{'inputCode'}, $place, 1) ne "\n") {
	$place++;
    } #while
#
# store schtuff we need
#

    $tail = substr($instance->{'inputCode'}, 0, $place);
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, $place +1);
#
# move the string 
#
    while (substr($instance->{'inputCode'}, 0, length($stopWord) + 1) ne
	   "\n$stopWord") {
	$buffer .= "\\" if (substr($instance->{'inputCode'}, 0, 1) eq $myTYPE);

	$buffer .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } # while
    $buffer .= "\n";
#
# cut off the stop word
#
    do {
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } while ($instance->{'inputCode'} !~ /^\n/o);

#
# re-assemble the source code with the new string
#
    $tail = $myTYPE . $tail if ($needsClose);
    $myTYPE = " \'" if ($myTYPE eq "\'");
    $instance->{'inputCode'} = $myTYPE . $buffer . $tail . $instance->{'inputCode'};

    undef $needsClose;
    delete $instance->{'STATE'};
    
} # processHere

1;








