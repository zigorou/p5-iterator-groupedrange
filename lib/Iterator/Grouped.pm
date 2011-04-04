package Iterator::Grouped;

use strict;
use warnings;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/grouped code is_last _has_next _buffer/],
);

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{ @_ };
    $args = +{
	grouped => 1000,
	%$args,
	is_last => 0,
	_has_next => undef,
	_buffer => [],
    };
    bless $args => $class;
}

sub has_next {
    my $self = shift;
    return 0 if ( $self->{is_last} );
    return 1 if ( $self->{_has_next} );
    $self->{_buffer} = $self->{code}->();
    if ( defined $self->{_buffer} && @{$self->{_buffer}} > 0 ) {
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

    my @buffer = @{$self->{_buffer}};

    while ( @buffer < $self->{grouped} ) {
	my $rv = $self->{code}->();
	unless ( defined $rv && @$rv > 0 ) {
	    $self->{is_last} = 1;
	    last;
	}
	push(@buffer, @$rv);
    }

    my @rs = splice( @buffer, 0, $self->{grouped} );

    $self->{_buffer} = [ @buffer ];
    $self->{_has_next} = @buffer > 0 ? 1 : 0;

    return \@rs;
}

1;
__END__

=head1 NAME

Iterator::Grouped -

=head1 SYNOPSIS

  use Iterator::Grouped;

=head1 DESCRIPTION

Iterator::Grouped is

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
