#!/usr/bin/perl
use warnings;
use strict;
use File::Find;
use Test::More;
use lib qw( t/lib/ lib/ );

my @skip_modules = qw(  );

use_ok($_) for find_modules();

done_testing;


# Find Perl modules in lib/ and t/lib,
# change from FS path names to Perl Module
# names.

sub find_modules {
    my @modules;

    find( 
        sub {
            my $module = $File::Find::name;
            return "" unless $module =~ /\.pm$/;
            s/(?:t\/)?lib\///, s/\//::/g, s/\.pm// for $module;

            next if grep { $_ eq $module } @skip_modules;
            push @modules, $module;
        },
        qw( lib t/lib )
    );

    return @modules;
}
