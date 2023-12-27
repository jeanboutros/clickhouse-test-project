# Exploring ClickHouse
This Repository was created to explore ClickHouse.

For more info, check out the article on [Medium](https://medium.com/@jeanboutros)
## Running a ClickHouse Instance

```bash
# Start clickhouse
docker compose up -d
```

<aside>
💡 The docker image can be found on the official docker hub page with detailed instructions on how to run it: https://hub.docker.com/r/clickhouse/clickhouse-server/
</aside>

## If you want to end the session

```bash
# Stop clickhouse
docker compose stop
# Or to clean up
docker compose down --volumes
```

```bash
# Ensure you are in the project directory ClickhouseProject01
# Run the below only if you want to run a clean start
sudo rm -Rv ./clickhouse/*
```

## Ingest Data Into ClickHouse

In order to work with some test data, I have chosen to use the cell tower dataset provided by Clickhouse. 🔗 https://clickhouse.com/docs/en/getting-started/example-datasets/cell-towers

I have prepared a bash script that you can run. The script should download a compressed csv file, decompress it and finally ingest the data into our Clickhouse instance.

If you encounter any errors, you can add the flag `--skip-lock=true` but please report back to me any errors or challenges you encounter.

**Use the following command to execute the script:**

```bash
docker exec -t clickhouseproject01-clickhouse-1 /root/scripts/ingest_cell_tower_data.sh
```

## Testing Our ClickHouse Instance

Open the URL http://localhost:18123/play to test your installation. Make sure to use the `username` and `password` that we set in the `.clickhouse.dev.env` file.

![ClickHouse_HTTP_API](https://github.com/jeanboutros/clickhouse-test-project/assets/1816932/1b6f6759-6c29-48bc-ae18-731583a2dddb)

I installed DBeaver community edition to test it as well:

![DBeaver community edition](https://github.com/jeanboutros/clickhouse-test-project/assets/1816932/b858ce5c-eaa8-4a2a-9aa2-4eabfabd8303)

Alternatively you could use a terminal to connect to ClickHouse and use interactive mode to 
execute queries.

```bash
docker exec -it clickhouseproject01-clickhouse-1 clickhouse-client
```
