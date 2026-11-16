#!/usr/bin/env tcsh

# ===========================================================================
# run a test, usually from an empty directory (results will go HERE)
#
#     - run a test based on standard data
#     - input is generally elsewhere, output is HERE
#     - evalute the local (non-regression) success of the command(s)
#       - likely with extra checks on any output files
#     - create status.txt  : store the above status, also use for exit value
#     - create regress.txt : store desired regression tests, to be run later
#
# ===========================================================================
# inputs: none required
#   - (optional) droot: root data dir
#     - else use any $AFNI_REGTEST_DROOT, else data is HERE
#     - root data dir: typically above AFNI_data6 or AFNI_data7
#
# outputs:
#   - status.txt  : contains 0 (success) or other (fail == 1 is sufficient)
#   - regress.txt : contains list of "file test_type" for regression testing
#   - data        : any files needed for regression testing
#
# return:
#   - exits with the same $status as is put in status.txt
# ===========================================================================

# ----------------------------------------------------------------------
# format of a test script:
#
# - run one test (script) per test directory
# - possibly edit any CHANGE lines or regions
#   - set $index and $label - optional, main tests will not use these
#   - set $dlocal = top path to data (e.g. AFNI_data7/task_demo_ap/sub-000/)
#   - write some "process" commands and store $status in $rv
#     - this is the main command or commands to test
#   - write some tests to evaluate basic "success" of the "process" commands
#     - if success: set $rv=0, write regression tests to $file_reg
#     - if failure: set $rv=1, goto EXIT
#   - write final $rv ($status) to status.txt and eventually return $rv
#
# ----------------------------------------------------------------------
# format of $file_reg = regress.txt - the regression tests file
#   - 3 columns : filename tolerance test
#     filename  : name of file to compare for regression test
#          e.g. : value.txt, motion.1D, data.nii, dset+tlrc.HEAD
#     tolerance : if 3dDiff, tolerance to apply (else any token)
#          e.g. : 0, 0.01
#     test      : one of:
#        diff     : run diff or cmp to detect text differences
#        3dDiff   : run 3dDiff with any non-zero tolerance
#
# ----------------------------------------------------------------------
# minor notes:
#   - a naming order is not required, it might be easier to move tests
#     around, such as having one script in multiple locations
#
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# variables: 
#   required to apply later:
#     $dfull      : full path prefix to input files below
#                   combining input $droot and local $dlocal, else ""
#     $rv         : final return value (used as "exit $rv")
#     $file_stat  : file to write final $rv/$status to
#                   (must be status.txt)
#     $file_reg   : file to write final regression tests to
#                   (must be regress.txt)
#
#   optional (likely not used for main AFNI regression tests)
#     $label      : a label possibly used in file names
#                 : might be based on some $index

# ------------------------------
# set at least 4 required variables: dfull, file_stat, file_reg, rv

# CHANGE these vars
# (optional) index/label vars, for scripts that choose to use them
set index  = 01
set label  = ${index}_CHANGE
# local data root (e.g. "" or "AFNI_data7/task_demo_ap/sub-000/")
set dlocal = "AFNI_data6/afni/"

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

echo "CHANGE : run commands to test (this is the point of script)"
echo "I like cheese" > CHANGE.out.run.txt
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
if ( ! -f CHANGE.out.run.txt ) then
   echo "== stat: FAIL: $label : missing output"
   set rv = 1
   goto EXIT
endif

# CHANGE : perform any extra local tests
set nvox = `cat CHANGE.out.run.txt | wc -w`
if ( $nvox != 3 ) then
   echo "== stat: FAIL: $label : count $nvox != 3"
   set rv = 1
   goto EXIT
endif
set CHANGEout = CHANGE.dout_$label.nvox.txt
echo $nvox > $CHANGEout
# ----- end local test(s) : END CHANGE -----

# -------------
# do not change - if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS: $label"

# ----------------------------------------------------------------------
# regression tests (file test ...) stored in regress file

echo CHANGE.output.nii 0.001 afni_exact >! $file_reg
echo $CHANGEout 0 diff >> $file_reg

# ----------------------------------------------------------------------
# exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

