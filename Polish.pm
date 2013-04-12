# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
package Polish;

use Token ();
use Double ();
use Single ();
use Word ();
use Here ();
use Use ();
use Require ();

=pod
=head1 MODULE

Polish.pm - ape code polisher

This module comtains the main state machine used 
to implement a Perl code polisher.  The code polisher
takes an arbitrary Perl program as input and
returns a single line Perl program as output.

=cut


sub new {
    my $class = shift;
    $instance = {};
    bless $instance, $class;
    return $instance;
} # new

sub polish {
    my $instance = shift;

    $instance ->{'inputCode'} = shift;
    $instance -> {'pCode'} = ";"; # preload a ; so newline state is true
    study $instance -> {'pCode'}; # we are going to do ALOT of matches on it
#
# the main state loop
#
    while($instance ->{'inputCode'}) {

#
# debugging sort of schtuff
#
	if ($ENV{'apeDEBUG'}) {
	    $|=1;
	    print `clear`;
	    print "FILE --> ", @MAIN::FILE[0], " <--",
	    "\nSTATE --> ", $instance->{'STATE'}, " <--",
	    "\nREGEXP --> ", $instance->{'regexp'}, " <--\n",
	    "REPEAT --> ", $instance->{'repeat'}, " <--\n",
	    "tink --> ", $instance->{'tink'}, " <--\n",
	    "LAST  --> ", $last, " <--\n",
	    "---\nInput Code\n---\n", 
	    $instance->{'inputCode'}, 
	    "\n---\nOutput Code\n---\n", $instance->{'pCode'}, "\n";
	    if ($ENV{'apeDEBUG_AUTO'}) {
		`sleep 1`; # for autostep
	    } # if
	    else {
		getc();
	    } # else
	} # if

#
# check if a state should be repeated
# this is for tr[][] and s[][]
# type schtuff
#
	if (($instance->{'repeat'}) && (!$instance->{'STATE'})) {
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'STATE'} = $instance->{'repeat'};
	    delete  $instance->{'repeat'};
	} # if
#
# if the regexp flag is high and there is no state then 
# just copy until the next non modifier character
#
	if (($instance->{'regexp'}) && (! $instance->{'STATE'})) {

	  while ($instance->{'inputCode'} =~ /^([egimosx])/o) {
	    $instance->{'pCode'} .= $1;
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	  } # while
	  delete $instance->{'regexp'};
	  next;
	} # if

	unless ($instance->{'STATE'}) {
	    $instance->lookForToken();
	    next;
	} # unless


#
# if the state is # then we are parsing a comment
# this is easy, just ignore EVERYTHING until we hit a return
# then transition back to the UNDEF state
#

	if ($instance->{'STATE'} eq "\#") {

	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1)
		while (substr($instance->{'inputCode'}, 0, 1) ne "\n");
	    delete $instance->{'STATE'};
	    next;
	} # if

	if ($instance->{'STATE'} eq "\"") {
	    $instance->processDouble();
	    next;
	} # if

	if ($instance->{'STATE'} eq "\'") {
	    $instance->processSingle();
	    next;
	} # if

	if ($instance->{'STATE'} eq "w") {
	    $instance->processWord();
	    next;
	} # if

	if ($instance->{'STATE'} eq "<<") {
	    $instance->processHere();
	    redo;
	} # if

	if ($instance->{'STATE'} eq "use") {
	    $instance->processUse();
	    redo;
	} # if

	if ($instance->{'STATE'} eq "require") {
	    $instance->processRequire;
	    redo;
	} # if


    } # while
    return($instance->{'pCode'});
} # polish
;1


