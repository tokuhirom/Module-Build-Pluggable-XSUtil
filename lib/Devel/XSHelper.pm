package Devel::XSHelper;
use strict;
use warnings;
use utf8;

our $VERSION = '1.01';

sub WriteFile {
    my $path = shift || 'xshelper.h';
    open my $fh, '>', $path
        or return 0;
    print {$fh} _xshelper_h();
    close $fh;
    return 1;
}

sub _xshelper_h {
    my $h = <<'XSHELPER_H';
:/* THIS FILE IS AUTOMATICALLY GENERATED BY Devel::XSHelper $VERSION. */
:/*
:=head1 NAME
:
:xshelper.h - Helper C header file for XS modules
:
:=head1 DESCRIPTION
:
:    // This includes all the perl header files and ppport.h
:    #include "xshelper.h"
:
:=head1 SEE ALSO
:
:L<Module::Install::XSUtil>, where this file is distributed as a part of
:
:=head1 AUTHOR
:
:Fuji, Goro (gfx) E<lt>gfuji at cpan.orgE<gt>
:
:=head1 LISENCE
:
:Copyright (c) 2010, Fuji, Goro (gfx). All rights reserved.
:
:This library is free software; you can redistribute it and/or modify
:it under the same terms as Perl itself.
:
:=cut
:*/
:
:#ifdef __cplusplus
:extern "C" {
:#endif
:
:#define PERL_NO_GET_CONTEXT /* we want efficiency */
:#include <EXTERN.h>
:#include <perl.h>
:#define NO_XSLOCKS /* for exceptions */
:#include <XSUB.h>
:
:#ifdef __cplusplus
:} /* extern "C" */
:#endif
:
:#include "ppport.h"
:
:/* portability stuff not supported by ppport.h yet */
:
:#ifndef STATIC_INLINE /* from 5.13.4 */
:# if defined(__GNUC__) || defined(__cplusplus) || (defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901L))
:#   define STATIC_INLINE static inline
:# else
:#   define STATIC_INLINE static
:# endif
:#endif /* STATIC_INLINE */
:
:#ifndef __attribute__format__
:#define __attribute__format__(a,b,c) /* nothing */
:#endif
:
:#ifndef LIKELY /* they are just a compiler's hint */
:#define LIKELY(x)   (!!(x))
:#define UNLIKELY(x) (!!(x))
:#endif
:
:#ifndef newSVpvs_share
:#define newSVpvs_share(s) Perl_newSVpvn_share(aTHX_ STR_WITH_LEN(s), 0U)
:#endif
:
:#ifndef get_cvs
:#define get_cvs(name, flags) get_cv(name, flags)
:#endif
:
:#ifndef GvNAME_get
:#define GvNAME_get GvNAME
:#endif
:#ifndef GvNAMELEN_get
:#define GvNAMELEN_get GvNAMELEN
:#endif
:
:#ifndef CvGV_set
:#define CvGV_set(cv, gv) (CvGV(cv) = (gv))
:#endif
:
:/* general utility */
:
:#if PERL_BCDVERSION >= 0x5008005
:#define LooksLikeNumber(x) looks_like_number(x)
:#else
:#define LooksLikeNumber(x) (SvPOKp(x) ? looks_like_number(x) : (I32)SvNIOKp(x))
:#endif
:
:#define newAV_mortal()         (AV*)sv_2mortal((SV*)newAV())
:#define newHV_mortal()         (HV*)sv_2mortal((SV*)newHV())
:#define newRV_inc_mortal(sv)   sv_2mortal(newRV_inc(sv))
:#define newRV_noinc_mortal(sv) sv_2mortal(newRV_noinc(sv))
:
:#define DECL_BOOT(name) EXTERN_C XS(CAT2(boot_, name))
:#define CALL_BOOT(name) STMT_START {            \
:        PUSHMARK(SP);                           \
:        CALL_FPTR(CAT2(boot_, name))(aTHX_ cv); \
:    } STMT_END
XSHELPER_H
    $h =~ s/^://xmsg;
    $h =~ s/\$VERSION\b/$Devel::XSHelper::VERSION/xms;
    return $h;
}

1;
__END__

=head1 NAME

Devel::XSHelper - xshelper.h

=head1 SYNOPSIS

    use Devel::XSHelper;
    Devel::XSHelper::WriteFile('xshelper.h');

=head1 DESCRIPTION

This module writes xshelper.h. xshelper.h is a utility header for xs.
It's written by gfx.

=head1 FUNCTIONS

=over 4

=item WriteFile

"WriteFile" takes one optional argument. When called with one argument, it expects to be passed a filename. When called with no
arguments, it defaults to the filename xsutil.h.

The function returns a true value if the file was written successfully.  Otherwise it returns a false value.

=back

=head1 AUTHOR

Goro Fuji

Tokuhiro Matsuno

