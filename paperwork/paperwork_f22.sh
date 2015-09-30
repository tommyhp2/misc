#!/bin/sh
BANNER='-------------------------------------------------------------------------------'
LOGFILE=~/paperwork_f22.log

echo "Installing dependency packages..." | tee $LOGFILE
dnf install curl git php php-cli php-gd php-mcrypt php-mysqlnd wget nodejs npm
echo "Installed nodejs & npm packages." | tee -a $LOGFILE
rpm -qa | egrep -i 'nodejs|npm' | sort | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo -n "Enter the install directory: "
read INSTALLDIR
if [ ! -d $INSTALLDIR ]
then
  echo "Creating directory $INSTALLDIR since it doesn't exists."
  mkdir -p $INSTALLDIR
fi
BASEDIR=$INSTALLDIR/paperwork
FRONTENDDIR=$BASEDIR/frontend
echo $BANNER

cd $INSTALLDIR
if [ -d $BASEDIR ]
then
  echo "Removing existing directory $BASEDIR."
  rm -fr $BASEDIR
  echo $BANNER
fi
echo "Cloning source."
git clone https://github.com/twostairs/paperwork.git
echo $BANNER

cd $BASEDIR
echo -n "Enter branch to use: "
read BRANCH
if [ ! -z $BRANCH ]
then
  echo "Using branch paperwork/$BRANCH." | tee -a $LOGFILE
  git checkout $BRANCH
else
  echo "Using branch paperwork/master." | tee -a $LOGFILE
fi
echo $BANNER | tee -a $LOGFILE

cd $FRONTENDDIR
echo "Getting composer."
curl -sS https://getcomposer.org/installer | php
echo $BANNER

echo "Modify the database settings."
if [ -f ~/database.php ]
then
  cp -fv ~/database.php $FRONTENDDIR/app/config/database.php
else
  nano $FRONTENDDIR/app/config/{,local/}database.php
fi
echo $BANNER

echo "Composer install..." | tee -a $LOGFILE
php composer.phar install | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo "Migrating the database." | tee -a $LOGFILE
php artisan migrate
echo $BANNER | tee -a $LOGFILE

echo "Installing npm modules: gulp & bower." | tee -a $LOGFILE
npm install -g gulp bower | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE
echo "Installed npm modules." | tee -a $LOGFILE
npm list -g | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo "npm installing..." | tee -a $LOGFILE
npm install | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo "bower installing..." | tee -a $LOGFILE
bower install --allow-root | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo "Running gulp" | tee -a $LOGFILE
gulp | tee -a $LOGFILE
echo $BANNER | tee -a $LOGFILE

echo "Setting filesystem ownership for directory $BASEDIR." | tee -a $LOGFILE
chown -R apache:apache $BASEDIR
echo $BANNER | tee -a $LOGFILE

echo "Complete!" | tee -a $LOGFILE
