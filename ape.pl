#!/usr/bin/perl
# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
#
# initialize global state variables
#
# TEST TEST TEST
use Polish;
use Compile;
use Encoder;
use Loader;

$| = 1;
unless ($#ARGV +1) {
    print STDERR "USAGE: $0 ProgramName <ProgramName2> ...\n";
    exit -10;
} # unless
while ($_ = shift(@ARGV)) {
  if (/^\-/o) {
    if (/^\-I/o) {
      s/^\-I//o;
      $_ = shift(@ARGV) unless ($_);
      print "\t\t...adding $_ to include path.\n";
      push(@MAIN::myINC, $_);
      next;
    } # if


    if (/^\-o/o) {
      s/^\-o//o;
      $_ = shift(@ARGV) unless ($_);
      $MAIN::OutputName = $_;
      next;
    } # if


    if (/^\-c/o) {
      $MAIN::No_Compile_Flag = "TRUE";
      next;
    } # if
    if (/^\-p/o) {
      $MAIN::Make_Parse_Files = "TRUE";
      next;
    } # if
    if (/^\-s/o) {
      $MAIN::Link_Type = "STATIC";
      next;
    } # if
    if (/^\-d/o) {
      $MAIN::Link_Type = "DYNAMIC";
      next;
    } # if
  } # if

  print "\tWorking on $_...\n";
  unshift (@MAIN::FILE, $_);
  $MAIN::filespec = $_;
  my $polisher = new Polish;
  if ($MAIN::No_Compile_Flag) {
    Encoder::encoder($polisher->polish(Loader::loader($_)));
  } # if 
  else {
    Compile::compile(Encoder::encoder($polisher->polish(Loader::loader($_))));
  } # else
} # while




