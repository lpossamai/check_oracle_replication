#!/bin/sh
#
#
#

# You need to have these paths setup otherwise script won't work.
export ORACLE_HOME=/your_oracle_home
export PATH=$PATH:/your_oracle_home/bin:/usr/sbin:/usr/bin
export ORACLE_SID=test
export ORACLE_BASE=/oracle_base

# uncomment the below line for debugging
#set -x

# Email function
email(){
  to="lucas@example.com";
  subject="WARNING: DB2 is NOT up-to-date with DB1";
  body="MESSAGE: \nDB2 is not up-to-date with DB1. \nLast Archiving log applied on DB1: $COUNT_DB1_2. \nLast Archiving log applied on DB2: $COUNT_DB2_2."
  echo -e "$body" | mail -s "WARNING: DB2 is NOT up-to-date with DB1" -aFrom:no-reply\<no-reply@example.com\> $to
}

# Getting the max(sequence) value from v$log_history
# output of "sqlplus / as sysdba @/home/oracle/lucas/check_replication_db1.sql | awk 'FNR>=13 && FNR<=13'"
# should only be the max sequence value
COUNT_DB1=$(sqlplus / as sysdba @/home/oracle/lucas/check_replication_db1.sql | awk 'FNR>=13 && FNR<=13')
COUNT_DB2=$(sqlplus / as sysdba @/home/oracle/lucas/check_replication_db2.sql | awk 'FNR>=14 && FNR<=14')

# It might take a while for DB2 apply the archiving logs
# so just warns me if the difference is higher than 20
# otherwise I assume the replication is working fine.
if ((${COUNT_DB1} - ${COUNT_DB2} < 20));
then
        echo "Replication is working..."
elif ((${COUNT_DB1} - ${COUNT_DB2} > 20));
then
# We double check the count again, before sending the emails
# If after the second count the difference is still > than 20, send an email.
# The sleep 120 is there so the DB2 has time to catch up with DB1.
        sleep 120
        COUNT_DB1_2=$(sqlplus / as sysdba @/home/oracle/lucas/check_replication_db1.sql | awk 'FNR>=13 && FNR<=13')
        COUNT_DB2_2=$(sqlplus / as sysdba @/home/oracle/lucas/check_replication_db2.sql | awk 'FNR>=14 && FNR<=14')
        if ((${COUNT_DB1_2} - ${COUNT_DB2_2} > 20)); then
                echo "WARNING: DB2 is NOT up-to-date with DB1"
                email # Calling the email function
        else
                echo "INFO: DB2 is now up-to-date with DB1"
        fi
fi
exit
