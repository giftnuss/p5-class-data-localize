package Class::Data::Localize;

use strict qw(vars subs);
use vars qw($VERSION);
$VERSION = '0.01';

use ReleaseAction ();

sub mk_classdata {
    my ($declaredclass, $attribute, $data) = @_;

    if( ref $declaredclass ) {
        require Carp;
        Carp::croak("mk_classdata() is a class method, not an object method");
    }

    my $accessor = sub {
        my $wantclass = ref($_[0]) || $_[0];
        
        if(@_==3) {
            my $current = $data;
            $_[2] = End::end { $data = $current };
            
            if($wantclass ne $declaredclass){
                return $wantclass->mk_classdata($attribute,$data)->(@_);
            }
        }
        else {
            return $wantclass->mk_classdata($attribute)->(@_)
              if @_>1 && $wantclass ne $declaredclass;
        }
        $data = $_[1] if @_>1;
        return $data;
    };

    my $alias = "_${attribute}_accessor";
    *{$declaredclass.'::'.$attribute} = $accessor;
    *{$declaredclass.'::'.$alias}     = $accessor;
}

1;

__END__

=head1 NAME

Class::Data::Localize - Localizable, Inheritable, overridable class data

=head1 SYNOPSIS

  package Stuff;
  use base qw(Class::Data::Localize);

  # Set up DataFile as inheritable class data.
  Stuff->mk_classdata('HomeDir');

  # Declare the location of the data file for this class.
  Stuff->HomeDir('/wooden/house/');

  # Teporary move to
     { Stuff->HomeDir('/stone/castle',my $move)
     ...
     }
     
  print Stuff->HomeDir; # back in /wooden/house
  
=head1 DESCRIPTION

This is an alternative to Class::Data::Inheritable with the feature
added, that the class data can be localized, similar to the function
of the keyword C<local>.

It is mostly compatible with C::D::I but attention should on the
prameter list. If an accessor is called with an array as argument list,
than a move to this module will break your code.

   Stuff->DataFile(@args); # make sure @args <= 1 or
                           # unwanted things will happen
                           
To localize a value give the accessor a lexical variable as second 
argument. Under the hood this module uses than the function of 
L<ReleaseAction> to provide the feature. This let's cancel the
localization before the variable goes out of scope.

=head1 SEE ALSO

=over 4

=item L<ReleaseAction>

=item L<Class::Data::Inheritable>

=back

=head1 AUTHOR

Original code by Damian Conway.

Maintained by Michael G Schwern until September 2005.

Class::Data::Inheritable is maintained by Tony Bowden.

Derived Class::Data::Localize by Sebastian Knapp

=head1 BUGS

Please report any bugs or feature requests to
C<bug-package-subroutine@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyleft 2007-2008 Sebastian Knapp <sk@computer-leipzig.com>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

