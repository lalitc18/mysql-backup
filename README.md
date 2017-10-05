MySQL_ALL_IN_ONE_BACKUP script will take single database or all database backup. 
Backup will be a logical backup taken by mysqldump tool.

This one is initial version of this script will add few options soon.

---------------
USAGE
--------------
Run ./mysql_backup_tool.sh

Enter Inputs:
1.Backup path [default current dir]: 
2.Enter mysql hostname/IP [localhost]:
3.Enter mysql username : 
4.Enter mysql password:
5.Enter mysql port[3306]:
6.Take Backup of [Single DB: Enter 1 || All databases: Enter 2]: 

--------------
OUTPUT
--------------
Selected Type of backup will be created in given Backup path.
Backup directory will have backup inside directory with current time-stamp.





