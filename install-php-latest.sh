#!/bin/bash

#. _DEBUG.sh

#
# PHP installation script for shared hostings
#
# Copyright 2013 Oleg Chirukhin (olegchiruhin@gmail.com)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at#
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
# Originally it was php5.4-install.sh from http://wiki.dreamhost.com/Installing_PHP5
#
# Revision history:
# 2013-10-08 by Oleg Chirukhin (olegchir.com)
#          a lot of changes, take a look at https://github.com/olegchir/php-for-shared-hosting/blob/master/README.md
# 2013-08-09 by Graham [http://blog.ham1.co.uk/] for latest PHP 5.4 and APC 3.1.13.
# 2013-05-02 by Krishna Desai (http://krishnadesai.com) for latest version of libmcrypt
# 2012-10-05 by Leonid Komarovsky (http://leonid.komarovsky.info) for PHP 5.4 and latest version of Xdebug. Added PostgreSQL support.
# 2011-12-01 by David (deceifermedia.com) for latest package versioins, updated download links,
#      and for the MySQLi and PDO extensions to use mysqlnd instead of libmysql (highly recommended)
# 2010-07-03 by Andres (andrew67.com) for latest php, curl and openssl versions and enabling perl/pecl
# 2009-12-27 by Steven Rosato to fix PHP 5.3 Compile Error: Undefined References in dns.c
# 2009-09-24 by Christopher (heavymark.com) for latest source versions and incorrect url and addition of proper enabling of xmlrpc.
# 2009-08-05 by Andy (andy.hwang.tw) to correct typo on m4 extract command.
# 2009-07-28 by samutz (samutz.com) to include ZIP, XMLRPC,
#          and GNU M4 (previous version of script failed without it)
# 2009-07-24 by ercoppa (ercoppa.org) to convert this script for PHP 5.3 (with all features of dreamhost,
#          except kerberos) with Xdebug and APC
# 2009-05-24 by ksmoe to correct copying of correct PHP cgi file (php-cgi instead of php)
# 2009-04-25 by Daniel (whathuhstudios.com) for latest source versions
# 2007-11-24 by Andrew (ajmconsulting.net) to allow 3rd wget line to pass
#          MCRYPT version information (was set as static download file name previously.)
# 2006-12-25 by Carl McDade (hiveminds.co.uk) to allow memory limit and freetype

# Save the code to a file as *.sh
# Don't forget to chmod a+x it!

# Abort on any errors
set -e

. parse_args.sh

if [ "$STARTWITHPHP" != "true" ] ; then
    echo "Building all modules, including base like curl, m4, cclient, etc"
else
    echo "Resume from building main PHP code"
fi

if [ $(package_used "php") == "y" ] ; then
    echo "PHP = on"
else
    echo "PHP = off"
fi

exit 0


# Where do you want all this stuff built? I'd recommend picking a local filesystem.
# ***Don't pick a directory that already exists!***
# We clean up after ourselves at the end!
SRCDIR=${HOME}/opt/php-latest/source

# And where should it be installed?
INSTALLDIR=${HOME}/opt/php-latest/prefix

# Set DISTDIR to somewhere persistent, if you plan to muck around with this
# script and run it several times!
DISTDIR=${HOME}/opt/php-latest/dist

DOMAINTEMPLATE=${HOME}/opt/php-latest/domain-template

# Update version information here.
PHP5="php5.5-latest" #MUST BE THE CURRENT VERSION
PHP5_BASE_VERSION="php5.5"
CURL="curl-7.32.0"
XDEBUG="xdebug-2.2.3"
M4="m4-1.4.17"
AUTOCONF="autoconf-2.69"
CCLIENT="imap-2007f" #MUST BE THE CURRENT VERSION
CCLIENT_DIR="imap-2007f"
OPENSSL="openssl-1.0.1e"
OPENSSL_DIR=$OPENSSL
LIBMCRYPT="2.5.8"
LIBTOOL="libtool-2.4.2"
APC="APC-3.1.9"

# What PHP features do you want enabled?
PHPFEATURES="--prefix=${INSTALLDIR} \
--with-config-file-path=${INSTALLDIR}/etc/php5/configs \
--with-config-file-scan-dir=${INSTALLDIR}/etc/php5/configs \
--enable-fastcgi \
--bindir=$INSTALLDIR/bin \
--enable-force-cgi-redirect \
--enable-zip \
--enable-xmlrpc \
--with-xmlrpc \
--with-xml \
--with-freetype-dir=/usr \
--with-mhash=/usr \
--with-zlib-dir=/usr \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--with-curl=${INSTALLDIR} \
--with-gd \
--enable-gd-native-ttf \
--enable-memory-limit \
--enable-ftp \
--enable-exif \
--enable-sockets \
--enable-wddx \
--enable-sqlite-utf8 \
--enable-calendar \
--enable-mbstring \
--enable-mbregex \
--enable-bcmath \
--with-mysql=/usr \
--with-mysqli=mysqlnd \
--with-pear \
--with-gettext \
--with-pdo-mysql=mysqlnd \
--with-pgsql \
--with-pdo-pgsql \
--with-openssl=${INSTALLDIR} \
--with-xsl \
--with-ttf=/usr \
--with-xslt \
--with-xslt-sablot=/usr \
--with-dom-xslt=/usr \
--with-mcrypt=${INSTALLDIR} \
"

WGETCMD="wget --no-check-certificate --max-redirect=1000"

# ---- end of user-editable bits. Hopefully! ----

if [ "$INFO_MODE" = "true" ] ; then
    echo "You requested to print information only. Exiting..."
    exit 0
fi

echo "Press any key to continue."
read tmp


# Pre-download clean up!!!!
if [ "$STARTWITHPHP" != "true" ] ; then
    rm -rf $SRCDIR
else
    if [ "$WITHOUT_PHP" != "true" ] ; then
    rm -rf ${SRCDIR}/${PHP5}
    fi

    if [ "$WITHOUT_XDEBUG" != "true" ] ; then
    rm -rf ${SRCDIR}/${XDEBUG}
    fi

    if [ "$WITHOUT_APC" != "true" ] ; then
    rm -rf ${SRCDIR}/${APC}
    fi
fi

# Push the install dir's bin directory into the path
export PATH=${INSTALLDIR}/bin:$PATH

#fix for PHP 5.3 Compile Error: Undefined References in dns.c
export EXTRA_LIBS="-lresolv"

# set up directories
mkdir -p ${SRCDIR}
mkdir -p ${INSTALLDIR}
if [ ! -f ${DISTDIR} ]
then
mkdir -p ${DISTDIR}
fi

cd ${DISTDIR}

if [ "$STARTWITHPHP" != "true" ] ; then

    if [ ! -f ${DISTDIR}/${CURL}.tar.gz ]
    then
        $WGETCMD -c http://curl.haxx.se/download/${CURL}.tar.gz
    fi

    if [ ! -f ${DISTDIR}/${M4}.tar.gz ]
    then
        $WGETCMD -c http://ftp.gnu.org/gnu/m4/${M4}.tar.gz
    fi

    if [ ! -f ${DISTDIR}/${CCLIENT}.tar.Z ]
    then
        $WGETCMD -c ftp://ftp.cac.washington.edu/imap/${CCLIENT}.tar.Z
    fi

    if [ ! -f ${DISTDIR}/${OPENSSL}.tar.gz ]
    then
        $WGETCMD -c http://www.openssl.org/source/${OPENSSL}.tar.gz
    fi

    if [ ! -f ${DISTDIR}/${LIBMCRYPT}.tar.gz ]
    then
        $WGETCMD -c http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/${LIBMCRYPT}/libmcrypt-${LIBMCRYPT}.tar.gz
    fi

    if [ ! -f ${DISTDIR}/${LIBTOOL}.tar.gz ]
    then
        $WGETCMD -c http://ftp.gnu.org/gnu/libtool/${LIBTOOL}.tar.gz
    fi


    if [ ! -f ${DISTDIR}/${AUTOCONF}.tar.gz ]
    then
        $WGETCMD -c http://ftp.gnu.org/gnu/autoconf/${AUTOCONF}.tar.gz
    fi

fi

# Get all the required packages FOR STABLE VERSIONS
#if [ ! -f ${DISTDIR}/${PHP5}.tar.gz ]
#then
#    $WGETCMD -c http://us.php.net/get/${PHP5}.tar.gz/from/this/mirror/
#    mv index.html ${PHP5}.tar.gz
#fi

# Get all the required packages FOR LATEST

if [ "$WITHOUT_PHP" != "true" ] ; then
if [ ! -f ${DISTDIR}/${PHP5}.tar.gz ]
then
    rm -rf ${DISTDIR}/${PHP5_BASE_VERSION}*
    $WGETCMD -O ${DISTDIR}/${PHP5}.tar.gz -c http://snaps.php.net/${PHP5}.tar.gz
fi
fi

if [ "$WITHOUT_XDEBUG" != "true" ] ; then
if [ ! -f ${DISTDIR}/${XDEBUG}.tgz ]
then
    $WGETCMD -c http://xdebug.org/files/${XDEBUG}.tgz
fi
fi

if [ "$WITHOUT_APC" != "true" ] ; then
if [ ! -f ${DISTDIR}/${APC}.tgz ]
then
    $WGETCMD -c http://pecl.php.net/get/${APC}.tgz
fi
fi

# FOR PHP 5.3 branch
#if [ ! -f ${DISTDIR}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch ]
#then
#    $WGETCMD -O ${DISTDIR}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch -c http://bugs.php.net/patch-display.php\?bug_id\=54736\&patch\=debian_patches_disable_SSLv2_for_openssl_1_0_0.patch\&revision\=1305414559\&download\=1
#fi

echo ---------- Unpacking downloaded archives. This process may take several minutes! ----------

cd ${SRCDIR}

# Unpack them all

if [ "$STARTWITHPHP" != "true" ] ; then

    echo Extracting ${CURL}...
    tar xzf ${DISTDIR}/${CURL}.tar.gz
    echo Done.

    echo Extracting ${M4}...
    tar xzf ${DISTDIR}/${M4}.tar.gz
    echo Done.


    echo Extracting ${CCLIENT}...
    uncompress -cd ${DISTDIR}/${CCLIENT}.tar.Z |tar x
    echo Done.

    echo Extracting ${OPENSSL}...
    uncompress -cd ${DISTDIR}/${OPENSSL}.tar.gz |tar x
    echo Done.

    echo Extracting ${LIBMCRYPT}...
    tar xzf ${DISTDIR}/libmcrypt-${LIBMCRYPT}.tar.gz
    echo Done.

    echo Extracting ${LIBTOOL}...
    tar xzf ${DISTDIR}/${LIBTOOL}.tar.gz
    echo Done.

    echo Extracting ${AUTOCONF}...
    tar xzf ${DISTDIR}/${AUTOCONF}.tar.gz
    echo Done.
fi

if [ "$WITHOUT_PHP" != "true" ] ; then
echo Extracting ${PHP5}...
tar xzf ${DISTDIR}/${PHP5}.tar.gz
mv ${SRCDIR}/${PHP5_BASE_VERSION}* ${SRCDIR}/${PHP5}
echo Done.
fi

if [ "$WITHOUT_XDEBUG" != "true" ] ; then
echo Extracting ${XDEBUG}...
tar xzf ${DISTDIR}/${XDEBUG}.tgz
echo Done.
fi

if [ "$WITHOUT_APC" != "true" ] ; then
echo Extracting ${APC}...
tar xzf ${DISTDIR}/${APC}.tgz
echo Done.
fi

# Build them in the required order to satisfy dependencies

if [ "$STARTWITHPHP" != "true" ] ; then

    #cURL
    echo ###################
    echo Compile CURL
    echo ###################
    cd ${SRCDIR}/${CURL}
    ./configure --enable-ipv6 --enable-cookies \
    --enable-crypto-auth --prefix=${INSTALLDIR}
    make clean
    make
    make install

    #M4
    echo ###################
    echo Compile M4
    echo ###################
    cd ${SRCDIR}/${M4}
    ./configure --prefix=${INSTALLDIR}
    make clean
    make
    make install

    #CCLIENT
    echo ###################
    echo Compile CCLIENT
    echo ###################
    cd ${SRCDIR}/${CCLIENT_DIR}
    make ldb
    # Install targets are for wusses!
    cp c-client/c-client.a ${INSTALLDIR}/lib/libc-client.a
    cp c-client/*.h ${INSTALLDIR}/include

    #OPENSSL
    echo ###################
    echo Compile OPENSSL
    echo ###################
    # openssl
    cd ${SRCDIR}/${OPENSSL_DIR}
    ./config --prefix=${INSTALLDIR} no-ssl2
    make
    make install

    #LIBMCRYPT
    echo ###################
    echo Compile LIBMCRYPT
    echo ###################
    cd ${SRCDIR}/libmcrypt-${LIBMCRYPT}
    ./configure --disable-posix-threads --prefix=${INSTALLDIR}
    # make clean
    make
    make install

    #LIBTOOL
    echo ###################
    echo Compile LIBTOOL
    echo ###################
    cd ${SRCDIR}/${LIBTOOL}
    ./configure --prefix=${INSTALLDIR}
    make clean
    make
    make install

    #AUTOCONF
    echo ###################
    echo Compile AUTOCONF
    echo ###################
    cd ${SRCDIR}/${AUTOCONF}
    ./configure --prefix=${INSTALLDIR}
    # make clean
    make
    make install

fi

if [ "$WITHOUT_PHP" != "true" ] ; then
#PHP 5
echo ###################
echo Compile PHP
echo ###################
cd ${SRCDIR}/${PHP5}
# For 5.3 branch only
#patch -p1 < ${DISTDIR}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
./configure ${PHPFEATURES}
# make clean
make
make install

# Copy a basic configuration for PHP
mkdir -p ${INSTALLDIR}/etc/php5/configs
cp ${SRCDIR}/${PHP5}/php.ini-production ${INSTALLDIR}/etc/php5/configs/php.ini
fi

if [ "$WITHOUT_XDEBUG" != "true" ] ; then
# XDEBUG
echo ###################
echo Compile XDEBUG
echo ###################
cd ${SRCDIR}/${XDEBUG}
export PHP_AUTOHEADER=${INSTALLDIR}/bin/autoheader
export PHP_AUTOCONF=${INSTALLDIR}/bin/autoconf
echo $PHP_AUTOHEADER
echo $PHP_AUTOCONF
${INSTALLDIR}/bin/phpize
./configure --enable-xdebug --with-php-config=${INSTALLDIR}/bin/php-config --prefix=${INSTALLDIR}
# make clean
make
mkdir -p ${INSTALLDIR}/extensions
cp modules/xdebug.so ${INSTALLDIR}/extensions

echo "zend_extension=${INSTALLDIR}/extensions/xdebug.so" >> ${INSTALLDIR}/etc/php5/configs/xdebug.ini
fi

if [ "$WITHOUT_APC" != "true" ] ; then
# APC
echo ###################
echo Compile APC
echo ###################
cd ${SRCDIR}/${APC}
${INSTALLDIR}/bin/phpize
./configure --enable-apc --enable-apc-mmap --with-php-config=${INSTALLDIR}/bin/php-config --

prefix=${INSTALLDIR}
# make clean
make
cp modules/apc.so ${INSTALLDIR}/extensions
echo "extension=${INSTALLDIR}/extensions/apc.so" >> ${INSTALLDIR}/etc/php5/configs/apc.ini
fi

# Copy PHP CGI
mkdir -p ${DOMAINTEMPLATE}/cgi-bin
chmod 0755 ${DOMAINTEMPLATE}/cgi-bin
cp ${INSTALLDIR}/bin/php-cgi ${DOMAINTEMPLATE}/cgi-bin/php.cgi
rm -rf $SRCDIR $DISTDIR

# Create .htaccess
if [ -f ${DOMAINTEMPLATE}/.htaccess ]
    then
    echo #
    echo '#####################################################################'
    echo ' Your domain already has a .htaccess, it is ranamed .htaccess_old    '
    echo '               --> PLEASE FIX THIS PROBLEM <--                       '
    echo '#####################################################################'
    echo #
    mv ${DOMAINTEMPLATE}/.htaccess ${DOMAINTEMPLATE}/.htaccess_old
fi

echo 'Options +ExecCGI' >> ${DOMAINTEMPLATE}/.htaccess
echo 'AddHandler php-cgi .php' >> ${DOMAINTEMPLATE}/.htaccess
echo 'Action php-cgi /cgi-bin/php.cgi' >> ${DOMAINTEMPLATE}/.htaccess
echo '' >> ${DOMAINTEMPLATE}/.htaccess
echo '<FilesMatch "^php5?\.(ini|cgi)$">' >> ${DOMAINTEMPLATE}/.htaccess
echo 'Order Deny,Allow' >> ${DOMAINTEMPLATE}/.htaccess
echo 'Deny from All' >> ${DOMAINTEMPLATE}/.htaccess
echo 'Allow from env=REDIRECT_STATUS' >> ${DOMAINTEMPLATE}/.htaccess
echo '</FilesMatch>' >> ${DOMAINTEMPLATE}/.htaccess

echo ---------- INSTALL COMPLETE! ----------
echo
echo 'Configuration files:'
echo "1) General PHP -> ${INSTALLDIR}/etc/php5/configs/php.ini"
echo "2) Xdebug conf -> ${INSTALLDIR}/etc/php5/configs/xdebug.ini"
echo "3) APC conf -> ${INSTALLDIR}/etc/php5/configs/apc.ini"
echo
echo 'You have to modify these files in order to enable Xdebug or APC features.'

exit 0
