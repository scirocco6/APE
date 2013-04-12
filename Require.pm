=pod
=head1 MODULE

Require.pm - ape handler for require statements

    Essentially what require does is load in the file into a string then eval
    it.  Here if we can FIND the file we load it into a string and
    re-write as evaling that string, else we leave it alone.  We
    also puch the file name into the magic variable for tracking
    wether things have been required yet.  This should prevent required
    files from being interpreted multiple times.

    For obvious reasons if a string or the implied $_ form is used we do 
    nothing :) and assume the user will sort it out at run time.

=cut

sub processRequire{
    my $instance = shift;
    my($found, $parsed, $parseString, $save);
#
# hack off the require and white space, then snarf everything up to the
# first semicolon into the parse string
#
# broken bit, God help me if there are semicolons in the module name
# or the import list.  I really hope that's illegal
#
    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 7);
    while ($instance->{'inputCode'} =~ /^\s/o) {
        $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } # while

    while ($instance->{'inputCode'} !~ /^;/o) {
        $parseString .= substr($instance->{'inputCode'}, 0, 1);
        $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1);
    } # while

    my $save = $parseString;

    $instance->{'inputCode'} = substr($instance->{'inputCode'}, 1); # and the semi-colon 
    $parseString =~ tr/\"\'//d;
#
# ignore generated includes, leave them for run time
#
    if ($instance->{'parseString'} =~ /^[\$\%\@\&]./o) {
	$instance->{'pCode'} .= "require $save;";
	delete $instance->{'STATE'};
	return;
    } # if

#
# IGNORE :: FOR THE TIME BEING
#
    if ($instance->{'parseString'} =~ /::/o) {
	$instance->{'pCode'} .= "require $save;";
	delete $instance->{'STATE'};
	return;
    } # if


				    
    undef $found;
#
# this to be removed after the real command line switches schtuff is in
#
#    @myInclude = @INC;
    @myInclude = @MAIN::myINC;
    push @myInclude, ".", @INC;
    foreach $path (@myInclude) {
	if (-f "$path/$parseString") {
	    $found = "$path/$parseString";
	    last; 
	} # if
    } # foreach 
#
# if we can't find the file assume it will be handled at run time
#
    unless ($found) {
	$instance->{'pCode'} .= "require $save;";
	delete $instance->{'STATE'};
	return;
    } # unless
#
# If we have already sucked this file in just play it back out of the
# global hash
#
    if ($GLOBAL::Requireds{$found}) {
      print "\t\tRehashing $found.\n";
      $instance->{'pCode'} .= 
	"if(\$INC{\'$found\'}) { 1; } else { eval \$sixPERL::Require$GLOBAL::Requireds{$found};}";
      delete $instance->{'STATE'};
      return;
    } # if
#
# Load the file then polish and encode it
#
    $requireFile = Loader::loader("$found");
    print "\t\tPolishing $found...\n";
    my $polisher = new Polish;
    $requireFile = $polisher->polish($requireFile);
    if ($MAIN::Make_Parse_Files) {
      $found =~ s|/|_|g;
      print "\t\tSaving ${found}.PARSED...\n";
      open (OF1, "> ${found}.PARSED"); 
      print OF1 $requireFile; 
      close(OF1);
    } # if
    print "\t\t\tEncoding $found...\n";
    $requireFile =~ s/([\w\W])/sprintf("\\\%03o",ord($1))/eg;
#    $requireFile =~ s/([\"\$\%\@\\])/sprintf("\\\%03o",ord($1))/eg;
#    $requireFile =~ s/([\W])/sprintf("\\\%03o",ord($1))/eg;

    print "\t\t\tStoring $found length = ", length($requireFile), 
          " as ", $#GLOBAL::Requireds + 1, " ...\n";
    push @GLOBAL::Requireds, $requireFile;
    $GLOBAL::Requireds{$found} = $#GLOBAL::Requireds;

    $instance->{'pCode'} .= "if(\$INC{\'$found\'}) { 1; } else { eval \$sixPERL::Require$#GLOBAL::Requireds;}";

    delete $instance->{'STATE'};
    print "\t\t\tReturning $found...\n";
    return;
} # processRequire
1;
