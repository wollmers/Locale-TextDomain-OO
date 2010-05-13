@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
use strict;
use warnings;

use File::Find;

find(
    sub {
        -d and return;
        $File::Find::name =~ m{\.svn}xms and return;
        open my $fh, '< :raw', $_ or die qq{$File::Find::name $!};
        local $/ = ();
        my $content = <$fh>;
        close $fh;
        my $write;
        if ( m{\.pl \z}xms ) {
            if ( $content =~ s{\A \xEF \xBB \xBF (\#!perl)}{$1}xms ) {
                $write = 1;
                print "LTR deleted at file $File::Find::name\n";
            }
        }
        if ( m{\.js \z}xms || m{\.tt \z}xms ) {
            if ( $content =~ s{\x0D? \x0A \x0D?}{\x0D\x0A}xmsg ) {
#                $write = 1;
            }
            if ( $content =~ s{\t}{}xmsg ) {
#                $write = 1;
                print "Tab detected at file $File::Find::name\n";
            }
        }
        if ($write) {
            open $fh, '> :raw', $_
                or die qq{$File::Find::name $!};
            print $fh $content
                or die qq{$File::Find::name $!};
            close $fh
                or die qq{$File::Find::name $!};
        }
    },
    q{.},
);
__END__
:endofperl
:script_failed_so_exit_with_non_zero_val
pause