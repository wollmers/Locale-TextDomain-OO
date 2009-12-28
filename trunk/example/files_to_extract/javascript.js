// this was an extract from http://jsgettext.berlios.de/doc/html/Gettext.html

alert(_("some string"));
alert(gt.gettext("some string"));
alert(gt.gettext("some string"));
var myString = this._("this will get translated");
alert( _("text") );
alert( gt.gettext("Hello World!\n") );
var translated = Gettext.strargs( gt.gettext("Hello %1"), [full_name] );
Code: Gettext.strargs( gt.gettext("This is the %1 %2"), ["red", "ball"] );
printf( ngettext("One file deleted.\n",
                 "%d files deleted.\n",
                 count),
        count);
Gettext.strargs( gt.ngettext( "One file deleted.\n",
                              "%d files deleted.\n",
                              count), // argument to ngettext!
                 count);
alert( pgettext( "Verb: To View", "View" ) );
alert( pgettext( "Noun: A View", "View"  ) );
var count = 14;
Gettext.strargs( gt.ngettext('one banana', '%1 bananas', count), [count] );


// do not find _('error 1'); _("error 2");

/* 
    do not find
    _('error 3');
    _("error 4");
*/

// this are all combinations

gettext(     'MSGID 1' ) 
_      (     'MSGID 2' )
ngettext(    'MSGID 3', 'MSGID_PLURAL', COUNT ) 
pgettext(    'MSGCTXT', 'MSGID 4' ) 
npgettext(   'MSGCTXT', 'MSGID 5', 'MSGID_PLURAL', COUNT ) 
dgettext(    'TEXTDOMAIN', 'MSGID 6' ) 
dcgettext(   'TEXTDOMAIN', 'MSGID 7', 'CATEGORY' ) 
dngettext(   'TEXTDOMAIN', 'MSGID 8', 'MSGID_PLURAL', COUNT ) 
dcngettext(  'TEXTDOMAIN', 'MSGID 9', 'MSGID_PLURAL', COUNT, 'CATEGORY' ) 
dpgettext(   'TEXTDOMAIN', 'MSGCTXT', 'MSGID 10' ) 
dcpgettext(  'TEXTDOMAIN', 'MSGCTXT', 'MSGID 11', 'CATEGORY' ) 
dnpgettext(  'TEXTDOMAIN', 'MSGCTXT', 'MSGID 12', 'MSGID_PLURAL', COUNT ) 
dcnpgettext( 'TEXTDOMAIN', 'MSGCTXT', 'MSGID 13', 'MSGID_PLURAL', COUNT, 'CATEGORY' )
