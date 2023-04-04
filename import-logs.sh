LOG_BASE_DIR="~/logs/"
LOG_DB="~/logs/logs.db"

for i in $(seq 0 3); do
    ./sqlite-import.sh -i $LOG_BASE_DIR/kafka${i}.log -c kafka-${i} -t kafka -d ${LOG_DB} -f CFK
    ./sqlite-import.sh -i $LOG_BASE_DIR/zookeeper${i}.log -c zookeeper-${i} -t zookeeper -d ${LOG_DB} -f CFK
done

for i in $(seq 0 1); do
    ./sqlite-import.sh -i $LOG_BASE_DIR/schemaregistry${i}.log -c schema-${i} -t schema -d ${LOG_DB} -f CFK
    ./sqlite-import.sh -i $LOG_BASE_DIR/connect${i}.log -c connect-${i} -t connect -d ${LOG_DB} -f CFK
done
