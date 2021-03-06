package Locale::TextDomain::OO::RegexBasedExtractor;

use strict;
use warnings;

use version; our $VERSION = qv('1.00');

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);
use Clone qw(clone); # clones not recursive

sub new {
    my ($class, %init) = @_;

    my $self = bless {}, $class;

    # how to find such lines
    if ( defined $init{start_rule} ) {
        $self->_set_start_rule( delete $init{start_rule} );
    }

    # how to match
    if ( ref $init{rules} eq 'ARRAY' ) {
        $self->_set_rules( delete $init{rules} );
    }

    # debug output for other rules than perl
    $self->_set_run_debug( delete $init{run_debug} );

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
    start_rule rules run_debug
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
    *{"get_$name"} = sub {
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
    stack  => 2 ** 1,
    file   => 2 ** 2,
);

sub _debug {
    my ($self, $group, @messages) = @_;

    my $run_debug = $self->get_run_debug()
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

    my $regex       = $self->get_start_rule();
    my $content_ref = $self->get_content_ref();
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

    my $content_ref = $self->get_content_ref();
    for my $stack_item ( @{ $self->get_stack() } ) {
        my $rules       = clone $self->get_rules();
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
                push @{ $stack_item->{match} }, @result;
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

sub _cleanup_and_calculate_reference {
    my ($self, $source_filename) = @_;

    my $stack       = $self->get_stack();
    my $content_ref = $self->get_content_ref();
    @{$stack} = map {
        exists $_->{match}
        ? do {
            # calculate reference
            my $pre_match = substr ${$content_ref}, 0, $_->{start_pos};
            my $newline_count = $pre_match =~ tr{\n}{\n};
            $_->{source_filename} = $source_filename;
            $_->{line_number}     = $newline_count + 1;
            $_;
        }
        # cleanup
        : ();
    } @{$stack};

    return $self;
}

sub _calculate_stack {
    my $self = shift;

    if ( $self->get_run_debug() ) {
        require Data::Dumper;
        $self->_debug(
            'stack',
            Data::Dumper
                ->new([$self->get_stack()], [qw(stack)])
                ->Sortkeys(1)
                ->Dump()
        );
    }
    my $stack = $self->get_stack();
    @{$stack} = map {
        $self->stack_item_mapping($_);
    } @{$stack};

    return $self;
}

sub extract {
    my ($self, $arg_ref) = @_;

    my $source_filename = $arg_ref->{source_filename}
        or croak 'No source_filename given';
    my $destination_filename = $arg_ref->{destination_filename}
        or croak 'No destination_filename given';
    my $source_filehandle = $arg_ref->{source_filehandle};

    if (! ref $source_filehandle) {
        open $source_filehandle, '<', $source_filename ## no critic (BriefOpen)
            or croak "Can not open file $source_filename\n$OS_ERROR";
    }

    local $INPUT_RECORD_SEPARATOR = ();
    $self->_set_content_ref(\<$source_filehandle>);
    () = close $source_filehandle;

    if ( $self->can('preprocess') ) {
        $self->preprocess();
    }
    $self->_parse_pos();
    $self->_parse_rules();
    $self->_cleanup_and_calculate_reference($source_filename);
    $self->_calculate_stack();
    $self->store_data($destination_filename);

    return $self;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::RegexBasedExtractor - Abstract class to extract data using regexes

$Id$

$HeadURL: https://perl-gettext-oo.svn.sourceforge.net/svnroot/perl-gettext-oo/module/trunk/lib/Locale/TextDomain/OO/Extract.pm $

=head1 VERSION

1.00

=head1 DESCRIPTION

This module extracts data using regexes to store anywhere.

=head1 SYNOPSIS

    use parent qw(Locale::TextDomain::OO::RegexBasedExtractor);

    # Optional method
    # to uncomment or interpolate the file content or anything else.
    sub preprocess {
        my $self = shift;

        my $content_ref = $self->get_content_ref();
        # modify anyhow
        ${$content_ref}=~ s{\\n}{\n}xmsg;

        return $self;
    }

    # How to map the stack_item e.g. to a po entry:
    # Return an empty list to ignore a stack item.
    sub stack_item_mapping {
        my ($self, $stack_item) = @_;

        my $match = $stack_item->{match};
        # The chars after __ were stored to make a decision now.
        my $extra_parameter = shift @{$match};
        @{$match}
            or return;

        return {
            reference    => "$stack_item->{source_filename}:$stack_item->{line_number}",
            msgctxt      => $extra_parameter =~ m{p}xms
                            ? shift @{$match}
                            : undef,
            msgid        => scalar shift @{$match},
            msgid_plural => scalar shift @{$match},
        };
    }

    sub store_data {
        my ($self, $destination_filename) = @_;

        my $stack = $self->get_stack();
        ...

        return $self;
    }

    my $extractor = Locale::TextDomain::OO::RegexBasedExtractor->new(
        start_rule => qr{...}xms,
        rules      => [
            ...
        ],
    );

    # Scan file $source_filename.
    # Call method store_data with $destination_filename.
    # The reference is $source_filename.
    $extractor->extract({
        source_filename      => 'dir/source.pl',
        destination_filename => 'dir/destination_filename.pot',
    });

    # or
    # Scan file from open $filehandle.
    # Call method store_date with $destination_filename.
    # The reference is $source_filename.
    $extractor->extract({
        source_filename      => 'source.pl',
        source_filehande     => $source_filehandle,
        destination_filename => 'dir/destination_filename.pot',
    });

=head1 SUBROUTINES/METHODS

=head2 method new

All parameters are optional.

    my $extractor = Locale::TextDomain::OO::RegexBasedExtractor->new(
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
                     # stack   - switch on stack debug
                     # file    - switch on file debug
                     # !parser - switch off parser debug
                     # !stack  - switch off stack debug
                     # !file   - switch off file debug
    );

=head2 method extract

Call

    $extractor->extract({
        source_filename      => 'dir1/filename1.pl',
        destination_filename => 'dir2/filename2.pot',
    });

to extract "dir1/filename1.pl" to "dir2/filename2.pot".
The reference is "dir1/filename1.pl".

Call

    open my $filehandle, '<', 'dir1/filename1.pl'
        or croak "Can no open file dir1/filename1.pl\n$OS_ERROR";
    $extractor->extract({
        source_filename      => 'filename1',
        source_filehandle    => $filehandle,
        destination_filename => 'dir2/filename2.pot',
    });

to extract "dir1/filename1.pl" to "dir2/filename2.pot".
The reference is "filename1".

=head2 method debug

Switch on the debug to see on STDERR how the rules are handled.
Inherit of this class and write your own debug method if needed.

=head2 method store_date

This method is not inside of this package.
Example code see SYNOPSIS.

Use the following methods to get data from the object.

=head2 method get_content_ref

Get access to the content of the scanned file.

    $scalar_ref = $extractor->get_content_ref();

=head2 method get_stack

Get access to the parsed result.

    $array_ref = $extractor->get_stack();

=head2 method get_start_rule (normally not used)

    $regex = $extractor->get_start_rule();

=head2 method get_rules (normally not used)

    $array_ref = $extractor->get_rules();

=head2 method get_run_debug (normally not used)

    $string = $extractor->get_run_debug();

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

Error message in case of unknown parameters at method new.

 Unknown parameter: ...

Missing parameter.

 No source_filename given ...

 No destination filename given ...

There is a problem in opening the file to extract.

 Can not open file ...

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

version

Carp

English

Clone

=head2 dynamic require

L<Data::Dumper|Data::Dumper>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

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
