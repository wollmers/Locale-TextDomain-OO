#!perl -T ## no critic (TidyCode)

use strict;
use warnings;
use utf8;
use Locale::TextDomain::OO::Lexicon::Hash;
use Locale::TextDomain::OO::Lexicon::StoreJSON;
use Tie::Hash::Sorted;

our $VERSION = 0;

# That sub I only wrote to have sorted hashes to test the output of this example.
# Otherwise the JSON string would change the keys.
# So sorted it is testable using string equal.
# Do not use that in productive code.
sub sort_hash_ref {
    my $hash_ref = shift;
    tie my %hash, 'Tie::Hash::Sorted', Hash => $hash_ref; ## no critic (Ties)
    return \%hash;
};

# switch of perlcritic because of po-file similar writing
## no critic (InterpolationOfLiterals EmptyQuotes NoisyQuotes)
Locale::TextDomain::OO::Lexicon::Hash
    ->new(
        logger => sub { () = print shift, "\n" },
    )
    ->lexicon_ref(
        sort_hash_ref({
            'en-gb:cat:dom' => [
                sort_hash_ref({
                    msgid  => "",
                    msgstr => ""
                        . "Content-Type: text/plain; charset=UTF-8\n"
                        . "Plural-Forms: nplurals=1; plural=n != 1;\n",
                }),
                sort_hash_ref({
                    msgid  => "GBP",
                    msgstr => "£",
                }),
            ],
        }),
    );
## use critic (InterpolationOfLiterals EmptyQuotes NoisyQuotes)

# To see how the filter is working see test "t/04_lexicon_store_JSON.t".
() = print Locale::TextDomain::OO::Lexicon::StoreJSON->new->to_json, "\n";

#$Id$

__END__

Output with all lexicons "en-gb:cat:dom" and the default "i-default::":

Lexicon "en-gb:cat:dom" loaded from hash.
{
  'en-gb:cat:dom' => {
    '{MSG_KEY_SEPARATOR}' => {
      'charset' => 'UTF-8',
      'nplurals' => 1,
      'plural' => 'n'
    },
    '{MSG_KEY_SEPARATOR}GBP' => {
      'msgstr' => "\xc2\xa3" # "\xc2\xa3" is £ as UTF-8
    }
  },
  'i-default::' => {
    '{MSG_KEY_SEPARATOR}' => {
      'nplurals' => 2,
      'plural' => 'n != 1'
    }
  }
}
