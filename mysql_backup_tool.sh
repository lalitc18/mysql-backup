
#!/bin/bash
# MySQL backup script single/multilple databases backup.

read -p "Backup path [default current dir]: " BKP_PATH
BKP_PATH=${BKP_PATH:-`pwd`}
NOW="$(date +"%Y-%m-%d_%H-%M-%S")"
BKP_DIR="$BKP_PATH/$NOW"
read -p "Enter mysql hostname/IP [localhost]: " MYSQL_HOST
MYSQL_HOST=${MYSQL_HOST:-localhost}
read -p "Enter mysql username : " MYSQL_USER 
echo "Enter mysql password:" 
read -s MYSQL_PWD
read -p "Enter mysql port[3306]:" MYSQL_PORT
MYSQL_PORT=${MYSQL_PORT:-3306}

echo  "Take Backup of [Single DB: Enter 1 || All databases: Enter 2]: "
read  BKP_TYPE


function dbtable {

mkdir -p "$BKP_DIR"
touch "$BKP_DIR/backup.log"
echo "Dumping tables into separate SQL command files for database '$DATABASE' into dir=$BKP_DIR" >> $BKP_DIR/backup.log
tbl_count=0
for t in $(mysql -NBA -h $MYSQL_HOST  -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT -D $DATABASE -e 'show tables')
do

    (( tbl_count++ ))
   echo "DUMPING TABLE: $t" >> $BKP_DIR/backup.log
mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT --set-gtid-purged=OFF --single-transaction  $DATABASE $t | gzip > $BKP_DIR/$t.sql.gz

done

echo "$tbl_count tables dumped from database '$DATABASE' into dir=$BKP_DIR" >> $BKP_DIR/backup.log
echo "Dumping --triggers --routines --events for '$DATABASE' into dir=$BKP_DIR" >> $BKP_DIR/backup.log

mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT --set-gtid-purged=OFF --triggers --routines --events --no-create-info --no-data --no-create-db --skip-opt $DATABASE | gzip > $BKP_DIR/routines.sql.gz

echo "$table_count tables dumped into dir=$BKP_DIR" >> $BKP_DIR/backup.log

echo "Backup Completed at $(date) to backup location $BKP_DIR"
                 }


function alldbs {

mkdir -p "$BKP_DIR"
touch "$BKP_DIR/backup.log"

echo "Dumping MySQL databases into separate SQL command files into dir=$BKP_DIR" >> $BKP_DIR/backup.log

db_count=0

for d in $(mysql -NBA -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT -e 'show databases')
do
   if [[ "$d" != information_schema ]] && [[ "$d" != mysql ]] && [[ "$d" !=  performance_schema ]] && [[ "$d" !=  sys ]]; then
    (( db_count++ ))
   echo "DUMPING DATABASE: $d " >> $BKP_DIR/backup.log
mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT --set-gtid-purged=OFF  --single-transaction   $d | gzip > $BKP_DIR/$d.sql.gz
echo "Dumping --triggers --routines --events for databases $d into dir=$BKP_DIR" >> $BKP_DIR/backup.log
mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD -P$MYSQL_PORT --set-gtid-purged=OFF --triggers --routines --events --no-create-info --no-data --no-create-db --skip-opt $d | gzip > $BKP_DIR/$d-routines.sql.gz
  fi
done

echo "Backup Completed at $(date) to backup location $BKP_DIR"

echo "$db_count databases dumped into dir=$BKP_DIR" >> $BKP_DIR/backup.log

}
if [[ $BKP_TYPE == 1 ]]; then

read -p "Enter databases name for backup:" DATABASE
dbtable

else

alldbs

fi

# End of the script
