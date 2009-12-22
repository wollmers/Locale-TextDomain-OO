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
