#!perl -T

use strict;
use warnings;
use utf8;
use Locale::TextDomain::OO::Lexicon::Hash;
use Locale::TextDomain::OO::Lexicon::StoreJSON;

our $VERSION = 0;

Locale::TextDomain::OO::Lexicon::Hash
    ->new(
        logger => sub { print shift, "\n" },
    )
    ->lexicon_ref({
        'en-gb:cat:dom' => [
            {
                msgid  => "",
                msgstr => ""
                    . "Content-Type: text/plain; charset=UTF-8\n"
                    . "Plural-Forms: nplurals=1; plural=n != 1;\n",
            },
            {
                msgid  => "GBP",
                msgstr => "£",
            },
        ],
    });

# to see how the filter is working see test t/04_lexicon_store_JSON.t
print Locale::TextDomain::OO::Lexicon::StoreJSON->new->to_json,

__END__

Output with all lexicons "en-gb:cat:dom" and the default "i-default::":

Lexicon "en-gb:cat:dom" loaded from hash.
{"en-gb:cat:dom":{"\u0004GBP":{"msgstr":"£"},"\u0004":{"plural":"n","charset":"UTF-8","nplurals":1}},"i-default::":{"\u0004":{"plural":"n != 1","nplurals":2}}}
