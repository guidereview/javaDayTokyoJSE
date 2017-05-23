#!/bin/bash

# APM Startup Wrapper for ACCS
# For use with post-provisioned APM agent folder in APM_AGENT_HOME
echo "&&& Start apm_wrapper.sh ...<<<"
	PROJECT_HOME=`pwd`	
echo ">>> PROJECT_HOME:${PROJECT_HOME}"
	TOMCAT_VERSION=8.5.11
	TOMCAT_DIST=apache-tomcat-${TOMCAT_VERSION}	
	APM_AGENT_HOME=${PROJECT_HOME}/${TOMCAT_DIST}/apmagent	
echo ">>> APM_AGENT_HOME:${APM_AGENT_HOME}"

	APM_PROP_FILE=${APM_AGENT_HOME}/config/AgentStartup.properties	
echo ">>> APM_PROP_FILE:${APM_PROP_FILE}"

# Replace properties with hardcoded paths. First delete the "pathTo" properties
# then add them back in with the correct paths from APM_AGENT_HOME
echo "&&& Replace Properties to APM_PROP_FILE...<<<"
echo ">>> oracle.apmaas.common.pathTo/d"
	sed "/oracle.apmaas.common.pathTo/d" -i.orig ${APM_PROP_FILE}

echo ">>> oracle.apmaas.agent.hostname/d"
	sed "/oracle.apmaas.agent.hostname/d" -i.orig ${APM_PROP_FILE}

echo ">>> oracle.apmaas.agent.ignore.hostname/d"
	sed "/oracle.apmaas.agent.ignore.hostname/d" -i.orig ${APM_PROP_FILE}

echo ">>> oracle.apmaas.common.pathToCertificate = ${APM_AGENT_HOME}/config/emcs.cer"
	echo "oracle.apmaas.common.pathToCertificate = ${APM_AGENT_HOME}/config/emcs.cer" >> ${APM_PROP_FILE}

echo ">>> oracle.apmaas.common.pathToCredentials = ${APM_AGENT_HOME}/config/AgentHttpBasic.properties"
	echo "oracle.apmaas.common.pathToCredentials = ${APM_AGENT_HOME}/config/AgentHttpBasic.properties" >> ${APM_PROP_FILE}

echo ">>> oracle.apmaas.agent.ignore.hostname = true"
	echo "oracle.apmaas.agent.ignore.hostname = true" >> ${APM_PROP_FILE}

echo ">>> ls -l ${APM_AGENT_HOME}/config"
	ls -l ${APM_AGENT_HOME}/config

echo ">>> cat ${APM_PROP_FILE}"
	cat ${APM_PROP_FILE}

echo ">>> Export CATALINA_OPTS"
export CATALINA_OPTS="-javaagent:${APM_AGENT_HOME}/lib/system/ApmAgentInstrumentation.jar"
#export JAVA_OPTS="-javaagent:${APM_AGENT_HOME}/lib/system/ApmAgentInstrumentation.jar"

echo ">>> Set APM LOG Folder Path"
# Optional, sets up APM logs and tails them out
	APM_LOG_DIR=${APM_AGENT_HOME}/logs/tomcat_instance
echo ">>> APM_LOG_DIR=${APM_LOG_DIR}"

echo ">>> Create APM LOG Folder"
	mkdir -p ${APM_LOG_DIR}
	pushd .
	
echo ">>> Touch APM LOGS"
	cd ${APM_LOG_DIR}

echo ">>> Touch AgentErrors.log AgentStartup.log"
	touch AgentErrors.log AgentStartup.log
	# touch Agent.log AgentStatus.log
	popd
	
echo ">>> TAIL All APM LOGS"
	tail -F ${APM_AGENT_HOME}/logs/tomcat_instance/*.log &

echo "+++>>> PROJECT_HOME:${PROJECT_HOME}"
echo "+++>>> APP_HOME:${APP_HOME}"
echo "+++>>> CATALINA_BASE:${CATALINA_BASE}"
echo "+++>>> CATALINA_HOME:${CATALINA_HOME}"
echo "+++>>> CATALINA_OPTS: ${CATALINA_OPTS}"
echo "+++>>> APM_AGENT_HOME:: ${APM_AGENT_HOME}"
echo "+++>>> APM_PROP_FILE::${APM_PROP_FILE}"
echo "+++>>> APM_LOG_DIR:${APM_LOG_DIR}"

echo ">>> p_w_d"
	pwd
echo ">>> Launch first parameter as script, passing remaining parmaters as args to that script"
# Launch first parameter as script, passing remaining parmaters as args to that script
echo ">>> First:EXEC_BINARY=$1"
	EXEC_BINARY="$1"
echo ">>> SHIFT"
	shift
echo ">>> SECOND:exec $EXEC_BINARY $@"
	exec "$EXEC_BINARY" "$@"
echo ">>> END ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"