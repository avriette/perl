#!/usr/bin/perl

use common::sense;
use YAML::XS;
use Data::Dumper;

my $y = YAML::XS::LoadFile( qw{ testdata/testdata.yaml } );

print Dumper $y;
