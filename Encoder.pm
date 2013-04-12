# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
package Encoder;

=pod
=head1 MODULE

Encoder.pm - ape arbitrary code embeder

This module takes as input an arbitrary single line perl program
and encodes and embeds it in a C program.

=cut

sub encoder {
    my $source = shift;
#
# dump it all in the temporary file
#

    my $file = $MAIN::filespec;
    $file =~ s/.pl$//io;
    $file .= ".po";
    
    open(OF1, "> $file");
    print OF1 "BEGIN{package sixPERL;";
    for ($offset = 0; $offset <= $#GLOBAL::Requireds; $offset++) {
      print "\t\t\tSpinning $offset...\n";
      print OF1 "\$Require$offset=\"",
                @GLOBAL::Requireds[$offset],
                "\";";
    } # for
    print OF1 "};", $source;
    close(OF1);
    undef $source;
#
# setup and open files
#
    print "\tWorking on $file...\n";
    $basename = substr($file, 0, length($file) -3);
    $newfile = "${basename}.c";
    print "\t\topening $newfile...\n";
    
    open(INFILE, "< $file") or next;
    open(OUTFILE, "> $newfile") or next;
#
# convert perl to string
#
    print OUTFILE "
#include <EXTERN.h>
#include <perl.h>

 EXTERN_C void xs_init (pTHX);

 EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);

 static PerlInterpreter *my_perl;
        void            frames();
        int             main (int argc, char** argv, char** env);
 static char *EASTEREGG = \"This program brought to you by the language \\047C\\047 and the number \\0476\\047.\\n\";

";
    print OUTFILE "\nchar PROGRAM[] = \"\\\n";
    print "\t\tStringing";
    undef $dots;
    foreach $line (<INFILE>) {
	print ".";
	if ($dots++ > 40) {
	    print "\n\t         ";
	    undef $dots;
	} # if
	chomp($line);
#
# remove blank lines
#
	next unless($line);
	$line =~ s/([\w\W])/sprintf("\\\%03o",128 + ord($1))/eg;
	print OUTFILE "$line\\\n";
#	$nline = $line;
#	for ($c = 0; $c <= length($nline); $c++) {
#	    $oline .= sprintf("\\\%03o", 128 + ord(substr($nline, $c, 1)));
#	} # for
#	print OUTFILE "$oline\\\n";
    } # foreach
    print OUTFILE "\";\n";
    print "\n";
    close(INFILE);
#
# now dump in some C code
#
    print OUTFILE "
int main (int argc, char** argv, char** env) {
  char *p;
  int i;
  char **my_argv;


  my_perl = perl_alloc();
  perl_construct(my_perl);

  for (p = PROGRAM; *p; p++)
    *p -= 128;

  my_argv = malloc((argc + 3) * sizeof(char*));
  my_argv[0] = strdup(\"\");
  my_argv[1] = strdup(\"-e\");
/*  my_argv[2] = strdup(PROGRAM); */
  my_argv[2] = PROGRAM;
  my_argv[3] = strdup(\"--\");

  for (i=4; i < (argc + 3); i++)
    my_argv[i] = argv[i-3];

  perl_parse(my_perl, xs_init, 3 + argc, my_argv, env);

  perl_run(my_perl);
  perl_destruct(my_perl);
  perl_free(my_perl);
  return 0;
} /* main */
";
#
# close the output file and try to compile it
#
# this is prolly goofy and will be cleanup up SOMEDAY
# oh yeah, it's 032 since n32 seems to be a compatibility 
# nightmare right now
#
    close(OUTFILE);
    return ($newfile);
} # sub encoder
;1
