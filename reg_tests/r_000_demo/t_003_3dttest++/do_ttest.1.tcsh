#!/usr/bin/env tcsh

# ------------------------------
# # set 4 required variables: dfull, rv, file_stat, file_reg

# (optional) index/label vars, for scripts that choose to use them
set index  = 03
set label  = ${index}_ttest
set dlocal = "AFNI_data6/group_results/"

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

set outset = stat.5.ttest.nii
3dttest++ -prefix $outset                                      \
          -AminusB                                             \
          -setA Vrel                                           \
             FP ${dfull}"OLSQ.FP.betas+tlrc.HEAD[Vrel#0_Coef]" \
             FR ${dfull}"OLSQ.FR.betas+tlrc.HEAD[Vrel#0_Coef]" \
             FT ${dfull}"OLSQ.FT.betas+tlrc.HEAD[Vrel#0_Coef]" \
             FV ${dfull}"OLSQ.FV.betas+tlrc.HEAD[Vrel#0_Coef]" \
             FX ${dfull}"OLSQ.FX.betas+tlrc.HEAD[Vrel#0_Coef]" \
             GF ${dfull}"OLSQ.GF.betas+tlrc.HEAD[Vrel#0_Coef]" \
             GG ${dfull}"OLSQ.GG.betas+tlrc.HEAD[Vrel#0_Coef]" \
             GI ${dfull}"OLSQ.GI.betas+tlrc.HEAD[Vrel#0_Coef]" \
             GK ${dfull}"OLSQ.GK.betas+tlrc.HEAD[Vrel#0_Coef]" \
             GM ${dfull}"OLSQ.GM.betas+tlrc.HEAD[Vrel#0_Coef]" \
          -setB Arel                                           \
             FP ${dfull}"OLSQ.FP.betas+tlrc.HEAD[Arel#0_Coef]" \
             FR ${dfull}"OLSQ.FR.betas+tlrc.HEAD[Arel#0_Coef]" \
             FT ${dfull}"OLSQ.FT.betas+tlrc.HEAD[Arel#0_Coef]" \
             FV ${dfull}"OLSQ.FV.betas+tlrc.HEAD[Arel#0_Coef]" \
             FX ${dfull}"OLSQ.FX.betas+tlrc.HEAD[Arel#0_Coef]" \
             GF ${dfull}"OLSQ.GF.betas+tlrc.HEAD[Arel#0_Coef]" \
             GG ${dfull}"OLSQ.GG.betas+tlrc.HEAD[Arel#0_Coef]" \
             GI ${dfull}"OLSQ.GI.betas+tlrc.HEAD[Arel#0_Coef]" \
             GK ${dfull}"OLSQ.GK.betas+tlrc.HEAD[Arel#0_Coef]" \
             GM ${dfull}"OLSQ.GM.betas+tlrc.HEAD[Arel#0_Coef]" \
             -paired

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
if ( ! -f $outset ) then
   echo "== stat: FAIL: $label : missing output, $outset"
   set rv = 1
   goto EXIT
endif

# ----- end local test(s) : END CHANGE -----

# -------------
# do not change - if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS: $label"

# ----------------------------------------------------------------------
# regression tests (file test ...) stored in regress file

echo $outset 0.01 3dDiff >> $file_reg

# ----------------------------------------------------------------------
# exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

