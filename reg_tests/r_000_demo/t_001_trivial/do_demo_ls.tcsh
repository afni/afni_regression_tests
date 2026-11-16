#!/usr/bin/env tcsh

# ------------------------------
# set at least 4 required variables: dfull, rv, file_stat, file_reg

# local data root (e.g. "" or "AFNI_data7/task_demo_ap/sub-000/")
set dlocal = ""

# note final files and initialize them, init return value
set file_stat = status.txt
set file_reg  = regress.txt
set rv        = 9    # return value or $status (9 means nothing saved)
echo -n $rv   >! $file_stat
echo -n ""    >! $file_reg

# set droot to an input root, env var or nothing (meaning inputs are HERE)
set droot = ''
echo nargs = $#argv
if ( $#argv > 0 ) then
    set droot = $1
else if ( $?AFNI_REGTEST_DROOT ) then
    set droot = $AFNI_REGTEST_DROOT
endif

# set needed dfull: if $droot is known, combine with $dlocal
if ( "$droot" != "" ) then
    set dfull = $droot/$dlocal
else
    set dfull = ''
endif

# ----------------------------------------------------------------------
# process - run the main command(s) and set the return value, rv
#
# assumes: $dfull, $label (optional per script)
#
# if failure, set $rv and goto EXIT

ls -l >! files.ls.txt
set rv = $status

if ( $rv ) then
   goto EXIT
endif

# ----------------------------------------------------------------------
# basic tests from above process - run any basis tests (non-regression)
#
# assumes: probably nothing
#
# if failure, set $rv and goto EXIT
# 

set rv = 0

# ----- perform local test(s) : START CHANGE -----
if ( ! -f files.ls.txt ) then
   echo "== stat: FAIL: missing output"
   set rv = 1
   goto EXIT
endif
# ----- end local test(s) : END CHANGE -----

# -------------
# do not change - if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS"

# ----------------------------------------------------------------------
# regression tests (file test ...) stored in regress file

echo files.ls.txt 0 diff >> $file_reg

# ----------------------------------------------------------------------
# exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

