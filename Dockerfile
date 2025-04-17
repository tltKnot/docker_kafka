FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

ARG KAFKA_VERSION=4.0.0
ARG SCALA_VERSION=2.13
RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz && \
    tar -xzf /tmp/kafka.tgz -C /opt && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka && \
    rm /tmp/kafka.tgz

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Создаем конфигурацию
RUN mkdir -p $KAFKA_HOME/config/kraft && \
    echo "process.roles=broker,controller" > $KAFKA_HOME/config/kraft/server.properties && \
    echo "node.id=1" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "controller.quorum.voters=1@localhost:9093" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "listeners=PLAINTEXT://:9092,CONTROLLER://:9093" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "advertised.listeners=PLAINTEXT://localhost:9092" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "controller.listener.names=CONTROLLER" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "inter.broker.listener.name=PLAINTEXT" >> $KAFKA_HOME/config/kraft/server.properties && \
    echo "log.dirs=/tmp/kraft-combined-logs" >> $KAFKA_HOME/config/kraft/server.properties

# Форматируем storage
RUN mkdir -p /tmp/kraft-combined-logs && \
    KAFKA_CLUSTER_ID=$($KAFKA_HOME/bin/kafka-storage.sh random-uuid) && \
    echo "Generated Cluster ID: $KAFKA_CLUSTER_ID" && \
    $KAFKA_HOME/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c $KAFKA_HOME/config/kraft/server.properties

EXPOSE 9092 9093

CMD ["sh", "-c", "$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/kraft/server.properties"]
