# log-analysis-sqlite - scripting tools for simple log analysis with Python and SQLite
This is a small script using [sqlite-utils](https://sqlite-utils.datasette.io/en/stable/) to import logs into sqlite.
It is inspired by the blog post from [Jeqo](https://jeqo.github.io/notes/2022-09-24-ingest-logs-sqlite/) and was extended to parse logs from Confluent-for-Kubernetes.

I modified the regexp to analyze the CFK-based logs.
So far these 2 regular expressions are supported - feel free to add more:
- Java log4j: https://regex101.com/r/2AxwfE/1
- Confluent-for-Kubernetes: https://regex101.com/r/pMzqPU/1

Usage example:
`./sqlite-import.sh -i ./logs/kafka0.log -c kafka-0 -t kafka -f CFK -d ./logs.db`

A wrapper-script example is provided as `sqlite-import.sh` and some simple analysis statement can be found in `sqlite-examples.sql`.
