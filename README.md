php-for-shared-hosting
======================

PHP installation script for shared hostings (you can manually build and install PHP 5, PHP 5.4, PHP 5.5, latest PHP from repository to Dreamhost, TimeWeb, etc)

Download this script, chmod a+x it and run. It should "just work".

Credits
=======

Originally it was php5.4-install.sh from http://wiki.dreamhost.com/Installing_PHP5

I changed a few lines, take a look at the revision history.

License
=======

http://www.apache.org/licenses/LICENSE-2.0

Revision history:
==================
```
 2013-10-08 by Oleg Chirukhin (olegchir.com, olegchiruhin@gmail.com)
           Apache License, Version 2.0,
           upgraded to the latest PHP version, 
           updated dependencies (except OpenSSL), 
           new command line options: --resume (skip base libs: it should be already compiled), --without-php, --without xdebug, --without-apc,
           raised wget redirect limit (for Sourceforge), disabled SSL checking for download servers,
           no-ssl2 patch for PHP from debian butracker for 5.3 branch and no-ssl2 configure option for modern branches, 
           single PHP instance for all domains (template stored in ~/opt/php-latest/domain-template),
           TimeWeb hosting support
 2013-08-09 by Graham [http://blog.ham1.co.uk/] for latest PHP 5.4 and APC 3.1.13.
 2013-05-02 by Krishna Desai (http://krishnadesai.com) for latest version of libmcrypt
 2012-10-05 by Leonid Komarovsky (http://leonid.komarovsky.info) for PHP 5.4 and latest version of Xdebug. Added PostgreSQL support.
 2011-12-01 by David (deceifermedia.com) for latest package versioins, updated download links,
      and for the MySQLi and PDO extensions to use mysqlnd instead of libmysql (highly recommended)
 2010-07-03 by Andres (andrew67.com) for latest php, curl and openssl versions and enabling perl/pecl
 2009-12-27 by Steven Rosato to fix PHP 5.3 Compile Error: Undefined References in dns.c
 2009-09-24 by Christopher (heavymark.com) for latest source versions and incorrect url and addition of proper enabling of xmlrpc.
 2009-08-05 by Andy (andy.hwang.tw) to correct typo on m4 extract command.
 2009-07-28 by samutz (samutz.com) to include ZIP, XMLRPC,
          and GNU M4 (previous version of script failed without it)
 2009-07-24 by ercoppa (ercoppa.org) to convert this script for PHP 5.3 (with all features of dreamhost,
          except kerberos) with Xdebug and APC
 2009-05-24 by ksmoe to correct copying of correct PHP cgi file (php-cgi instead of php)
 2009-04-25 by Daniel (whathuhstudios.com) for latest source versions
 2007-11-24 by Andrew (ajmconsulting.net) to allow 3rd wget line to pass 
          MCRYPT version information (was set as static download file name previously.)
 2006-12-25 by Carl McDade (hiveminds.co.uk) to allow memory limit and freetype
```
