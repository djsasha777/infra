#!/bin/bash
#Scripts to start services if not running
ps -ef | grep nginx |grep -v grep > /dev/null
if [ $? != 0 ]
then
       /etc/init.d/nginx start > /dev/null
fi
ps -ef | grep php5-fpm |grep -v grep > /dev/null
if [ $? != 0 ]
then
       /etc/init.d/php5-fpm start > /dev/null
fi
ps -ef | grep mysql |grep -v grep > /dev/null
if [ $? != 0 ]
then
       /etc/init.d/mysql start > /dev/null 
fi
#Specify DMGR Path Here
DMGR=/opt/IBM/WebSphere/AppServer/profiles/Dmgr01
#Specify Profile Path Here
Profile=/opt/IBM/WebSphere/AppServer/profiles/AppSrv01
ps -ef | grep dmgr |grep -v grep > /dev/null
if [ $? != 0 ]
then
       $DMGR/bin/startManager.sh > /dev/null
fi
ps -ef | grep nodeagent |grep -v grep > /dev/null
if [ $? != 0 ]
then
       $Profile/bin/startNode.sh > /dev/null
fi
ps -ef | grep server1 |grep -v grep > /dev/null
if [ $? != 0 ]
then
       $Profile/bin/startServer.sh server1 > /dev/null
fi


## use cronetab 
## crontab
## */5 * * * * ~/startwasifdown.sh 