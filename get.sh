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
    else
        cp $full_filepath natcap/invest  # when it's just a python file
    fi
done

# remove cythonized/compiled files
echo "Removing compiled/cythonized files"
find natcap/invest -name "*.pyc" \
    -o -name "*.c" \
    -o -name "*.cpp" \
    -o -name "*.orig" \
    -o -name "*.so" | xargs rm

# remove any empty folders
echo "Removing any empty package folders"
for dirname in `ls natcap/invest`
do
    full_dirname=natcap/invest/$dirname
    if [ "`ls $full_dirname`" = "" ]  && [ -d "$full_dirname" ]
    then
        rm -r $full_dirname
    fi
done

# find/replace invest_natcap with natcap.invest
echo "Replacing 'invest_natcap' with 'natcap.invest'"
for py_file in `find natcap/invest -name "*.py" -o -name "*.json"`
do
    sed -i .bak 's/invest_natcap/natcap.invest/g' $py_file
    rm $py_file.bak
done

# expose the module's execute function by adding to the correct __init__ file
echo "Exposing entrypoints for models"
basedirname=natcap/invest
for name in `ls $basedirname`
do
    if [ -d "$basedirname/$name" ]
    then
        pkg_python_file=$basedirname/$name/$name.py
        pkg_init_file=$basedirname/$name/__init__.py
        if [ ! -e "$pkg_python_file" ]
        then
            echo "$pkg_python_file does not exist.  Manually expose the entry point for this package"
        else
            echo "from $name import execute" >> $pkg_init_file
            echo "__all__ = ['execute']" >> $pkg_init_file
        fi
    fi
done

exit 0

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
        if [ ! -e "`find natcap/invest -name \"$pkg_name.py\" -o -name \"$pkg_name.pyx\"`" ]
        then
            echo $pkg_name
        fi
    fi
done
    

