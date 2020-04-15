#!/bin/bash
# --------------------------------------------------------------
# Include JAR Files
# --------------------------------------------------------------

cd /opt/OpenIMSCore/FHoSS/deploy
JAVA_HOME="/usr/lib/jvm/jdk1.7.0_80"
CLASSPATH="/usr/lib/jvm/jdk1.7.0_80/jre/lib/"
echo "Building Classpath"
CLASSPATH=$CLASSPATH:log4j.properties:.
for i in lib/*.jar; do CLASSPATH="$i":"$CLASSPATH"; done
echo "Classpath is $CLASSPATH."

# --------------------------------------------------------------
# Start-up
# --------------------------------------------------------------

$JAVA_HOME/bin/java -cp $CLASSPATH de.fhg.fokus.hss.main.HSSContainer $1 $2 $3 $4 $5 $6 $7 $8 $9
