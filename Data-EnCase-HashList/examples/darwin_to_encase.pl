#!/usr/bin/perl

use warnings;
use strict;

use lib qw{ lib };

use Data::EnCase::HashList;
use Data::EnCase::HashList::Hash;
use Data::Dumper;
use File::Slurp;

my @md5_lines = read_file( qw{ data/darwin_md5.txt } );

my @objects = Data::EnCase::HashList::Hash->new_from_md5( @md5_lines );

# print Dumper( \@objects );

my $hl = Data::EnCase::HashList->new( \@objects, 'darwinhashes.txt' );

print Dumper( $hl );
