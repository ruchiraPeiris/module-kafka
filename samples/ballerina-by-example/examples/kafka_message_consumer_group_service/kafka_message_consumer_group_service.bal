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

import wso2/kafka;
import ballerina/io;
import ballerina/internal;

kafka:ConsumerConfig consumerConfigs = {
    bootstrapServers: "localhost:9092",
    concurrentConsumers: 2,
    groupId: "group-id",
    topics: ["test-kafka-topic"],
    pollingInterval: 1000
};

listener kafka:SimpleConsumer consumer = new(consumerConfigs);

service kafkaService on consumer {
    resource function onMessage(kafka:ConsumerAction consumerAction, kafka:ConsumerRecord[] records) {
        // Dispatched set of Kafka records to service, We process each one by one.
        foreach kafkaRecord in records {
            processKafkaRecord(kafkaRecord);
        }
    }
}

function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    byte[] serializedMsg = kafkaRecord.value;
    string msg = internal:byteArrayToString(serializedMsg, "UTF-8");
    // Print the retrieved Kafka record.
    io:println("Topic: " + kafkaRecord.topic + " Partition: " + kafkaRecord.partition + " Received Message: " + msg);
}
