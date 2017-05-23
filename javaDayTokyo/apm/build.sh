#!/bin/bash

# Build script to build WAR and move create Tomcat server w/ APM agent

# Make sure that the following environment varibles are set:
#   AGENTINSTALL_ZIP_URL
#   AGENT_REGISTRATION_KEY
# It's recommended that you put the AgentInstall.zip you get from the
# OMC tenant into the Maven tenant and use the URL to the artifact.

echo ">>>Start Build.sh ...<<<"
	pwd
	ls -a
	MAVEN_PROJECT_DIR=`pwd`
echo ">>>MAVEN_PROJECT_DIR=${MAVEN_PROJECT_DIR}"
	ls -a
	MAVEN_PROJECT_WAR=target/${WAR_FILE}.original
echo ">>>MAVEN_PROJECT_WAR=${MAVEN_PROJECT_WAR}"

echo ">>>Start Prepare Download TOMCAT ...<<<"
	TOMCAT_VERSION=8.5.11
	TOMCAT_DIST=apache-tomcat-${TOMCAT_VERSION}
TOMCAT_DL_URL="http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz"
echo ">>>TOMCAT_VERSION:${TOMCAT_VERSION}"
echo ">>>TOMCAT_DIST:${TOMCAT_DIST}"
echo ">>>TOMCAT_DL_URL:${TOMCAT_DL_URL}"
	cd ..
	APP_HOME=`pwd`
	cd ${MAVEN_PROJECT_DIR}
echo ">>>APP_HOME:${APP_HOME}"
	ls -a

echo ">>>Start Check WAR file ...<<<"
echo ">>>WAR_FILE: ${WAR_FILE}"
	if [[ -z ${WAR_FILE} ]]; then
	  echo "Make sure that WAR_FILE is set"
	  exit 1
	fi

# Setup proxy
echo ">>>Start SETUP PROXY ...<<<"
	if [ -n "$HTTP_PROXY" ]; then
	  echo "HTTP Proxy is set to ${HTTP_PROXY}"
	  PROXY_ARG="--proxy ${HTTP_PROXY}"
	  export http_proxy=${HTTP_PROXY}
	  export https_proxy=${HTTP_PROXY}
	  echo ">>>PROXY_ARG: ${PROXY_ARG}"
	  echo ">>>http_proxy: ${http_proxy}"
	  echo ">>>https_proxy: ${https_proxy}"
	fi

# Check APM Agent Env Prerequisites
echo ">>>Start Check APM Agent Env...<<<"
echo ">>>AGENTINSTALL_ZIP_URL: ${AGENTINSTALL_ZIP_URL}"
echo ">>>APMSTAGE_ZIP_URL: ${APMSTAGE_ZIP_URL}"
	if [[ -z ${AGENTINSTALL_ZIP_URL} ]] && [[ -z ${APMSTAGE_ZIP_URL} ]]; then
	  echo "Make sure AGENTINSTALL_ZIP_URL or APMSTAGE_ZIP_URL are set"
	  exit 1
	fi

# Check APM Agent Registration Key
echo ">>>Start Check APM Agent Registration Key...<<<"
echo ">>>AGENT_REGISTRATION_KEY: ${AGENT_REGISTRATION_KEY}"
	if [[ -z ${AGENT_REGISTRATION_KEY} ]]; then
	  echo "Make sure AGENT_REGISTRATION_KEY is set"
	  exit 1
	fi

# Clean up any artifacts left from previous builds
echo ">>>Start Cleanup Any Artifacts Left From Previous Builds...<<<"
	rm -rf tomcat-Treadmill-dist.zip
	rm -rf ${TOMCAT_DIST}

# Start MKDIR agent_stage Folder in apm folder
echo ">>>MKDIR agent_stage Folder in apm folder"
	mkdir agent_stage
	pushd .

echo ">>>Route into agent_stage"
	cd agent_stage

echo ">>>Check The APMSTAGE_ZIP_URL Exiting ...<<"
# If we provided an APMSTAGE URL, use that, otherwise use AgentInstall.sh
	if [[ ${APMSTAGE_ZIP_URL} ]]; then
echo ">>>Condition One: APMSTAGE_ZIP_URL Exit"
echo ">>>1.Download the APMSTAGE_ZIP_URL As apm_stage.zip;2.Unzip apm_stage.zip"
		curl -o apm_stage.zip "${APMSTAGE_ZIP_URL}"
		unzip apm_stage.zip
	else
echo ">>>Condition Two: APMSTAGE_ZIP_URL Not Exit"
echo "Start Download AgentInstall.zip ........."
echo ">>>AGENTINSTALL_ZIP_URL :${AGENTINSTALL_ZIP_URL}"  
echo ">>>1.Download the AGENTINSTALL_ZIP_URL As AgentInstall.zip into agent_stage folder;2.Unzip AgentInstall.zip"
echo ">>>Start Downloading AgentInstall.zip...<<<"
		curl -o AgentInstall.zip "${AGENTINSTALL_ZIP_URL}"
echo ">>>Unzip AgentInstall.zip"
		chmod a+rx AgentInstall.zip
 		unzip AgentInstall.zip
 		jar xvf AgentInstall.zip
		chmod a+rx AgentInstall.sh
echo ">>>Start Install AgentInstall.sh .....<<<"
echo ">>>Install Into apm_stage folder"
		./AgentInstall.sh AGENT_TYPE=apm STAGE_LOCATION=apm_stage AGENT_REGISTRATION_KEY="${AGENT_REGISTRATION_KEY}"
	fi

echo ">>>Set APM_AGENT_STATGE"
	cd apm_stage
	APM_AGENT_STATGE=`pwd`
echo ">>>APM_AGENT_STATGE:${APM_AGENT_STATGE}"

echo ">>>Start Provise Apm Java As Agent ... <<<"
	chmod a+rx ProvisionApmJavaAsAgent.sh

echo ">>>Provise to APP_HOME --- javaDayTokyo/apm"
	echo "yes" | ./ProvisionApmJavaAsAgent.sh -no-wallet -d "${MAVEN_PROJECT_DIR}"
	popd

echo ">>>APM Agent Customizing - Exclude CXFServlet"
echo ">>>Chmod the apm folders"
	chmod -R 777 ${APP_HOME}
# Any agent config customizations

echo ">>>APM Agent Customizing - Exclude CXFServlet -SED"
	##sed 's#\(excludedServletClasses\" \: \[ \)#\1\"org.apache.cxf.transport.servlet.CXFServlet\", #' -i "${APM_AGENT_STATGE}/apmagent/config/Servlet.json"
	sed 's#\(excludedServletClasses\" \: \[ \)#\1\"org.apache.cxf.transport.servlet.CXFServlet\", #' -i "${MAVEN_PROJECT_DIR}/apmagent/config/Servlet.json"
	
echo ">>>Start Build Project ...<<"
# Build the project
	pushd .
	
echo ">>>Route to MAVEN_PROJECT_DIR"
	cd ${APP_HOME}
	ls -a
	
echo ">>>MAVEN_PROJECT_DIR:${MAVEN_PROJECT_DIR}"
	mvn --version
	mvn clean package
	popd

echo ">>>Start DownLoad Tomcat ...<<"
# Download Tomcat distribution
	curl -X GET \
   		${PROXY_ARG} \
   		-o ${TOMCAT_DIST}.tar.gz \
   		"${TOMCAT_DL_URL}"
   		
echo ">>>Start Extract Tomcat ...<<"
# Extract Tomcat distribution
	tar -xf ${TOMCAT_DIST}.tar.gz

echo ">>> Define Tomcat Path"

echo ">>>Start Move project WAR to webapps in the Tomcat Folder ...<<<"
echo ">>>Remove the ROOT,Examples,docs folders in Tomcat webapps folder"
# Move project WAR to webapps dir as root deployment, removing default one
	rm -rf ${TOMCAT_DIST}/webapps/ROOT
	rm -rf ${TOMCAT_DIST}/webapps/examples
	rm -rf ${TOMCAT_DIST}/webapps/docs

echo ">>>Copy War file from MAVEN_PROJECT_DIR to TOMCAT_DIST-tomcat folder"
echo "1111"
	pwd
echo "222"
	ls -a
echo "333"
	cp ${APP_HOME}/${MAVEN_PROJECT_WAR} ${TOMCAT_DIST}/webapps/${WAR_FILE}

echo ">>>Chmod apm_wrapper.sh"
# Make sure wrapper has correct perms
	chmod a+rx apm_wrapper.sh

echo ">>>Mkdir apmagent folder into Tomcat folder"
# Create application archive with Tomcat (with Treadmill war) and manifest.json
	mkdir ${TOMCAT_DIST}/apmagent
	
echo ">>>Copy files in apmagent folder into Tomcat-apmagent folder"
	pwd
	ls -a
	echo "qqq"
	cd agent_stage
	pwd
	ls -a
	echo "www"
	cd apm_stage
	pwd
	ls -a
	echo "eee"
	cd apmagent
	pwd
	ls -a
	echo "rrr"
	cd config
	pwd
	ls -a
	echo "kkk"
	cd ${MAVEN_PROJECT_DIR}/agent_stage/apm_stage/apmagent
	echo "kkk1"
	ls -a
	echo "kkk2"
	cp -R ${MAVEN_PROJECT_DIR}/apmagent/* ${MAVEN_PROJECT_DIR}/${TOMCAT_DIST}/apmagent
	echo "kkk3"
	cp -R ${MAVEN_PROJECT_DIR}/apmagent/* ${MAVEN_PROJECT_DIR}/apmagent
	echo "kkk4"

###mkdir apmagent
###cp -R agent_stage/apm_stage/apmagent/* apmagent
	cd ${MAVEN_PROJECT_DIR}
	pwd
	ls -a
	cd apmagent
	pwd
	ls -a
	cd ${MAVEN_PROJECT_DIR}
	ls -a
echo ">>>Start Zip files :manifest.json ,TOMCAT_DIST,apmagent,apm_wrapper.sh"
	zip -r application.zip manifest.json ${TOMCAT_DIST} apmagent apm_wrapper.sh

echo ">>>Remove {TOMCAT_DIST} apmagent"
# Remove the expanded Tomcat distribution
	rm -rf ${TOMCAT_DIST} apmagent
