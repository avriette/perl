#!/usr/bin/perl

use common::sense;
use YAML::XS;
use Data::Dumper;

my $y = YAML::XS::LoadFile( qw{ testdata/testdata.yml } );

print Dumper $y;
