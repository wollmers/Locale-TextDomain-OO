package Locale::Utils::Autotranslator; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use HTTP::Request::Common qw(GET);
use JSON qw(decode_json);
use LWP::UserAgent;
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(Bool CodeRef);
use URI;
use namespace::autoclean;

our $VERSION = '0.001';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
    Locale::TextDomain::OO::Lexicon::Role::ExtractHeader
);

# a .. w, z     => A-WZ
# A .. W, Z     => Ym
# space         => YX
# open, e.g. {  => XX
# :             => XY
# close, e.g. } => XZ
# other         => XAA .. XPP
#                  like hex but
#                  0123456789ABCDEF is
#                  ABCDEFGHIJKLMNOP

has plural => (
    is      => 'ro',
    default => sub { {} },
);

sub clear_plural {
    my $self = shift;

    %{ $self->plural } = ();
}

has num => (
    is      => 'ro',
    default => sub { {} },
);

sub clear_num {
    my $self = shift;

    %{ $self->num } = ();

    return;
}

my $encode_inner = sub {
    my ( $lc, $uc, $space, $colon, $other ) = @_;

    if ( defined $lc ) {
        return uc $lc;
    }
    if ( defined $uc ) {
        return q{Y} . $uc;
    }
    if ( defined $space ) {
        return 'YX';
    }
    if ( defined $colon ) {
        return 'XY';
    }

    $other = ord $other;
    $other > 255
        and confess 'encode error Xnn overflow';
    my $digit2 = int $other / 16;
    my $digit1 = $other % 16;
    for my $digit ( $digit2, $digit1 ) {
        $digit = [ q{A} .. q{P} ]->[$digit];
    }

    return q{X} . $digit2 . $digit1;
};

my $encode_az = sub {
    my $inner = shift;

    $inner =~ s{
        ( [a-wz] )
        | ( [A-WZ] )
        | ( [ ] )
        | ( [:] )
        | ( . )
    }
    {
        $encode_inner->($1, $2, $3, $4, $5, $6)
    }xmsge;

    return 'XX'. $inner . 'XZ';
};

sub encode_named {
    my ( $self, $placeholder ) = @_;

    $placeholder =~ s{
        ( \\ \{ )
        | \{ ( [^\}]* ) \}
    }
    {
        $1
        || $encode_az->($2)
    }xmsge;

    return $placeholder;
}

my $decode_inner = sub {
    my $inner = shift;

    my @chars = $inner =~ m{ (.) }xmsg;
    my $decoded = q{};
    CHAR:
    while ( @chars ) {
        my $char = shift @chars;
        if ( $char =~ m{ \A [A-WZ] \z }xms ) {
            $decoded .= lc $char;
            next CHAR;
        }
        if ( $char eq q{Y} ) {
            @chars
                or confess 'decode error Y';
            my $char2 = shift @chars;
            $decoded .= $char2 eq q{X}
                ? q{ }
                : uc $char2;
            next CHAR;
        }
        if ( $char eq q{X} ) {
            @chars
                or confess 'decode error Xn';
            my $char2 = shift @chars;
            if ( $char2 eq q{Y} ) {
                $decoded .= q{:};
                next CHAR;
            }
            @chars
                or confess 'decode error Xnn';
            my $char3 = shift @chars;
            my $decode_string = 'ABCDEFGHIJKLMNOP';
            my $index2 = index $decode_string, $char2;
            $index2 == -1
                and confess 'decode error X?';
            my $index1 = index $decode_string, $char3;
            $index1 == -1
                and confess 'decode error Xn?';
            $decoded .= chr $index2 * 16 + $index1;
            next CHAR;
        }
        confess 'decode error';
    }

    return $decoded;
};

sub decode_named {
    my ( $self, $placeholder ) = @_;

    $placeholder =~ s{
        XX
        ( [ A-Z ]+ )
        XZ
    }
    {
        q[{] . $decode_inner->($1) . q[}]
    }xmsge;

    return $placeholder;
}

sub translate {
    my ( $self, $name_read, $name_write ) = @_;

    defined $name_read
        or confess 'Undef is not a name of a lexicon';
    my $lexicon = DBD::PO::Locale::PO->load_file_ashash($name_read);
    my $header = $self->extract_header_msgstr( $lexicon->{ q{} }->msgstr );
    my $nplurals    = $header->{nplurals};
    my $plural_code = $header->{plural_code};
    $self->clear_plural;
    MESSAGE_KEY:
    for my $message_key ( keys %{$lexicon} ) {
        length $message_key
            or next MESSAGE_KEY;
        my $po = $lexicon->{$message_key};
        my $msgid        = $po->msgid;
        my $msgid_plural = $po->msgid_plural;
        defined $po->msgstr
            and length $po->msgstr
            and next MESSAGE_KEY;
        $po->msgstr_n
            and defined $po->msgstr_n->{0}
            and length $po->msgstr_n->{0}
            and next MESSAGE_KEY;
        if ( length $msgid_plural ) {
            if ( $nplurals ) {
                NUMBER:
                for ( 0 .. 1000 ) {
                    my $plural = $plural_code->($_);
                    if ( ! exists $self->plural->{$plural} ) {
                        $self->plural->{$plural} = $_;
                    }
                    $nplurals == ( keys %{ $self->plural } )
                        and last NUMBER;
                }
            }
            $self->translate_gettext_plural($po);
            next MESSAGE_KEY;
        }
        if ( $po->msgid =~ m{ \{ [^\{\}]+ \} }xms ) {
            $self->translate_gettext($po);
            next MESSAGE_KEY;
        }
        if ( $po->msgid =~ m{ [%] (?: \d | [*] | quant ) }xms ) {
            $self->translate_maketext($po);
            next MESSAGE_KEY;
        }
        $self->translate_simple($po);
    }
    DBD::PO::Locale::PO->save_file_fromhash($name_write, $lexicon);

    return;
}

sub encode_gettext {
    my ( $self, $msgid, $num ) = @_;

    $num = defined $num ? $num : 1;
    $self->clear_num;
    my $encode_placeholder = sub {
        my ( $placeholder, $is_num ) = @_;
        if ( $is_num ) {
            $self->num->{$num} = $placeholder;
            return $num++;
        }
        return $self->encode_named($placeholder);
    };
    $msgid =~ s{
        ( \\ \{ )
        | (
            \{
            [^\{\}:]+
            ( [:] ( num )? [^\{\}]* )?
            \}
        )
    }
    {
        $1
        || $encode_placeholder->($2, $3)
    }xmsge;

    return $msgid;
}

sub decode_gettext {
    my ( $self, $msgstr ) = @_;

    $msgstr =~ s{ ( \d+ ) }{ $self->num->{$1} }xmsge;
    $msgstr = $self->decode_named($msgstr);

    return $msgstr;
}

sub translate_gettext {
    my ( $self, $po ) = @_;

    my $msgid = $self->encode_gettext( $po->msgid );
    my $msgstr = $self->translate_with_api($msgid);
    $msgstr = $self->decode_gettext($msgstr);
    $po->msgstr($msgstr);

    return;
}

sub translate_gettext_plural {
    my ( $self, $po ) = @_;

    my $msgid        = $po->msgid;
    my $msgid_plural = $po->msgid_plural;
    my @msgstr = map {
        my $number_for_plural_form = $self->plural->{$_};
        my $any_msgid = $self->encode_gettext(
            $number_for_plural_form == 1 ? $msgid : $msgid_plural,
            $number_for_plural_form,
        );
        my $any_msgstr = $self->translate_with_api($any_msgid);
        $any_msgstr = $self->decode_gettext($any_msgstr);
    } sort keys %{ $self->plural };
    my $index = 0;
    for my $msgstr (@msgstr) {
       $po->msgstr_n->{$index++} = $msgstr;
    }

    return;
}

sub encode_maketext_inner {
    my ( $self, $quant, $number, $singular, $plural, $zero ) = @_;

    $self->plural->{$number} = [
        $quant,
        map {
            ( defined $_ && length $_ )
            ? $self->translate_with_api($_)
            : undef;
        } $singular, $plural, $zero
    ];

    return $encode_az->("*$number");
}

sub encode_maketext {
    my ( $self, $msgid ) = @_;

    $msgid =~ s{
        ( %% )                    # escaped
        |
        [%] ( [*] | quant )       # quant
        [(]
            [%] ( \d+ )           # number
            [,] ( [^,)]* )        # singular
            [,] ( [^,)]* )        # plural
            (?: [,] ( [^,)]* ) )? # zero
        [)]
        |
        [%] ( \d+ )               # simple
    }
    {
        $1
        ? $1
        : $2
        ? $self->encode_maketext_inner($2, $3, $4, $5, $6)
        : $encode_az->($7)
    }xmsge;

    return $msgid;
}

sub decode_maketext_inner {
    my ( $self, $inner ) = @_;

    $inner = $decode_inner->($inner);
    if ( $inner =~ m{ \A ( \d+ ) \z }xms ) {
        return q{%} . $1;
    }
    if ( $inner =~ m{ \A [*] ( \d+ ) \z }xms ) {
        my $plural = $self->plural->{$1};
        return join q{},
            q{%},
            $plural->[0],
            q{(},
            ( join q{,}, "%$1", grep { defined } @{$plural}[ 1 .. 3 ] ),
            q{)};
    }

    confess "decode error maketext inner $inner";
}

sub decode_maketext {
    my ( $self, $msgstr ) = @_;

    $msgstr =~ s{
        XX
        ( [ A-Z ]+ )
        XZ
    }
    {
        $self->decode_maketext_inner($1)
    }xmsge;

    return $msgstr;
}

sub translate_maketext {
    my ( $self, $po ) = @_;

    $self->clear_plural;
    my $msgid = $self->encode_maketext( $po->msgid );
    my $msgstr = $self->translate_with_api($msgid);
    $msgstr = $self->decode_maketext($msgstr);
    $po->msgstr($msgstr);

    return;
}

sub translate_simple {
    my ( $self, $po ) = @_;

    $po->msgstr(
        $self->translate_with_api( $po->msgid ),
    );

    return;
}

sub translate_with_api {
    my ( $self, $msgid ) = @_;

    $ENV{TRANSLATE}
        or return $msgid;
    my $uri = URI->new('http://api.mymemory.translated.net/get');
    $uri->query_form(
        q        => $msgid,
        langpair => 'de|en',
    );
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request(
        GET
            $uri->as_string,
            'User-Agent'      => 'Mozilla/5.0 (Windows NT 5.1; rv:26.0) Gecko/20100101 Firefox/26.0',
            'Accept'          => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'de-de,en-us;q=0.7,en;q=0.3',
            'Accept-Encoding' => 'gzip, deflate',
            'DNT'             => 1,
            'Connection'      => 'keep-alive',
            'Cache-Control'   => 'max-age=0',
    );
    $response->is_success
        or confess $response->status_line;
    my $json = decode_json( $response->decoded_content );
    $json->{responseStatus} eq '200'
        or confess $json->{responseDetails};

    return $json->{responseData}->{translatedText};
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::Utils::PlaceholderNamed - Utils to expand named placeholders

$Id: PlaceholderNamed.pm 474 2014-01-24 11:51:14Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/Locale-Utils-PlaceholderNamed/trunk/lib/Locale/Utils/PlaceholderNamed.pm $

=head1 VERSION

0.001

=head1 SYNOPSIS

    use Locale::Utils::PlaceholderNamed;

    my $obj = Locale::Utils::PlaceholderNamed->new(
        # optional strict switch
        strict => 1,
        # optional modifier code
        modifier_code => sub {
            my ( $value, $attribute ) = @_;
            return
                $attribute eq '%.3f'
                ? sprintf($attribute, $value)
                : $attribute eq 'accusative'
                ? accusative($value)
                : $value;
        },
    );

    $expanded = $obj->expand_named($text, %args);
    $expanded = $obj->expand_named($text, \%args);

=head1 DESCRIPTION

Utils to expand named placeholders.

=head1 SUBROUTINES/METHODS

=head2 method strict

If strict is false: undef will be converted to q{}.
If strict is true: no replacement.

    $obj->strict(1); # boolean true or false;

=head2 method modifier_code, clear_modifier_code

The modifier code handles named attributes
to modify the given placeholder value.

If the placeholder name is C<{foo:bar}> then foo is the placeholder name
and bar the attribute name.
Space in front of the attribute name is allowed, e.g. C<{foo :bar}>.

    my $code_ref = sub {
        my ( $value, $attribute ) = @_;
        return
            $attribute eq 'num.03'
            ? sprintf('%.03f, $value)
            : $attribute eq 'accusative'
            ? accusative($value)
            : $value;
    };
    $obj->modifier_code($code_ref);

To switch off this code - clear them.

    $obj->clear_modifier_code;

=head2 method expand_named

Expands strings containing named placeholders like C<{name}>.

    $text = 'foo {name} baz';
    %args = (
        name => 'bar',
    );

    $expanded = $obj->expand_named($text, %args);

or

    $expanded = $obj->expand_text($text, \%args);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Carp|Carp>

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike|MooX::Types::MooseLike>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Gettext>

L<Locale::TextDomain|Locale::TextDomain>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
