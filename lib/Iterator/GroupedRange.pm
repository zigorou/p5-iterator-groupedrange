package Iterator::GroupedRange;

use strict;
use warnings;

our $VERSION = '0.03';

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

Iterator::GroupedRange - Iterates rows is grouped by range

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

Iterator::GroupedRange is module to iterate rows grouped by range. It accepts other iterator to get rows, or list.

=head1 METHODS

=head2 new( \&iterator[, $range] )

Return new instance. The range variable is default 1000.

=head2 new( \@list[, $range] )

Return new instance. The range variable is default 1000.

=head2 has_next()

Return which has next rows or not.

=head2 next()

Return next rows.

=head2 is_last()

Return which is ended of iteration or not.

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
