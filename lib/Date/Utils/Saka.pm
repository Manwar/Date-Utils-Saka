package Date::Utils::Saka;

$Date::Utils::Saka::VERSION = '0.02';

=head1 NAME

Date::Utils::Saka - Saka date specific routines as Moo Role.

=head1 VERSION

Version 0.02

=cut

use 5.006;
use Data::Dumper;
use List::Util qw/min/;
use POSIX qw/floor/;
use Date::Calc qw/Delta_Days/;

use Moo::Role;
use namespace::clean;

my $SAKA_START  = 80;
my $SAKA_OFFSET = 78;

my $SAKA_MONTHS = [
    undef,
    'Chaitra', 'Vaisakha', 'Jyaistha',   'Asadha', 'Sravana', 'Bhadra',
    'Asvina',  'Kartika',  'Agrahayana', 'Pausa',  'Magha',   'Phalguna'
];

my $SAKA_DAYS = [
    '<yellow><bold>       Ravivara </bold></yellow>',
    '<yellow><bold>        Somvara </bold></yellow>',
    '<yellow><bold>    Mangalavara </bold></yellow>',
    '<yellow><bold>      Budhavara </bold></yellow>',
    '<yellow><bold> Brahaspativara </bold></yellow>',
    '<yellow><bold>      Sukravara </bold></yellow>',
    '<yellow><bold>       Sanivara </bold></yellow>',
];

has saka_days   => (is => 'ro', default => sub { $SAKA_DAYS   });
has saka_months => (is => 'ro', default => sub { $SAKA_MONTHS });
has saka_start  => (is => 'ro', default => sub { $SAKA_START  });
has saka_offset => (is => 'ro', default => sub { $SAKA_OFFSET });

with 'Date::Utils';

=head1 DESCRIPTION

Saka date specific routines as Moo Role.

=head1 METHODS

=head2 saka_to_gregorian($year, $month, $day)

=cut

sub saka_to_gregorian {
    my ($self, $year, $month, $day) = @_;

    return $self->julian_to_gregorian($self->saka_to_julian($year, $month, $day));
}

=head2 gregorian_to_sake($year, $month, $day)

=cut

sub gregorian_to_saka {
    my ($self, $year, $month, $day) = @_;

    return $self->julian_to_saka($self->gregorian_to_julian($year, $month, $day));
}

=head2 julian_to_saka()

=cut

sub julian_to_saka {
    my ($self, $julian) = @_;

    $julian     = floor($julian) + 0.5;
    my $year    = ($self->julian_to_gregorian($julian))[0];
    my $yday    = $julian - $self->gregorian_to_julian($year, 1, 1);
    my $chaitra = $self->days_in_chaitra($year);
    $year = $year - $self->saka_offset;

    if ($yday < $self->saka_start) {
        $year--;
        $yday += $chaitra + (31 * 5) + (30 * 3) + 10 + $self->saka_start;
    }
    $yday -= $self->saka_start;

    my ($day, $month);
    if ($yday < $chaitra) {
        $month = 1;
        $day   = $yday + 1;
    }
    else {
        my $mday = $yday - $chaitra;
        if ($mday < (31 * 5)) {
            $month = floor($mday / 31) + 2;
            $day   = ($mday % 31) + 1;
        }
        else {
            $mday -= 31 * 5;
            $month = floor($mday / 30) + 7;
            $day   = ($mday % 30) + 1;
        }
    }

    return ($year, $month, $day);
}

=head2 saka_to_julian($year, $month, $day)

=cut

sub saka_to_julian {
    my ($self, $year, $month, $day) = @_;

    my $gregorian_year = $year + 78;
    my $gregorian_day  = ($self->is_gregorian_leap_year($gregorian_year)) ? (21) : (22);
    my $start = $self->gregorian_to_julian($gregorian_year, 3, $gregorian_day);

    my ($julian);
    if ($month == 1) {
        $julian = $start + ($day - 1);
    }
    else {
        my $chaitra = ($self->is_gregorian_leap_year($gregorian_year)) ? (31) : (30);
        $julian = $start + $chaitra;
        my $_month = $month - 2;
        $_month = min($_month, 5);
        $julian += $_month * 31;

        if ($month >= 8) {
            $_month  = $month - 7;
            $julian += $_month * 30;
        }

        $julian += $day - 1;
    }

    return $julian;
}

=head2 days_in_chaitra($year)

=cut

sub days_in_chaitra {
    my ($self, $year) = @_;

    ($self->is_gregorian_leap_year($year)) ? (return 31) : (return 30);
}

=head2 days_in_saka_month_year($month, $year)

=cut

sub days_in_saka_month_year {
    my ($self, $month, $year) = @_;

    my @start = $self->saka_to_gregorian($year, $month, 1);
    if ($month == 12) {
        $year += 1;
        $month = 1;
    }
    else {
        $month += 1;
    }

    my @end = $self->saka_to_gregorian($year, $month, 1);

    return Delta_Days(@start, @end);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Date-Utils-Saka>

=head1 ACKNOWLEDGEMENTS

Entire logic is based on the L<code|http://www.fourmilab.ch/documents/calendar> written by John Walker.

=head1 BUGS

Please report any bugs / feature requests to C<bug-date-utils-saka at rt.cpan.org>
, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Utils-Saka>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Utils::Saka

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Utils-Saka>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Utils-Saka>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Utils-Saka>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Utils-Saka/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Date::Utils::Saka
