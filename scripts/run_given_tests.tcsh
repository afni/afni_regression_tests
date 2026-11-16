#!/usr/bin/env tcsh

# ---------------------------------------------------------------------------
# - given an indir tree with tests and and outdir name for results
#   - under indir, find all do_* scripts
#   - rsync that tree of scripts (ignores any extra files)
#   - cd outdir
#   - for each script
#     - cd to script dir
#     - run script (pass $data_root)
#     - note status
#     - cd -
#
# ---------------------------------------------------------------------------
# organization:
#   - scripts and directories do not require numbering (but it is okay)
#   - scripts are independent, so sets could be processed in parallel
#
# ---------------------------------------------------------------------------

set verbosity = 0
set data_root = ~/data
# allow env var to override data_root
if ( $?AFNI_REGTEST_DROOT ) then
   set data_root = $AFNI_REGTEST_DROOT
endif

# probably run with RUN tests.clean run
set indir = $1
set newdir = $2

if ( -d $newdir ) then
   echo "** will not overwrite $newdir tree"
   exit 1
endif

mkdir -p $newdir

if ( ! -d $indir || ! -d $newdir ) then
   echo "** missing dirs?"
   exit 1
endif


set all_test_files = ( `find $indir -name do_\* | sort` )
rsync -avR $all_test_files $newdir
cd $newdir

set all_test_files = ( `find . -name do_\* | cut -b3- | sort` )
set nfailures = 0
foreach testfile ( $all_test_files )
   set tdir = $testfile:h
   set tfile = $testfile:t

   cd $tdir
   echo "++ running test in $tdir "
   if ( $verbosity ) then
      tcsh -x $tfile $data_root |& tee out.tfile
      set rv = $status
   else
      tcsh -x $tfile $data_root >& out.tfile
      set rv = $status
   endif
   if ( $rv ) then
      @ nfailures += 1
   endif

   echo status : $rv
   cd -
end

echo ""
echo "== have $nfailures failures out of $#all_test_files tests"
echo ""

