package Dist::WantXS;
use strict;
use warnings;
use utf8;
use parent qw/Exporter/;

our @EXPORT = qw/want_xs/;

my $want_xs;
sub want_xs {
    my($self, $default) = @_;
    return $want_xs if defined $want_xs;

    # you're using this module, you must want XS by default
    # unless PERL_ONLY is true.
    $default = !$ENV{PERL_ONLY} if not defined $default;

    foreach my $arg(@ARGV){
        if($arg eq '--pp'){
            return $want_xs = 0;
        }
        elsif($arg eq '--xs'){
            return $want_xs = 1;
        }
    }
    return $want_xs = $default;
}

1;
__END__

=head1 NAME

Dist::WantXS - user needs pp?

=head1 SYNOPSIS

    use Dist::WantXS;

    if (want_xs()) {
        ... # setup to compile
    } else {
        ... # setup to PP version
    }

=head1 DESCRIPTION

This module detects the user need to use pp version or not.

=head1 FUNCTIONS

=over 4

=item want_xs() : Bool

Returns true if the user asked for the XS version or pure perl version of the module.

Will return true if "--xs" is explicitly specified as the argument to Makefile.PL, and false if "--pp" is specified. If neither is explicitly specified, will
return the value specified by $default. If you do not specify the value of $default, then it will be true.

=back

=head1 AUTHORS

Goro Fuji(Original author of Module::Install::XSUtil)

Tokuhiro Matsuno(Port from Module::Install::XSUtil)

