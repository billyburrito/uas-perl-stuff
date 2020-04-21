#!/usr/bin/perl

use strict;

my $path = "./";
my $hide_string = "########";

if ( $ARGV[0] ) {
    if ( $ARGV[0] !~ /.*\/$/ ) {
        $ARGV[0] .= '/';
    }

    if ( ( $ARGV[0] =~ /etc/i )
	 || ( $ENV{PWD} =~ /etc/i ) ) {
        die "Do not run this in paths containing etc";
    }

    $path = $ARGV[0];
}


print "Checking $path for shadow files...\n";

opendir(DIR, $path) || die "can't opendir $path: $!";
my @shadows = grep { /shadow/ } readdir(DIR);
closedir DIR;

foreach my $file (@shadows) {
    print "removing secrets from $file\n";

    open (SHADOW, "$path$file");
    my @sfile = <SHADOW>;
    close (SHADOW);

    foreach my $line (@sfile) {
        chomp $line;
        my @sline = split ( /:/, $line );
        if ( $sline[1] =~ /.{10,}/ ) {
            $sline[1] = $hide_string;
        }
        $line = join ( ':', @sline );
        $line .= "\n";
    }

    open (NEWSHADOW, ">$path$file");
    print NEWSHADOW @sfile;
    close (NEWSHADOW);

}
