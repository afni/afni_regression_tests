#!/usr/bin/env tcsh

# ----------------------------------------------------------------------
# this is a trivial demo with CHANGE sections in place - a good template
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# set at least 4 required variables: dfull, file_stat, file_reg, rv

# CHANGE: local data root (e.g. "" or "AFNI_data7/task_demo_ap/sub-000/")
set dlocal = ""

# ===== start KEEP: do not alter ============================================
# note final files and initialize them, init return value
set file_stat = status.txt
set file_reg  = regress.txt
set rv        = 9    # return value or $status (9 means nothing saved)
echo -n $rv   >! $file_stat
echo -n ""    >! $file_reg

# set droot to required input data root
set droot = $1

# set needed dfull: if $droot is known, combine with $dlocal
if ( "$droot" != "" ) then
    set dfull = $droot/$dlocal
else
    set dfull = ''
endif
# ===== end KEEP ============================================================

# ----------------------------------------------------------------------
# process - run the main command(s) and set the return value, rv
#
# assumes: $dfull
# result : set $rv
#
# if failure, goto EXIT

# ----- START CHANGE: main process commands -----
ls -l >! files.ls.txt
set rv = $status

if ( $rv ) then
   goto EXIT
endif
# ----- END CHANGE -----

# ----------------------------------------------------------------------
# basic tests from above process - run any basis tests (non-regression)
#
# assumes: probably nothing (might have filename variables)
#
# if failure, set $rv and goto EXIT
# 

set rv = 0

# ----- START CHANGE: perform local test(s) -----
if ( ! -f files.ls.txt ) then
   echo "== stat: FAIL: missing output"
   set rv = 1
   goto EXIT
endif
# ----- END CHANGE: local test(s) -----

# ===============================================
# KEEP: if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS"

# ----------------------------------------------------------------------
# CHANGE: regression tests (file test ...) stored in regress file

echo files.ls.txt 0 diff >> $file_reg

# ======================================================================
# KEEP: exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

