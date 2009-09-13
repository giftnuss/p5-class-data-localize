package Class::Data::Localize;

use strict qw(vars subs);
use vars qw($VERSION);
$VERSION = '0.03_2';

use ReleaseAction ();

our $warn_redefine = 1;

our %methods;
%methods = (
    'lazy_default' => sub {
        my ($declaredclass,$attr,$code) = @_;
        my $default;
        $default = sub {
            my $wantclass = ref($_[0]) || $_[0];
            $_[1] = $code->() unless defined $_[1];

            if(@_==3) {
               $_[2] = ReleaseAction->new(sub {
                   local $warn_redefine;
                   $methods{'make_accessor'}->($wantclass,$attr,$default);
               });
            }
            local $warn_redefine;
            $methods{'mk_classdata'}->($wantclass,$attr,$_[1]);
            shift;
            return $wantclass->$attr(@_);
        };
        return $default;
    },

    'class_accessor' => sub {
        my ($declaredclass, $attribute,$data) = @_;

        my $accessor;
        $accessor = sub {
            my $wantclass = ref($_[0]) || $_[0];
            if(@_==3) {
                my $current = $data;
                my $stacked = $_[2]; # maybe a lazy default release action
                $_[2] = ReleaseAction->new(sub {
                    $data = $current;
                    undef($stacked);
                });

                if($wantclass ne $declaredclass){
                    shift();
                    $methods{'mk_classdata'}->($wantclass,$attribute,$data);
                    return $wantclass->$attribute(@_);
                }
            }
            else {
                if(@_>1 && $wantclass ne $declaredclass) {
                    shift();
                    $methods{'mk_classdata'}->($wantclass,$attribute);
                    return $wantclass->$attribute(@_)
                }
            }
            $data = $_[1] if @_>1;
            return $data;
        };
        return $accessor;
    },

    'make_accessor' => sub {
        my ($declaredclass,$attribute,$accessor) = @_;

        my $alias = "_${attribute}_accessor";
        if($warn_redefine) {
            *{$declaredclass.'::'.$attribute} = $accessor;
            *{$declaredclass.'::'.$alias}     = $accessor;
        }
        else {
            no warnings 'redefine';
            *{$declaredclass.'::'.$attribute} = $accessor;
            *{$declaredclass.'::'.$alias}     = $accessor;
        }
    },

    'mk_classdata' => sub {
        my ($declaredclass, $attribute,@args) = @_;

        if( ref $declaredclass ) {
            require Carp;
            Carp::croak("mk_classdata() is a class method, not an object method");
        }
        my ($accessor);
        if(@args > 1) {
            my %args = @args;
            my $code = $args{'default'};

            $methods{'mk_classdata'}->($declaredclass, $attribute, undef);
            $accessor = $methods{'lazy_default'}->($declaredclass, $attribute, $code);
            local $warn_redefine;
            $methods{'make_accessor'}->($declaredclass,$attribute,$accessor)
        }
        else {
            $accessor = $methods{'class_accessor'}->($declaredclass, $attribute, $args[0]);
            $methods{'make_accessor'}->($declaredclass,$attribute,$accessor)
        }
    }
);

*mk_classdata = $methods{'mk_classdata'};

1;

__END__

=head1 NAME

Class::Data::Localize - Localizable, inheritable, overridable class data

=head1 SYNOPSIS

  package Prince;
  use base qw(Class::Data::Localize);

  # Set up HomeDir as localizable, inheritable class data.
  Prince->mk_classdata('HomeDir');

  # Declare the location of the home dir for this class.
  Prince->HomeDir('/wooden/house/');

  # Teporary move to
     { Prince->HomeDir('/stone/castle',my $move);
       if(Prince->kiss("princess")) {
          $move->cancel
          # live happy in stone castle until end of time
       }
     };

  print Prince->HomeDir; # back in /wooden/house when no kiss

=head1 DESCRIPTION

This is an alternative to Class::Data::Inheritable with the feature
added, that the class data can be localized, similar to the function
of the keyword C<local>.

=head2 Class Method C<mk_classdata>

This class method works the same way as in C::D::I.

=head2 Compatibility

It is mostly compatible with C::D::I but attention should on the accessor
parameter list. If an accessor is called with an array as argument list,
than a move to this module will break your code.

   Stuff->DataFile(@args); # make sure @args <= 1 or
                           # unwanted things will happen

=head2 Localize Class Data

To localize a value give the accessor a lexical variable as second
argument. Under the hood this module uses than the function of
L<ReleaseAction> to provide the feature. It stores in the variable an
ReleaseAction object. This let's cancel the localization before the
variable goes out of scope. When canceled the localized value becomes
the new persistent value.

=head2 Lazy Default Value

With version 0.3 a new feature is added.

   Class->mk_classdata('attribute',default => sub { ... });

The return value of the code reference will be used as default value
when the accessor is called with an undefined value the first time. This
works together with the localize class data feature, but not
perfectly. Inheritance needs more tests when both play together.

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

Class::Data::Inheritable and Class::Data::Localize can't be used
together easily. This was an early design decision which is maybe wrong.

Expect more when lazy default is used together with localization.

=head1 TODO

Test and fix localization with inheritance and lazy defaults.

Please report any bugs or feature requests to
C<bug-package-subroutine@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyleft 2007-2009 Sebastian Knapp <sk@computer-leipzig.com>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5 itself.

=cut

