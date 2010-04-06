package Locale::TextDomain::OO::RegexExtractor;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Clone qw(clone); # clones not recursive

sub new {
    my ($class, %init) = @_;

    my $self = bless {}, $class;

    # prepare the file and the encoding
    if ( ref $init{preprocess_code} eq 'CODE' ) {
        $self->_set_preprocess_code( delete $init{preprocess_code} );
    }

    # how to find such lines
    if ( defined $init{start_rule} ) {
        $self->_set_start_rule( delete $init{start_rule} );
    }

    # how to find the parameters
    if ( ref $init{rules} eq 'ARRAY' ) {
        $self->_set_rules( delete $init{rules} );
    }

    # debug output for other rules than perl
    $self->_set_run_debug( delete $init{run_debug} );

    # how to map the parameters to pot file
    if ( ref $init{parameter_mapping_code} eq 'CODE' ) {
        $self->_set_parameter_mapping_code(
            delete $init{parameter_mapping_code},
        );
    }

    # how write data
    if ( exists $init{store_code} ) {
        $self->_set_store_code( delete $init{store_code} );
    }

    # error
    my $keys = join ', ', keys %init;
    if ($keys) {
        croak "Unknown parameter: $keys";
    }

    return $self;
}

my @names = qw(
    preprocess_code start_rule rules run_debug parameter_mapping_code
    store_code
    content_ref stack
);

for my $name (@names) {
    no strict qw(refs);       ## no critic (NoStrict)
    no warnings qw(redefine); ## no critic (NoWarnings)

    *{"_set_$name"} = sub {
        my ($self, $data) = @_;

        $self->{$name} = $data;

        return $self;
    };
    *{"_get_$name"} = sub {
        return shift->{$name};
    };
}

sub debug {
    my ($self, $message) = @_;

    defined $message
        or return $self->debug('undef');
    () = print {*STDERR} "\n# $message";

    return $self;
}

my %debug_switch_of = (
    ':all' => ~ 0,
    parser => 2 ** 0,
    data   => 2 ** 1,
    file   => 2 ** 2,
);

sub _debug {
    my ($self, $group, @messages) = @_;

    my $run_debug = $self->_get_run_debug()
        or return $self;
    my $debug = 0;
    DEBUG: for ( split m{\s+}xms, $run_debug ) {
        my $switch = $_;
        my $is_not = $switch =~ s{\A !}{}xms;
        if ( exists $debug_switch_of{$switch} ) {
            if ($is_not) {
                $debug &= ~ $debug_switch_of{$switch};
            }
            else {
                $debug |= $debug_switch_of{$switch};
            }
        }
        else {
            croak "Unknwon debug switch $_";
        }
    }
    $debug & $debug_switch_of{$group}
        or return $self;

    for my $line ( map { split m{\n}xms, $_ } @messages ) {
        $self->debug($line);
    }

    return $self;
}

sub _parse_pos {
    my $self = shift;

    my $regex       = $self->_get_start_rule();
    my $content_ref = $self->_get_content_ref();
    defined ${$content_ref}
        or return $self;
    my @stack;
    while ( ${$content_ref} =~ m{\G .*? ($regex)}xmsgc ) {
        push @stack, {
            start_pos => pos( ${$content_ref} ) - length $1,
        };
    }
    $self->_set_stack(\@stack);

    return $self;
}

sub _parse_rules {
    my $self = shift;

    my $content_ref = $self->_get_content_ref();
    for my $stack_item ( @{ $self->_get_stack() } ) {
        my $rules       = clone $self->_get_rules();
        my $pos         = $stack_item->{start_pos};
        my $has_matched = 0;
        $self->_debug('parser', "Starting at pos $pos.");
        my (@parent_rules, @parent_pos);
        RULE: {
            my $rule = shift @{$rules};
            if (! $rule) {
                $self->_debug('parser', 'No more rules found.');
                if (@parent_rules) {
                    $rules = pop @parent_rules;
                    ()     = pop @parent_pos;
                    $self->_debug('parser', 'Going back to parent.');
                    redo RULE;
                }
                last RULE;
            }
            # goto child
            if ( ref $rule eq 'ARRAY' ) {
                push @parent_rules, $rules;
                push @parent_pos,   $pos;
                $rules = clone $rule;
                $self->_debug('parser', 'Going to child.');
                redo RULE;
            }
            # alternative
            if ( lc $rule eq 'or' ) {
                if ( $has_matched ) {
                    $rules       = pop @parent_rules;
                    ()           = pop @parent_pos;
                    $has_matched = 0;
                    $self->_debug('parser', 'Ignore alternative.');
                    redo RULE;
                }
                $self->_debug('parser', 'Try alternative.');
                redo RULE;
            }
            pos ${ $content_ref } = $pos;
            $self->_debug('parser', "Set the current pos to $pos.");
            $has_matched
                = my ($match, @result)
                = ${$content_ref} =~ m{\G ($rule)}xms;
            if ($has_matched) {
                push @{ $stack_item->{parameter} }, @result;
                $pos += length $match;
                $self->_debug(
                    'parser',
                    qq{Rule $rule has matched:},
                    ( split m{\n}xms, $match ),
                    "The current pos is $pos.",
                );
                redo RULE;
            }
            $rules = pop @parent_rules;
            $pos   = pop @parent_pos;
            $self->_debug(
                'parser',
                "Rule $rule has not matched.",
                'Going back to parent.',
            );
            redo RULE;
        }
    }

    return $self;
}

sub _cleanup {
    my $self = shift;

    my $stack = $self->_get_stack();
    my $index = 0;
    @{$stack} = grep {
        exists $_->{parameter}
    } @{$stack};

    return $self;
}

sub _calculate_reference {
    my $self = shift;

    my $content_ref = $self->_get_content_ref();
    for my $stack_item ( @{ $self->_get_stack() } ) {
        my $pre_match = substr ${$content_ref}, 0, $stack_item->{start_pos};
        my $newline_count = $pre_match =~ tr{\n}{\n};
        $stack_item->{line_number} = $newline_count + 1;
    }

    return $self;
}

sub _calculate_data {
    my ($self, $file_name) = @_;

    if ( $self->_get_run_debug() ) {
        require Data::Dumper;
        $self->_debug(
            'data',
            Data::Dumper
                ->new([$self->_get_stack()], [qw(parameters)])
                ->Sortkeys(1)
                ->Dump()
        );
    }
    my $parameter_mapping_code = $self->_get_parameter_mapping_code();
    STACK_ITEM:
    for my $stack_item ( @{ $self->_get_stack() } ) {
        my $parameter = $parameter_mapping_code->(
            delete $stack_item->{parameter},
        ) or next STACK_ITEM;
        $stack_item->{pot_data} = {(
            reference => "$file_name:$stack_item->{line_number}",
            %{$parameter},
        )};
    }

    return $self;
}

sub extract {
    my ($self, $arg_ref) = @_;

    my $file_name        = $arg_ref->{file_name};
    defined $file_name
        or croak 'No file name given';
    my $source_file_name = $arg_ref->{source_file_name} || $file_name;
    my $file_handle      = $arg_ref->{file_handle};

    if (! ref $file_handle) {
        open $file_handle, '<', $source_file_name ## no critic (BriefOpen)
            or croak "Can not open file $source_file_name\n$OS_ERROR";
    }

    local $INPUT_RECORD_SEPARATOR = ();
    $self->_set_content_ref(\<$file_handle>);
    () = close $file_handle;

    if ( $self->_get_preprocess_code() ) {
        $self->_get_preprocess_code()->( $self->_get_content_ref() );
    }
    $self->_parse_pos();
    $self->_parse_rules();
    $self->_cleanup();
    $self->_calculate_reference();
    $self->_calculate_data($source_file_name);
    $self->store_data($file_name);

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::RegexExtractor - Extracts data using regex

$Id: Extract.pm 271 2010-01-16 07:37:06Z steffenw $

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract.pm $

=head1 VERSION

0.01

=head1 DESCRIPTION

This module extracts internationalizations data and stores this in a pot file.

=head1 SYNOPSIS

    use Locale::TextDomain::OO::RegexExtractor;

=head1 SUBROUTINES/METHODS

=head2 method init

This method is for initializing DBD::PO.
How to initialize, see L<DBD::PO>.
Normally you have not to do this, because the defult is:

    BEGIN {
        Locale::TextDomain::OO::Extract->init( qw(:plural) );
    }

=head2 method new

All parameters are optional.

    my $extractor = Locale::TextDomain::OO::Extract->new(
        # prepare the file and the encoding
        preprocess_code => sub {
            my $content_ref = shift;

            ...

            return;
        },

        # how to find such lines
        start_rule => qr{__ n?p?x? \(}xms

        # how to find the parameters
        rules => [
            [
                # __( 'text'
                # __x( 'text'
                qr{__ (x?) \s* \( \s*}xms,
                qr{\s*}xms,
                # You can re-use the next reference.
                # It is a subdefinition.
                [
                    qr{'}xms,
                    qr{( (?: \\\\ \\\\ | \\\\ ' | [^'] )+ )}xms,
                    qr{'}xms,
                ],
            ],
            # The next array reference describes an alternative
            # and not a subdefinition.
            'OR',
            [
                # next alternative e.g.
                # __n( 'context' , 'text'
                # __nx( 'context' , 'text'
                ...
            ],
        ],

        # debug output for other rules than perl
        run_debug => ':all !parser', # debug all but not the parser
                     # :all    - switch on all debugs
                     # parser  - switch on parser debug
                     # data    - switch on data debug
                     # file    - switch on file debug
                     # !parser - switch off parser debug
                     # !data   - switch off data debug
                     # !file   - switch off file debug

        # how to map the parameters to pot file
        parameter_mapping_code => sub {
            my $parameter = shift;

            # The chars after __ were stored to make a decision now.
            my $context_parameter = shift @{$parameter};

            return {
                msgctxt      => $context_parameter =~ m{p}xms
                                ? $context_parameter
                                : undef,
                msgid        => scalar shift @{$parameter},
                msgid_plural => scalar shift @{$parameter},
            };
        },

        # where to store the pot file
        pot_dir => './',

        # how to store the pot file
        # - The meaning of undef is ISO-8859-1 but use not Perl unicode.
        # - Set 'ISO-8859-1' to have a ISO-8859-1 pot file and use Perl unicode.
        # - Set 'UTF-8' to have a UTF-8 pot file and use Perl unicode.
        # And so on.
        pot_charset => undef,

        # add some key value pairs to the header
        # more see documentation of DBD::PO
        pot_header => { ... },

        # how to write the pot file
        is_append => $boolean,

        # write your own code to store pot file
        store_pot_code => sub {
            my $attr_ref = shift;

            my $pot_dir     = $sttr_ref->{pot_dir};     # undef or string
            my $pot_charset = $sttr_ref->{pot_charset}; # undef or string
            my $is_append   = $sttr_ref->{is_append};   # boolean
            my $pot_header  = $sttr_ref->{pot_header};  # hashref
            my $stack       = $sttr_ref->{stack};       # arrayref
            my $file_name   = $sttr_ref->{file_name};   # undef or string

            ...
        },
    );

=head2 method extract

The default pot_dir is "./".

Call

    $extractor->extract('dir/filename.pl');

to extract "dir/filename.pl" to have a "$pot_dir/dir/filename.pl.pot".

Call

    open my $file_handle, '<', 'dir/filename.pl'
        or croak "Can no open file dir/filename.pl\n$OS_ERROR";
    $extractor->extract('filename', $file_handle);

to extract "dir/filename.pl" to have a "$pot_dir/filename.pot".

=head2 method debug

Switch on the debug to see on STDERR how the rules are handled.
Inherit of this class and write your own debug method if needed.

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters at method new.

 Unknown parameter: ...

Undef is not a filename.

 No file name given

There is a problem in opening the file to extract.

 Can not open file ...

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

version

Carp

English

Clone

DBI

DBD::PO

=head2 dynamic require

L<Data::Dumper>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2010,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut