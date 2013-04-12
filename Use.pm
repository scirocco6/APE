# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
=pod
=head1 MODULE

Double.pm - ape handler for use statements

    The idea here is to just re-write the use statement as a require
statement inside a BEGIN block.  There are three types of use statements.
They are:

    use ModuleName;
    use ModuleName LIST;
    use ModuleName ();

    We re-write these as:

    BEGIN { require "Module.pm"; Module->import(); }
    BEGIN { require "Module.pm"; Module->import(LIST); }
    BEGIN { require "Module.pm"; }
=cut

sub processUse {
    my $instance = shift;
    my ($parseString, $modName);
#
# hack off the use and white space, then snarf everything up to the 
# first semicolon into the parse string
#
# broken bit, God help me if there are semicolons in the module name
# or the import list.  I really hope that's illegal
#
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 3);
    while ($instance->{'inputCode'} =~ /^\s/o) {
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1); 
    } # while

    while ($instance->{'inputCode'} !~ /^;/o) {
	$parseString .= substr($instance->{'inputCode'}, 0, 1);
	$instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } # while
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1); # and the semi-colon
#print "DEALING WITH \"$parseString\"...\n";


#
# OK, now figure out wich type of use it is and re-write it
# accordingly
#
    if ($parseString =~ /^(\w*)\s*$/o) {
#print "COPING AS \"$1.pm\"...\n";
	$instance->{'inputCode'} ="BEGIN { require \"$1.pm\"; $1->import(); }"
	    . $instance->{'inputCode'};
	delete $instance->{'STATE'};
	return;
    } # if
    if ($parseString =~ /^(\w*)\s*\(\)$/o) {
#print "COPING AS \"$1.pm\"...\n";
	$instance->{'inputCode'} = "BEGIN { require \"$1.pm\"; }" .
	    $instance->{'inputCode'};
	delete $instance->{'STATE'};
	return;
    } # if
#
# this is just a temp hack to cope with :: case
#
    if ($parseString =~ /::/) {
#      print "COPING AS \"$parseString\"...\n";
      $instance->{'pCode'} .= "use $parseString;";
      delete $instance->{'STATE'};

      return;


    } # if
      
#
# Yes this probably could be optimized for less readability
#
    $parseString =~ s/^(\w*)\b//o; # pull out and remove the module name
    $modName = $1;
    $parseString =~ s/^\s*//o;     # clean up leading white space
    $parseString =~ s/\s*$//o;     # clean up trailing white space
#    print "Module is \"$modName\"\nList is \"$parseString\"\n";
    $instance->{'inputCode'} = 
	"BEGIN { require \"$modName.pm\"; $modName->import($1); }" .
	    $instance->{'inputCode'};
    delete $instance->{'STATE'};
    return;
} # processUse
1;
