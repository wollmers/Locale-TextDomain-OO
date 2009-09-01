@echo off

perl -MFile::Copy -e "copy qw(11_performance_gettext_mo.pl trunk/example/)"
perl -MFile::Copy -e "copy qw(12_performance_gettext_struct_from_locale_po.pl trunk/example/)"
cd trunk/example/

perl -T -I../lib -d:DProf 11_performance_gettext_mo.pl
rem perl -T -I../lib -MDevel::Profiler 11_performance_gettext_mo.pl

call dprofpp
rem call dprofpp -T

perl -T -I../lib -d:DProf 12_performance_gettext_struct_from_locale_po.pl
rem perl -T -I../lib -MDevel::Profiler 12_performance_gettext_struct_from_locale_po.pl

call dprofpp
rem call dprofpp -T

perl -e "unlink qw(11_performance_gettext_mo.pl delete 12_performance_gettext_struct_from_locale_po.pl tmon.out)"

pause
