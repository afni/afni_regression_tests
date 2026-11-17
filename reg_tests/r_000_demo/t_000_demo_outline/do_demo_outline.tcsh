#!/usr/bin/env tcsh

# ===========================================================================
# run a test, usually from an empty directory (results will go HERE)
#
#     - run a test based on standard data
#     - input is generally elsewhere, output is HERE
#     - evaluate the local (non-regression) success of the command(s)
#       - likely with extra checks on any output files
#     - create status.txt  : store the above status, also use for exit value
#     - create regress.txt : store desired regression tests, to be run later
#
# ===========================================================================
# inputs:
#   - droot: root data dir - perhaps above AFNI_data6 or AFNI_data7
#
# outputs:
#   - status.txt  : contains 0 (success) or other (fail == 1 is sufficient)
#   - regress.txt : contains lines of regression tests
#                   3 columns: filename tolerance test
#   - data        : any files needed for regression testing
#
# return:
#   - exits with the same $status as is put in status.txt
# ===========================================================================

# ----------------------------------------------------------------------
# to create a new test script (starting from this one):
#
#   possibly edit the following CHANGE lines or regions:
#
#     1. set $dlocal = top path to data (e.g. AFNI_data7/task_demo_ap/sub-000/)
#        - this should end in a '/' (if not blank)
#     2. write some "process" commands and store $status in $rv
#        - the main command(s) to test
#     3. write some additional tests to evaluate the "process" commands
#        - set rv=0 if successful (else set rv=1 and "goto EXIT")
#     4. write regression tests to $file_reg
#
# ----------------------------------------------------------------------
# format of $file_reg = regress.txt - the regression tests file
#
#   3 columns per test : filename tolerance test
#
#     filename  : name of file to compare for regression test
#          e.g. : value.txt, motion.1D, data.nii, dset+tlrc
#     tolerance : if 3dDiff, tolerance to apply (else any token)
#          e.g. : 0, 0.01
#     test      : one of diff, 3dDiff
#        diff   : run diff or cmp to detect text differences
#        3dDiff : run 3dDiff (with tolerance, if non-zero)
#
# ----------------------------------------------------------------------
# minor notes:
#   - a naming order is not required, it might be easier to move tests
#     around, such as having one script in multiple locations
#   - tests will probably have one script per directory
#
# ----------------------------------------------------------------------
# variables (required by the testing script):
#
#     $dfull      : full path prefix to (any remote) input files below
#                   combining input $droot and $dlocal, else ""
#     $file_stat  : file to write final $rv/$status to
#                   (must be status.txt)
#     $file_reg   : file to write final regression tests to
#                   (must be regress.txt)
#     $rv         : final return value (used as "exit $rv")
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# set at least 4 required variables: dfull, file_stat, file_reg, rv

# CHANGE: local data root (e.g. "" or "AFNI_data7/task_demo_ap/sub-000/")
set dlocal = "AFNI_data6/afni/"

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

# ===== START CHANGE : run main commands to test =====
# e.g. create 2 output files and check the status of nifti_tool
set myoutput = out.process.txt
echo "I like cheese" > $myoutput

set dout = tiny_image.nii
nifti_tool -make_im -prefix $dout
set rv = $status
# ===== END CHANGE =====

if ( $rv ) then
   goto EXIT
endif

# ----------------------------------------------------------------------
# basic tests from above process - run any basis tests (non-regression)
#
# assumes: probably nothing (might have filename variables)
#
# if failure, set $rv and goto EXIT
# 

set rv = 0

# ===== START CHANGE : perform local test(s) =====
if ( ! -f $myoutput ) then
   echo "== stat: FAIL: missing output"
   set rv = 1
   goto EXIT
endif

# some dataset test...
set nvox = `3dinfo -nijk $dout`
if ( "$nvox" != 1 ) then
   echo "== stat: FAIL: count $nvox != 1"
   set rv = 1
   goto EXIT
endif
# ===== END CHANGE =====

# ===============================================
# KEEP: if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS"

# ======================================================================
# CHANGE: regression tests (file test ...) stored in regress file

echo $dout 0.001 3dDiff >> $file_reg
echo $myoutput 0 diff >> $file_reg

# ======================================================================
# KEEP: exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

