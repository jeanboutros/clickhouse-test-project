#!/bin/bash 

cd /root/scripts

# check if parameter --skip-lock=true is set and .lock file exists
if [ -f .lock ] &&[ "$1" == "--skip-lock=true" ]; then
    # echo in bold yellow skip lock
    echo -e "\033[1;33mSkiping lock\033[0m"
    rm -f .lock
fi


if [ -f .lock ]; then
    echo -e "\033[1;31mScript was already run. If you want to run it again, remove .lock file.\033[0m"
    exit 1
else
    touch .lock
fi

apt-get update
apt-get install -y wget xz-utils

echo -ne "\033[1;32m👀 Looking for cell_towers.csv.xz\033[0m"

# if cell_towers.csv.xz does not exist or is older than 1 day, download it
if [ ! -f cell_towers.csv ] || [ cell_towers.csv -ot $(date -d "1 day ago" '+%Y-%m-%d') ]; then
    echo -e "\033[1;32m ... ✅ Done and not found! 🥴\033[0m"
    echo -ne "\033[1;32mDownloading cell_towers.csv.xz\033[0m"
    wget https://datasets.clickhouse.com/cell_towers.csv.xz
    echo -e "\033[1;32m ... ✅ Done.\033[0m"

    echo -ne "\033[1;32mUnpacking cell_towers.csv.xz\033[0m"
    xz -f -d cell_towers.csv.xz
    echo -e "\033[1;32m ... ✅ Done.\033[0m"
else
    echo -e "\033[1;33m ... 😍 cell_towers.csv.xz is up to date\033[0m"
fi

echo -ne "\033[1;32mDropping table cell_towers inside clickhouse_db database if it exists.\033[0m"
clickhouse-client --database="clickhouse_db" --query="DROP TABLE IF EXISTS cell_towers SYNC;"
echo -e "\033[1;32m ... ✅ Done.\033[0m"

echo -ne "\033[1;32mCreating table cell_towers inside clickhouse_db database\033[0m"

read -r -d '' CREATE_TABLE_DDL <<- EOM
CREATE TABLE cell_towers
(
    radio Enum8('' = 0, 'CDMA' = 1, 'GSM' = 2, 'LTE' = 3, 'NR' = 4, 'UMTS' = 5),
    mcc UInt16,
    net UInt16,
    area UInt16,
    cell UInt64,
    unit Int16,
    lon Float64,
    lat Float64,
    range UInt32,
    samples UInt32,
    changeable UInt8,
    created DateTime,
    updated DateTime,
    averageSignal UInt8
)
ENGINE = MergeTree ORDER BY (radio, mcc, net, created)
EOM

clickhouse-client --database="clickhouse_db" --query="$CREATE_TABLE_DDL"
echo -e "\033[1;32m ... ✅ Done.\033[0m"

echo -ne "\033[1;32mInserting data into cell_towers table\033[0m"
clickhouse-client --database="clickhouse_db" --query "INSERT INTO cell_towers FORMAT CSVWithNames" < cell_towers.csv
echo -e "\033[1;32m ... ✅ Done.\033[0m"

N_RECORDS=$(clickhouse-client --database="clickhouse_db" --query="select count(*) from clickhouse_db.cell_towers;")
echo -e "\033[1;32m👾 Number of records in cell_towers table: $N_RECORDS 🚀\033[0m"

echo -e "\033[1;32m🗑️ Removing temporary files\033[0m"
echo -ne "\033[1;33m❌ Deleting cell_towers.csv.xz\033[0m"
rm -f cell_towers.csv.xz
echo -e "\033[1;32m ... ✅ Done.\033[0m"

echo -ne "\033[1;33m❌ Deleting cell_towers.csv\033[0m"
rm -f cell_towers.csv
echo -e "\033[1;32m ... ✅ Done.\033[0m"

# All done!
echo -e "\033[1;32mDone ... Bye bye 👋🏻\033[0m"

# Don't remove the .lock file to prevent running the script again