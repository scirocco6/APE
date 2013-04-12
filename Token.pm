# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
require "keywords.pl";

=pod
=head1 MODULE

Token.pm - ape token hunter

This module hunts for tokens and changes the STATE accordingly.

=cut

sub lookForToken() {
    my $instance = shift;
    study $instance->{'inputCode'};
#
# hack for ,'
# yes I know this shouldn't be needed
# this is #1 thing that must be fixed
#
    if ($instance->{'inputCode'} =~ /^\,\'/o) { # starting a ' string
	$instance->{'clossure'} = "\'";
	$instance->{'STATE'} = "\'";
	$last = "lvalue";
	$instance->{'pCode'} .= "\,\""; #re-write tick as escaped " strings
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if

#
# any syntax just hanging around?
#
    if ($instance->{'inputCode'} =~ /^([\,\;\{])/o) {
	$instance->{'pCode'} .= $1;
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	$last = $1;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^([\&\|]{2})/o) {
	$instance->{'pCode'} .= $1;
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	$last = $1;
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^\)/o) {
	$last = "lvalue";
	$instance->{'pCode'} .= ")";
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if
#
# start off by seeing if we can pull out a keyword
#
    if ($instance->{'inputCode'} =~ /^([\$\@\%]*\w+)\b/o) {
	my ($word) = $1;
	if ($word =~ /^[\$\@\%]/o) {
	    $last = "lvalue";
	    $instance->{'pCode'} .= $word;
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, length($word));
	    return;
	} # if
#
# non-explicitly handled token words
#
	if ($key_words{$word}){
	    $last = $word;
	    $instance->{'pCode'} .= $word;
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 
					      length($word));
	    return;
	} # if
#
# inline use as require in a BEGIN block
#
#	    
	if ($word eq "use") {
	    $instance->{'STATE'} = "use";
	    return;
	} # if
#
# inline require as an eval of a ' string
#
	if ($word eq "require") {
	    $instance->{'STATE'} = "require";
	    return;
	} # if

	if ($word eq "qq") { # starting a qq( string?
#
# the next bit is as complicated as it is because in perl...
#
# print
# qq
# (thing1)
# ;
#
# is equivalent to...
#
# print qq(thing1);
#
# in other words qq IS a token, its meaning is, the next non-white space
# character is to be treated as the start of a string. The end of the string 
# is the next time you see that character un-escaped, unless the character
# was (, {, [, or < in which case the end char is ), }, ], or > respectively
#
# to make life harder, (. [, {, < may be nested ie
#
# print qq (
#   this is part of a string
#   ( SO IS THIS )
#   we are STILL in a string
# ); # ok, now the string is done
#
	    $instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);
#
# it is LEGAL in perl to do qq\wombat\;
# unfortunately this can lead to exploding horrors in the compiler
# therefore we will re-write these to be qq" and escape any
# bare " we find later in the string
# 
	    if ($instance->{'clossure'} =~ /\\/o) {
		$instance->{'pCode'} .= "\"";
	    } # if
	    else {
		$instance->{'pCode'} .= $instance->{'clossure'};
	    } # else
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "\"";
	    $last = "lvalue";
#
# and here are the exceptions to the qq closure rule
# I know it is VISUALLY appealing but this really sorta sucks
#
	    if ($instance->{'clossure'} =~ /([\(\{\[\<])/o) {
		$instance->{'opener'} = $1;
		$instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
		$instance->{'tink'} = 1;
		return;
	    } # if
	} # if
#
# word list
#
	if ($word eq "qw") { # starting a qw( list?
	    $instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);

	    if ($instance->{'clossure'} =~ /\\/o) {
		$instance->{'pCode'} .= "\"";
	    } # if
	    else {
		$instance->{'pCode'} .= $instance->{'clossure'};
	    } # else
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "w";
	    $last = "lvalue";
	    if ($instance->{'clossure'} =~ /([\(\{\[\<])/o) {
		$instance->{'opener'} = $1;
		$instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
		$instance->{'tink'} = 1;
		return;
	    } # if
	} # if
#
# now for qx
#
	if ($word eq "qx") { # starting a qx( string?
	    $instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);
#
# it is LEGAL in perl to do qx\wombat\;
# unfortunately this can lead to exploding horrors in the compiler
# therefore we will re-write these to be qx" and escape any
# bare " we find later in the string
# 
	    if ($instance->{'clossure'} =~ /\\/o) {
		$instance->{'pCode'} .= "\"";
	    } # if
	    else {
		$instance->{'pCode'} .= $instance->{'clossure'};
	    } # else
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "\"";
	    $last = "lvalue";
#
	    if ($instance->{'clossure'} =~ /([\(\{\[\<])/o) {
		$instance->{'opener'} = $1;
		$instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
		$instance->{'tink'} = 1;
		return;
	    } # if
	} # if
#
# everything said about qq applies to q (more or less :)
#

	if ($word eq "q") { # starting a q( string?
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);
	    $instance->{'pCode'} .= "\""; # just like a normal ' string we translate
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "\'";
	    $last = "lvalue";
	    
	    if ($instance->{'clossure'} =~ /([\(\{\[\<])/o) {
		$instance->{'opener'} = $1;
		$instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
		$instance->{'tink'} = 1;
		return;
	    } # if
	} # if
#
# m( 
#
	if (($word eq "m") && ($instance->{'pCode'} =~ /\W$/o)) {
	    $instance->{'pCode'} .= $word;
#	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    do {
		$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    } while ($instance->{'inputCode'} =~ /^\s/o);
	    $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);
	    $instance->{'pCode'} .= $instance->{'clossure'};
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "\"";
	    $instance->{'regexp'} = "TRUE";
	    $last = "lvalue";
#
# and here are the exceptions to the qq closure rule
# I know it is VISUALLY appealing but this really sorta sucks
#
	    if ($instance->{'clossure'} =~ /([\(\{\[\<])/o) {
		$instance->{'opener'} = $1;
		$instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
		$instance->{'tink'} = 1;
		return;
	    } # if
	} # if
#
# s searches
#
	if ((($word eq "s") || ($word eq "y") || ($word eq "tr"))
	    && ($instance->{'pCode'} =~ /\W$/o)) {

	  delete $instance->{'opener'};
	  $instance->{'pCode'} .= $word;
	  $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1)
	    if ($word eq "tr");
	  do {
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	  } while ($instance->{'inputCode'} =~ /^\s/o);
	  $instance->{'clossure'} = substr($instance->{'inputCode'}, 0, 1);
	  unless ($instance->{'clossure'} =~ /^[\(\{\[\<]/o) {
	    if ($instance->{'clossure'} =~ /\\/o) {
	      $instance->{'pCode'} .= "\"";
	    } # if
	    else {
	      $instance->{'pCode'} .= $instance->{'clossure'};
	    } # else
	    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	    $instance->{'STATE'} = "\"";
	    $last = "lvalue";
	    $instance->{'tink'} = 2;
	    $instance->{'regexp'} = "TRUE";
	    return;
	  } # unless

	  $instance->{'clossure'} =~ /^([\(\{\[\<])/o;
	  $instance->{'opener'} = $1;
	  $instance->{'pCode'} .= $instance->{'opener'};
	  $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	  $instance->{'clossure'} =~ tr/\(\{\[\</\)\}\]\>/;
	  $instance->{'tink'} = 1;
	  $instance->{'repeat'} = "\"";
	  $instance->{'regexp'} = "TRUE";
	  $instance->{'STATE'} = "\"";
	  $last = "lvalue";
	  return;
	} # if
      } # if 

    if ($instance->{'inputCode'} =~ /^\$\#/o) {
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 2);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^\#/o) { # maybe we're starting a comment
	$instance->{'STATE'} = "\#";
	return;
    } # if
#
# if we find pod documentation remove it
#
# First a QUICK method for people who do pod correctly
#
    if ($instance->{'inputCode'} =~ /^=pod/o) {
	$instance->{'inputCode'} =~ s/^=pod[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
#
# Unfortunately ALOT of people do pod wrong.  Even in the perl dist :( :(
# therefore we need to attempt to unpod all podlike syntax :( :(
# 
# This is perl's GREATEST problem..  Inconstant syntax and people who
# insist on using inconstant syntax.  It will prolly prevent perl
# from ever acheiving wide acceptance as a programming language
# and relegate it forever as a sysadmin scripting lingo
#
    if ($instance->{'inputCode'} =~ /^=head/o) {
	$instance->{'inputCode'} =~ s/^=head[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=item/o) {
	$instance->{'inputCode'} =~ s/^=item[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=over/o) {
	$instance->{'inputCode'} =~ s/^=over[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=back/o) {
	$instance->{'inputCode'} =~ s/^=back[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=for/o) {
	$instance->{'inputCode'} =~ s/^=for[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=begin/o) {
	$instance->{'inputCode'} =~ s/^=begin[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if
    if ($instance->{'inputCode'} =~ /^=end/o) {
	$instance->{'inputCode'} =~ s/^=end[\w\W]*?\n=cut[\w\W]*?\n//o;
	return;
    } # if


#
# is it a HERE is document?
#
    if ($instance->{'inputCode'} =~ /^<<[^=]/o) {
	$instance->{'STATE'} = "<<";
	$last = "lvalue";
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^\"/o) { # maybe we're starting a " string
	$instance->{'clossure'} = "\"";
	$instance->{'STATE'} = "\"";
	$last = "lvalue";
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if

#
# if ever something needs more testing, this hack is it
# it trys to find / strings WITHOUT swallowing up division
#
# division is lvalue / lvalue
# match is nonlvalue / anything
#
    if (($instance->{'inputCode'} =~ /^\//o) && ($last ne "lvalue")) {
	$instance->{'clossure'} = "/";
	$instance->{'STATE'} = "\"";
	$instance->{'regexp'} = "TRUE";
	$last = "lvalue";
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^\`/o) { # maybe we're starting a ` string
	$instance->{'clossure'} = "\`";
	$instance->{'STATE'} = "\"";
	$last = "lvalue";
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^(\W)\'/o) { # starting a ' string
	$instance->{'clossure'} = "\'";
	$instance->{'STATE'} = "\'";
	$last = "lvalue";
	$instance->{'pCode'} .= "$1\""; #re-write tick as escaped " strings
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 2);
	return;
    } # if

    if ($instance->{'inputCode'} =~ /^\~/o) { 
	$last = "~";
    } # if
    if ($instance->{'inputCode'} =~ /^=/o) { 
	$last = "=";
    } # if
#
# It tries to find strings early and pull them out
#
    if ($instance->{'inputCode'} =~ /^(\$[^\)\s,;=]*)/o) {
	$instance->{'pCode'} .= $1;
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 
					  length($1) );
	$last = "lvalue";
	return;
    } # if	


#
# if no token then move 1 character from the input to the pcode
# unless it is white space, if it IS white space then compress white space
#
    if ($instance->{'inputCode'} =~ /^\S/o) {
	$instance->{'pCode'} .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if
    if ($instance->{'pCode'} =~ /\s$/o) {
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
	return;
    } # if
    $instance->{'pCode'} .= " ";
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    return;
	
} # lookForToken
;1

