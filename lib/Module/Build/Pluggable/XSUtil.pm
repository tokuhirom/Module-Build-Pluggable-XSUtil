package Module::Build::Pluggable::XSUtil;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';
use parent qw/Module::Build::Pluggable::Base/;
use Config;
use Carp ();

# -------------------------------------------------------------------------
# utility methods

sub _xs_debugging {
    my $self = shift;
    return $ENV{XS_DEBUG} || $self->builder->args('g');
}

# GNU C Compiler
sub _is_gcc {
    return $Config{gccversion};
}

# Microsoft Visual C++ Compiler (cl.exe)
sub _is_msvc {
    return $Config{cc} =~ /\A cl \b /xmsi;
}

sub _gcc_version {
    my $res = `$Config{cc} --version`;
    my ($version) = $res =~ /\(GCC\) ([0-9.]+)/;
    no warnings 'numeric', 'uninitialized';
    return sprintf '%g', $version;
}

# -------------------------------------------------------------------------
# hooks

sub HOOK_prepare {
    my ($self, $args) = @_;

    # add -g option
    Carp::confess("-g option is defined at other place.") if $args->{get_options}->{g};
    $args->{get_options}->{g} = { type => '!' };
}

sub HOOK_configure {
    my $self = shift;
    unless ($self->builder->have_c_compiler()) {
        warn "This distribution requires a C compiler, but it's not available, stopped.\n";
        exit -1;
    }

    # runtime deps
    $self->configure_requires('ExtUtils::ParseXS' => '2.21');
    $self->requires('XSLoader' => '0.02');

    # cleanup options
    if ($^O eq 'cygwin') {
        $self->bulder->add_to_cleanup('*.stackdump');
    }

    # debugging options
    if ($self->_xs_debugging()) {
        if ($self->_is_msvc()) {
            $self->add_extra_compiler_flags('-Zi');
        } else {
            $self->add_extra_compiler_flags(qw/-g -ggdb -g3/);
        }
        $self->add_extra_compiler_flags('-DXS_ASSERT');
    }

    # c++ options
    if ($self->{'c++'}) {
        $self->configure_requires('ExtUtils::CBuilder' => '0.28');

        require ExtUtils::CBuilder;
        my $cbuilder = ExtUtils::CBuilder->new(quiet => 1);
        $cbuilder->have_cpluplus or do {
            warn "This environment does not have a C++ compiler(OS unsupported)\n";
            exit 0;
        };
    }

    # c99 is required
    if ($self->{c99}) {
        $self->configure_requires('Devel::CheckCompiler' => '0.01');

        require Devel::CheckCompiler;
        Devel::CheckCompiler::check_c99_or_exit();
    }

    # write xshelper.h
    if (my $xshelper = $self->{xshelper}) {
        if ($xshelper eq '1') { # { xshelper => 1 }
            $xshelper = 'xshelper.h';
        }
        File::Path::mkpath(File::Basename::dirname($xshelper));
        require Devel::XSHelper;
        Devel::XSHelper::WriteFile($xshelper);

        # generate ppport.h to same directory automatically.
        unless (defined $self->{ppport}) {
            (my $ppport = $xshelper) =~ s!xshelper\.h$!ppport\.h!;
            $self->{ppport} = $ppport;
        }
    }

    # write ppport.h
    if (my $ppport = $self->{ppport}) {
        if ($ppport eq '1') { # { ppport => 1 }
            $ppport = 'ppport.h';
        }
        File::Path::mkpath(File::Basename::dirname($ppport));
        require Devel::PPPort;
        Devel::PPPort::WriteFile($ppport);
    }

    # cc_warnings => 1
    $self->add_extra_compiler_flags($self->_cc_warnings());
}

sub _cc_warnings {
    my $self = shift;

    my @flags;
    if($self->_is_gcc()){
        push @flags, qw(-Wall);

        my $gccversion = $self->_gcc_version();
        if($gccversion >= 4.0){
            push @flags, qw(-Wextra);
            if(!($self->{c99} or $self->{'c++'})) {
                # Note: MSVC++ doesn't support C99,
                # so -Wdeclaration-after-statement helps
                # ensure C89 specs.
                push @flags, qw(-Wdeclaration-after-statement);
            }
            if($gccversion >= 4.1 && !$self->{'c++'}) {
                push @flags, qw(-Wc++-compat);
            }
        }
        else{
            push @flags, qw(-W -Wno-comment);
        }
    }
    elsif ($self->_is_msvc()) {
        push @flags, qw(-W3);
    }
    else{
        # TODO: support other compilers
    }
    
    return @flags;
}

1;
__END__

=encoding utf8

=head1 NAME

Module::Build::Pluggable::XSUtil - Utility for XS

=head1 SYNOPSIS

    use Module::Build::Pluggable (
        'XSUtil' => {
            cc_warnings => 1,
            ppport      => 1,
            xshelper    => 1,
            'c++'       => 1,
            'c99'       => 1,
        },
    );

=head1 DESCRIPTION

Module::Build::Pluggable::XSUtil is a utility for xs library.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
