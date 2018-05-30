-- Change it to your sys user and password
conn sysuser/syspassword@sid as sysdba
select max(sequence#) a from v$log_history where FIRST_TIME > SYSDATE -1;
exit
