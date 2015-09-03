#!/bin/sh 
DEMO="Baggage Delivery Demo"
AUTHORS="Jason Milliron, Andrew Block, Eric D. Schabell"
PROJECT="git@github.com:jbossdemocentral/bpms-baggage-delivery-demo.git"
PRODUCT="JBoss BPM Suite"
JBOSS_HOME=./target/jboss-eap-6.4
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects
BPMS=jboss-bpmsuite-6.1.0.GA-installer.jar
EAP=jboss-eap-6.4.0-installer.jar
VERSION=6.1

# wipe screen.
clear 

echo
echo "#####################################################################"
echo "##                                                                 ##"   
echo "##  Setting up the ${DEMO}                           ##"
echo "##                                                                 ##"   
echo "##                                                                 ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####         ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #             ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###           ##"
echo "##     #   # #     #     #       # #   #   #     #   #             ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####         ##"
echo "##                                                                 ##"   
echo "##                                                                 ##"   
echo "##  brought to you by,                                             ##"   
echo "##       ${AUTHORS}            ##"
echo "##                                                                 ##"   
echo "##  ${PROJECT} ##"
echo "##                                                                 ##"   
echo "#####################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $EAP package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
		echo Product sources are present...
		echo
else
		echo Need to download $BPMS package from the Customer Portal 
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

# remove the old JBoss instance, if it exists.
if [ -x $JBOSS_HOME ]; then
		echo "  - existing JBoss product install removed..."
		echo
		rm -rf target
fi

# Run installers.
echo "JBoss EAP installer running now..."
echo
java -jar $SRC_DIR/$EAP $SUPPORT_DIR/installation-eap -variablefile $SUPPORT_DIR/installation-eap.variables

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP installation!
	exit
fi

echo
echo "JBoss BPM Suite installer running now..."
echo
java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables

if [ $? -ne 0 ]; then
	echo Error occurred during $PRODUCT installation!
	exit
fi

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/application-roles.properties $SERVER_CONF

echo "  - setting up demo projects..."
echo
cp -r $SUPPORT_DIR/bpm-suite-demo-niogit $SERVER_BIN/.niogit

echo "  - setting up zip code services..."
echo
#cp -r $SUPPORT_DIR/ZipCodeServices.war $SERVER_DIR
mvn clean install -f $PRJ_DIR/ZipCodeServices/pom.xml
cp $PRJ_DIR/ZipCodeServices/target/ZipCodeServices-1.0.war $SERVER_DIR

echo "  - setup email task notification users..."
echo
cp $SUPPORT_DIR/userinfo.properties $SERVER_DIR/business-central.war/WEB-INF/classes/

echo
echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

# Optional: uncomment this to install mock data for BPM Suite.
#
#echo - setting up mock bpm dashboard data...
#cp $SUPPORT_DIR/1000_jbpm_demo_h2.sql $SERVER_DIR/dashbuilder.war/WEB-INF/etc/sql
#echo

echo
echo "========================================================================"
echo "=                                                                      ="
echo "=  You can now start the $PRODUCT with:                         ="
echo "=                                                                      ="
echo "=   $SERVER_BIN/standalone.sh                           ="
echo "=                                                                      ="
echo "=  Login into business central at:                                     ="
echo "=                                                                      ="
echo "=    http://localhost:8080/business-central  (u:erics / p:bpmsuite1!)  ="
echo "=                                                                      ="
echo "=  See README.md for general details to run the various demo cases.    ="
echo "=                                                                      ="
echo "=  $PRODUCT $VERSION $DEMO Setup Complete.            ="
echo "=                                                                      ="
echo "========================================================================"
