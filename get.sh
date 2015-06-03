#! /bin/bash
#
# Get package files from InVEST and copy them into invest.natcap.
#


invest_dir=../invest-natcap.invest-3/invest_natcap
for pkg_dir in `ls $invest_dir`
do
    full_filepath=$invest_dir/$pkg_dir
    if [ -d $full_filepath ]
    then
        cp -r $full_filepath natcap/invest
    fi
done
find natcap/invest -name "*.pyc" | xargs rm
find natcap/invest -name "*.c" | xargs rm
find natcap/invest -name "*.cpp" | xargs rm

