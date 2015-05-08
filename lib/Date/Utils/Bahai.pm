package Date::Utils::Bahai;

$Date::Utils::Bahai::VERSION = '0.02';

=head1 NAME

Date::Utils::Bahai - Bahai date specific routines as Moo Role.

=head1 VERSION

Version 0.02

=cut

use 5.006;
use Data::Dumper;
use POSIX qw/floor/;

use Moo::Role;
use namespace::clean;

our $BAHAI_MONTHS = [
    '',
    'Baha',    'Jalal', 'Jamal',  'Azamat', 'Nur',       'Rahmat',
    'Kalimat', 'Kamal', 'Asma',   'Izzat',  'Mashiyyat', 'Ilm',
    'Qudrat',  'Qawl',  'Masail', 'Sharaf', 'Sultan',    'Mulk',
    'Ala'
];

our $BAHAI_CYCLES = [
    '',
    'Alif', 'Ba',     'Ab',    'Dal',  'Bab',    'Vav',
    'Abad', 'Jad',    'Baha',  'Hubb', 'Bahhaj', 'Javab',
    'Ahad', 'Vahhab', 'Vidad', 'Badi', 'Bahi',   'Abha',
    'Vahid'
];

our $BAHAI_DAYS = [
    '<yellow><bold>    Jamal </bold></yellow>',
    '<yellow><bold>    Kamal </bold></yellow>',
    '<yellow><bold>    Fidal </bold></yellow>',
    '<yellow><bold>     Idal </bold></yellow>',
    '<yellow><bold> Istijlal </bold></yellow>',
    '<yellow><bold> Istiqlal </bold></yellow>',
    '<yellow><bold>    Jalal </bold></yellow>'
];

has bahai_epoch  => (is => 'ro', default => sub { 2394646.5     });
has bahai_days   => (is => 'ro', default => sub { $BAHAI_DAYS   });
has bahai_months => (is => 'ro', default => sub { $BAHAI_MONTHS });
has bahai_cycles => (is => 'ro', default => sub { $BAHAI_CYCLES });

with 'Date::Utils';

=head1 DESCRIPTION

Bahai date specific routines as Moo Role.

=head1 METHODS

=head2 bahai_to_gregorian($major, $cycle, $year, $month, $day)

Returns Gregorian  date  as list (year, month, day) equivalent of the given bahai
date.

=cut

sub bahai_to_gregorian {
    my ($self, $major, $cycle, $year, $month, $day) = @_;

    return $self->julian_to_gregorian($self->bahai_to_julian($major, $cycle, $year, $month, $day));
}

=head2 gregorian_to_bahai($year, $month, $day)

Returns Bahai date component as list (majaor, cycle, year, month, day) equivalent
of the given gregorian date.

=cut

sub gregorian_to_bahai {
    my ($self, $year, $month, $day) = @_;

    return $self->julian_to_bahai($self->gregorian_to_julian($year, $month, $day));
}

=head2 bahai_to_julian($major, $cycle, $year, $month, $day)

Returns julian date of the given bahai date.

=cut

sub bahai_to_julian {
    my ($self, $major, $cycle, $year, $month, $day) = @_;

    my ($g_year) = $self->julian_to_gregorian($self->bahai_epoch);
    my $gy     = (361 * ($major - 1)) +
                 (19  * ($cycle - 1)) +
                 ($year - 1) + $g_year;

    return $self->gregorian_to_julian($gy, 3, 20)
           +
           (19 * ($month - 1))
           +
           (($month != 20) ? 0 : ($self->is_gregorian_leap_year($gy + 1) ? -14 : -15))
           +
           $day;
}

=head2 julian_to_bahai($julian_date)

Returns Bahai date component as list (majaor, cycle, year, month, day) equivalent
of the given Julian date C<$julian_date>.

=cut

sub julian_to_bahai {
    my ($self, $julian_date) = @_;

    $julian_date = floor($julian_date) + 0.5;
    my $gregorian_year = ($self->julian_to_gregorian($julian_date))[0];
    my $start_year     = ($self->julian_to_gregorian($self->bahai_epoch))[0];

    my $j1 = $self->gregorian_to_julian($gregorian_year, 1, 1);
    my $j2 = $self->gregorian_to_julian($gregorian_year, 3, 20);

    my $bahai_year = $gregorian_year - ($start_year + ((($j1 <= $julian_date) && ($julian_date <= $j2)) ? 1 : 0));
    my ($major, $cycle, $year) = $self->get_major_cycle_year($bahai_year);

    my $days  = $julian_date - $self->bahai_to_julian($major, $cycle, $year, 1, 1);
    my $bld   = $self->bahai_to_julian($major, $cycle, $year, 20, 1);
    my $month = ($julian_date >= $bld) ? 20 : (floor($days / 19) + 1);
    my $day   = ($julian_date + 1) - $self->bahai_to_julian($major, $cycle, $year, $month, 1);

    return ($major, $cycle, $year, $month, $day);
}

=head2 get_major_cycle_year($bahai_year)

Returns the attribute as list major, cycle & year as in Kull-i-Shay) of the given
Bahai year C<$bahai_year>.

=cut

sub get_major_cycle_year {
    my ($self, $bahai_year) = @_;

    my $major = floor($bahai_year / 361) + 1;
    my $cycle = floor(($bahai_year % 361) / 19) + 1;
    my $year  = ($bahai_year % 19) + 1;

    return ($major, $cycle, $year);
}

=head2 validate_month($month)

Dies if the given C<$month> is not a valid Bahai month.

=cut

sub validate_month {
    my ($self, $month) = @_;

    die("ERROR: Invalid month [$month].\n")
        unless (defined($month) && ($month =~ /^\d{1,2}$/) && ($month >= 1) && ($month <= 19));
}

=head2 validate_day($day)

Dies if the given C<$day> is not a valid Bahai day.

=cut

sub validate_day {
    my ($self, $day) = @_;

    die ("ERROR: Invalid day [$day].\n")
        unless (defined($day) && ($day =~ /^\d{1,2}$/) && ($day >= 1) && ($day <= 19));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Date-Utils-Bahai>

=head1 ACKNOWLEDGEMENTS

Entire logic is based on the L<code|http://www.fourmilab.ch/documents/calendar> written by John Walker.

=head1 BUGS

Please report any bugs / feature requests to C<bug-date-utils-bahai at rt.cpan.org>
, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Utils-Bahai>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Utils::Bahai

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Utils-Bahai>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Utils-Bahai>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Utils-Bahai>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Utils-Bahai/>

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

1; # End of Date::Utils::Bahai
