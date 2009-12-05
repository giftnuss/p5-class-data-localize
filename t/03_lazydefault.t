use strict;
use Test::More; # tests => 8;

package Ray;
use base qw(Class::Data::Localize);
Ray->mk_classdata('Ubu', default => sub { 'Plong' });
Ray->mk_classdata('DataFile', default => sub { '/etc/stuff/data' });
Ray->mk_classdata('MoreData', default => sub { '/etc/more/data' });
Ray->mk_classdata('Sims', default => sub { 'emosewa' });

package main;

is(Ray->Ubu,'Plong');

is(Ray->DataFile('/etc/config/stuff/data'), '/etc/config/stuff/data');
is(Ray->DataFile, '/etc/config/stuff/data');

{ my $local;
  is(Ray->MoreData('/etc/more/stuff/data',$local), '/etc/more/stuff/data');

  is(Ray->MoreData, '/etc/more/stuff/data');
};

is(Ray->MoreData,'/etc/more/data');

package Gun;
use base 'Ray';

package main;
Ray->Sims('iko');
is(Ray->Sims,'iko');
is(Gun->Sims,'iko');

done_testing;

