
job of a test script
   - run local test with remote data
     - script is HERE
     - run HERE
     - all output is HERE
   - input:
     - top level directory (typically a parent of AFNI_data6)
   - output:
     - file: status.txt  - status of the test
     - file: regress.txt - regression tests (file tolerance test)
     - return status
   ? extras:
     - maybe put "# TTYPE smoke" line(s) for desired regression tests
     - comment any main points of test

structure of test tree
   - paths to do_* test scripts
   - one script per directory
   ? naming and organization is for a higher level

job of running tests
   - note desired tests to run - choices:
     - a testing directory tree
     - multiple sub-trees
     - a list of paths to do_* test scripts
   - sync the tree of these tests to a new RESULTS directory
     - will be a directory containing do_* test scripts
   - for each contained do_* script:
       cd script dir
       tcsh -x script |& tee out.$script
       note $status
       cd -
   - log and report status count
   - log options (Yarik's software?)
     - run time (/usr/bin/time ?)
     - RAM use
     
job of regression testing
   - input:
     - test tree - some new RESULTS directory from running tests
     - base tree - some old RESULTS directory that we trust
   - process:
     make new regress tree
       - run afni_system_check.py and save output
       - sync desired testing sub-tree
         ? maybe start by finding all do_* scripts in test tree and sync
         - include status.txt and regress.txt files (more?)
       - for each test tree leaf directory
            if bad $status, skip (and note)
            if no tests in regress.txt, skip (and note)
            for each test in regress.txt
               perform tests
                 - create reg.run.INDEX.tcsh command files for each test
                 - run reg.run REGSCRIPT - text to out.REGSCRIPT
                 - status out.reg.status.INDEX.txt
   - log results
     - can possibly make JSON files for auto-generating reports
       - some can be in trees, some at the top level

