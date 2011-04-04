package Iterator::GroupedRange;

use strict;
use warnings;

our $VERSION = '0.02';

sub new {
    my $class = shift;
    my ( $code, $range ) = @_;
    $range ||= 1000;

    if ( ref $code eq 'ARRAY' ) {
        my @ds = @$code;
        $code = sub {
            [ splice( @ds, 0, $range ) ];
        };
    }

    return bless +{
        code      => $code,
        range     => $range,
        is_last   => 0,
        _has_next => undef,
        _buffer   => [],
    } => $class;
}

sub has_next {
    my $self = shift;
    return 0 if ( $self->{is_last} );
    return 1 if ( $self->{_has_next} );
    $self->{_buffer} = $self->{code}->();
    if ( defined $self->{_buffer} && @{ $self->{_buffer} } > 0 ) {
        $self->{_has_next} = 1;
        return 1;
    }
    else {
        return 0;
    }
}

sub next {
    my $self = shift;

    return [] if ( $self->{is_last} );
    return [] unless ( defined $self->{_buffer} );

    my @buffer = @{ $self->{_buffer} };

    while ( @buffer < $self->{range} ) {
        my $rv = $self->{code}->();
        unless ( defined $rv && @$rv > 0 ) {
            $self->{is_last} = 1;
            last;
        }
        push( @buffer, @$rv );
    }

    my @rs = splice( @buffer, 0, $self->{range} );

    $self->{_buffer} = [@buffer];
    $self->{_has_next} = @buffer > 0 ? 1 : 0;

    return \@rs;
}

sub is_last {
    $_[0]->{is_last};
}

1;
__END__

=head1 NAME

Iterator::GroupedRange - Iterate grouped array

=head1 SYNOPSIS

  use Iterator::GroupedRange;

  my @ds = (
    [ 1 .. 6 ],
    [ 7 .. 11 ],
    [ 11 .. 25 ],
  );

  my $i1 = Iterator::GroupedRange->new( sub { shift @ds; }, 10 );
  $i1->next; # [ 1 .. 10 ]
  $i1->next; # [ 11 .. 20 ]
  $i1->next; # [ 21 .. 25 ]

  my $i2 = Iterator::GroupedRange->new( [ 1 .. 25 ], 10 );
  $i2->next; # [ 1 .. 10 ]
  $i2->next; # [ 11 .. 20 ]
  $i2->next; # [ 21 .. 25 ]

=head1 DESCRIPTION

Iterator::GroupedRange is iteration module to apply grouped range array given callback or array.

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
