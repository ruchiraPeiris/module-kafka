// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/log;
import ballerina/runtime;
import ballerina/internal;
import ballerina/task;
import wso2/kafka;

kafka:ConsumerConfig consumerConfigs = {
    bootstrapServers:"localhost:9092",
    groupId:"group-id",
    offsetReset:"earliest",
    autoCommit:false
};

kafka:SimpleConsumer consumer = new(consumerConfigs);

public function main(string... args) {
    // Here we initializes a consumer which connects to remote cluster.
    var conError = consumer->connect();

    // We subscribes the consumer to topic test-kafka
    string[] topics = ["test-kafka-topic"];
    //var subErr = consumer -> subscribe(topics);

    function(kafka:SimpleConsumer simpleConsumer, kafka:TopicPartition[] partitions) onAssigned = printAssignedPartitions;
    function(kafka:SimpleConsumer simpleConsumer, kafka:TopicPartition[] partitions) onRevoked = printRevokedPartitions;

    var subErr = consumer->subscribeWithPartitionRebalance(topics, onRevoked, onAssigned);
    if (subErr is error) {
        log:printError("Error occurred while subscribing", err = e);
        return;
    }

    // Consumer poll() function will be called every time the timer goes off.
    function () onTriggerFunction = poll;

    // Consumer pollError() error function will be called if an error occurs while consumer poll the topics.
    function (error e) onErrorFunction = pollError;

    // Schedule a timer task which initially starts poll cycle in 500ms from now and there
    //onwards runs every 2000ms.
    //var taskId, schedulerError = task:scheduleTimer(onTriggerFunction, onErrorFunction, {delay:500, interval:2000});
    task:Timer timer = new(onTriggerFunction, onErrorFunction, 2000, delay = 500);
    timer.start();

    runtime:sleep(30000); // Temporary workaround to stop the process from exiting.
}

function poll() {
    var results = consumer->poll(1000);
    if (results is error) {
        log:printError("Error occurred while polling ", err = results);
    } else {
        foreach kafkaRecord in results {
            processKafkaRecord(kafkaRecord);
        }
    }
    consumer->commit();
}

function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    byte[] serializedMsg = kafkaRecord.value;
    string msg = internal:byteArrayToString(serializedMsg, "UTF-8");
    // Print the retrieved Kafka record.
    io:println("Topic: " + kafkaRecord.topic + " Received Message: " + msg);
}

function pollError(error e) {
    // Exception occurred while polling the Kafka consumer. Here we close close consumer and log error.
    var closeError = consumer->close();
    log:printError("Error occurred while polling ", err = e);
}

function printAssignedPartitions(kafka:SimpleConsumer consumer, kafka:TopicPartition[] partitions) {
    io:println("Number of partitions assigned to consumer: " + lengthof partitions);
}

function printRevokedPartitions(kafka:SimpleConsumer consumer, kafka:TopicPartition[] partitions) {
    io:println("Number of partitions revoked from consumer: " + lengthof partitions);
}
