#!/usr/bin/perl -w
#
# Copyright 2007-2009 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License Version 2.0.
#
use strict;
use Test::More;
use IO::File;
use ExtUtils::Manifest;

plan( skip_all => "Author tests not required for installation" )
  unless $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING};

my $slurp = sub {
    my $file = shift;
    my $fh = IO::File->new ($file) or die "%Error: $! $file";
    my $wholefile = join('',$fh->getlines());
    $fh->close();
    return $wholefile;
};

my $manifest = ExtUtils::Manifest::maniread();

my %skipfor = ('META.yml' => 1);
plan tests => (1 + (keys %{$manifest}) - (keys %skipfor));
ok(1);

foreach my $filename (keys %{$manifest}) {
    next if exists $skipfor{$filename};
    my $wholefile = $slurp->($filename);
    ok($wholefile && !($wholefile =~ /(.{0,10})[ \t]+$/m),"no trailing space in $filename " . ($1||""));
}
