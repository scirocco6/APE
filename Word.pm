# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
=pod
=head1 MODULE

Word.pm - ape double quote handler

This module contains functions for glueing together word lists

=cut

sub processWord {
    my $instance = shift;
    my $flag = true;
    do {
      if (($instance->{'clossure'} ne "\\") &&
	  ($instance->{'inputCode'} =~ /^\\/o)) { # ignore things escaped
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	next;
      }	# if
      
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
	next;
      }	# if
      
      
      #
      # returnss inside strings are packed up
      # as white space
      #
      if (substr($instance->{'inputCode'}, 0, 1) eq "\n") {
	$instance->{'pCode'} .= " ";
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	next;
      }	# if
      
      if (substr($instance->{'inputCode'}, 0, 1) eq $instance->{'clossure'}) {
	if ($instance->{'tink'} > 1) {
	  $instance->{'tink'}--;
	} # if
	else {
	  delete $instance->{'STATE'};
	  delete $instance->{'tink'};
	  undef $flag;
	  if ($instance->{'clossure'} eq "\\") {
	    $instance->{'pCode'} .= "\"";
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    next;
	  } # if
	} # else
      }	# if
      $instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } while ($flag);
} # processWord
1;





