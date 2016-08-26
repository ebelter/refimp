package RefImp::Ace::Sequence;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    my $self = bless \%params, $class;
    $self->_validate;
    $self->_init_;

    $self;
}

sub _validate {
    my $self = shift;

    die "No bases given!" if not $self->{bases};
    $self->{pad_char} ||= '*';
}

sub _init_ {
    my $self = shift;

    my $bases = $self->{bases};
	my $bases_length = length($bases);

	my (@padded_to_unpadded, @unpadded_to_padded);
	my $unpadded_index = 0;
    my $pad_char = $self->{pad_char};

	for ( my $padded_index = 0; $padded_index < $bases_length; $padded_index++ ) {
		$unpadded_to_padded[$unpadded_index] = $padded_index;
        if( substr($bases, $padded_index, 1) ne $pad_char ) {
			$padded_to_unpadded[$padded_index] = $unpadded_index;
			$unpadded_index++;
		}
		else {
			$padded_to_unpadded[$padded_index] = $pad_char;
		}
	}

    if ( $padded_to_unpadded[ $bases_length - 1 ] eq $pad_char ) { # remove trailing unpadded positions that are pads
        pop @unpadded_to_padded;
    }

    $self->{padded_to_unpadded} = \@padded_to_unpadded;
    $self->{unpadded_to_padded} = \@unpadded_to_padded;
}

sub unpadded_for_padded_position {
	my ($self, $padded_position) = @_;

	while ($padded_position > 1 ) {
		last if $self->{padded_to_unpadded}->[$padded_position - 1] ne $self->{pad_char};
        $padded_position--;
	}

	# sequence starts with pads? return 0?
	return 0 if $padded_position == 1 && $self->{padded_to_unpadded}->[$padded_position - 1] eq $self->{pad_char};

	return $self->{padded_to_unpadded}->[$padded_position - 1] + 1;
}

sub base_for_padded_position { substr($_[0]->{bases}, ($_[1] - 1), 1) }

1;

