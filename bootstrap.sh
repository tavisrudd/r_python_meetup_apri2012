#!/bin/bash
## install Python 2.7 and virtualenvwrapper at the OS/package-manager level
source /usr/bin/virtualenvwrapper.sh

VENV_NAME=r_python_meetup
if [[ -e $WORKON_HOME/$VENV_NAME ]]; then
    workon $VENV_NAME
else
    mkvirtualenv --no-site-packages $VENV_NAME
fi

# install the requirements in several sets as they have cross-deps
pip install -r requirements1.txt
pip install -r requirements2.txt
pip install pandas # 0.7.3

# the development version of ipython won't install by pip at the moment, 
# do it manually:
pushd .
cdsitepackages 
[[ -e $VIRTUAL_ENV/src ]] || mkdir -p $VIRTUAL_ENV/src
cd $VIRTUAL_ENV/src
rm -rf ipython
git clone git://github.com/ipython/ipython.git
cd ipython 
git checkout 56745b883117d309bd69dd68d00c7f571a7b4cb4
python setup.py install
popd
