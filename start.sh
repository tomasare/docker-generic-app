#!/bin/bash

JAR=$(ls ${HOME}/*.jar | head -n1)
APP_NAME_FROM_JAR=$(echo $(basename $JAR) | sed 's/-[[:digit:]].*//g')

: ${APP_NAME=$APP_NAME_FROM_JAR}
: ${LOG_DIR=${HOME}/logs}
: ${LOGBACK_PATH=${HOME}/logback/logback.xml}
: ${JAVA_CLASSPATH=-cp ${HOME}/${JAR}:${HOME}/lib/*}
: ${JVM_XMS=512m}
: ${JVM_XMX=512m}
: ${JVM_METASPACE_SIZE=128M}
: ${JVM_MAX_METASPACE_SIZE=128M}
: ${JAVA_SECURITY_EGD=-Djava.security.egd=file:/dev/./urandom}
: ${CUSTOM_JAVA_OPTS=}
: ${APP_OPTS=-d}

export JAVA_OPTS="-server"
export JAVA_OPTS="${JAVA_OPTS} -Xms${JVM_XMS}"
export JAVA_OPTS="${JAVA_OPTS} -Xmx${JVM_XMX}"
export JAVA_OPTS="${JAVA_OPTS} -XX:MetaspaceSize=${JVM_METASPACE_SIZE}"
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxMetaspaceSize=${JVM_MAX_METASPACE_SIZE}"
export JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
export JAVA_OPTS="${JAVA_OPTS} -Dsun.rmi.dgc.client.gcInterval=3600000"
export JAVA_OPTS="${JAVA_OPTS} -Dsun.rmi.dgc.server.gcInterval=3600000"
export JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
export JAVA_OPTS="${JAVA_OPTS} -XX:HeapDumpPath=${LOG_DIR}"
export JAVA_OPTS="${JAVA_OPTS} -XX:+UseCompressedOops"
export JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"
export JAVA_OPTS="${JAVA_OPTS} -Dnet.sf.ehcache.skipUpdateCheck=true"
export JAVA_OPTS="${JAVA_OPTS} -Duser.home=${HOME}"
export JAVA_OPTS="${JAVA_OPTS} -Dlogback.configurationFile=${LOGBACK_PATH}"
export JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_DIR}/${APP_NAME}-gc.log"
export JAVA_OPTS="${JAVA_OPTS} -XX:+ExitOnOutOfMemoryError"
export JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDetails"
export JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCTimeStamps"
export JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDateStamps"
export JAVA_OPTS="${JAVA_OPTS} -Dapp=${APP_NAME}"
export JAVA_OPTS="${JAVA_OPTS} ${JAVA_CLASSPATH}"
export JAVA_OPTS="${JAVA_OPTS} ${JAVA_SECURITY_EGD}"
export JAVA_OPTS="${JAVA_OPTS} ${CUSTOM_JAVA_OPTS}"	 

if [[ ! -z ${DEBUG_PORT} ]]; then
   export JAVA_OPTS="${JAVA_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=${DEBUG_PORT}" 
fi

trap 'kill -TERM ${JVM_PID}' TERM INT

echo "java ${JAVA_OPTS} -jar ${JAR} ${APP_OPTS}"
java ${JAVA_OPTS} -jar ${JAR} ${APP_OPTS} &

JVM_PID=$!

wait ${JVM_PID}
exit $?