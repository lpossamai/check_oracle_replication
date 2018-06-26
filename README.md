#
# Check Oracle Replication
#

This script will check if a Standby Oracle DB is successfully applying the archiving logs.
If the difference between DB1 and DB2 is > than 20, it'll send you an email.

More about Oracle Archiving Logs: http://www.dba-oracle.com/concepts/archivelog_archived_redo_logs.htm

NOTE: Tested in an Oracle 11G Standard instance.
