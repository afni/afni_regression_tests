#!/usr/bin/env tcsh

# ----------------------------------------------------------------------
# note types of tests this might apply to
# TTYPE demo

# ----------------------------------------------------------------------
# # set 4 required variables: dfull, rv, file_stat, file_reg

set dlocal = "AFNI_data6/group_results/"

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
# assumes: probably nothing (might have filename variables)
#
# if failure, set $rv and goto EXIT
# 

set rv = 0

# ----- perform local test(s) : START CHANGE -----
if ( ! -f $outset ) then
   echo "== stat: FAIL: missing output, $outset"
   set rv = 1
   goto EXIT
endif

# ----- end local test(s) : END CHANGE -----

# ===============================================
# KEEP: if we are here, the basic tests succeeded
set rv = 0
echo "== stat: SUCCESS"

# ----------------------------------------------------------------------
# CHANGE: regression tests (file test ...) stored in regress file

echo $outset 0.01 3dDiff >> $file_reg

# ======================================================================
# KEEP: exit, saving status

EXIT:
echo $rv >! $file_stat

exit $rv

