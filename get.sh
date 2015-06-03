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

# find imports that are not in python's stdlib.
ENV=invest_test_env
virtualenv --no-setuptools --clear $ENV
source $ENV/bin/activate
which python
echo "Packages imported by python packages that might need to be installed"
for pkg_name in `grep -rh import\  natcap/invest | sort | uniq | grep -oEi '(^import [a-zA-Z0-9_]+)|(^from [a-zA-Z0-9_]+)' | grep -oE '[^ ]+$' | uniq`
do
    python -c "import $pkg_name" &> /dev/null

    # if the package does not import (exit code is nonzero), package might need to be installed.
    if [ "$?" -ne "0" ]
    then
        # If we can find a file by this name in the invest source tree, we won't need to install it to the system
        if [ ! -e "`find . -name \"$pkg_name.py\" -o -name \"$pkg_name.pyx\"`" ]
        then
            echo $pkg_name
        fi
    fi
done
    

