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

string topic1 = "rebalance-topic-1";
string topic2 = "rebalance-topic-2";
string[] topics = [topic1, topic2];

kafka:ConsumerConfig consumerConfigs = {
    bootstrapServers: "localhost:9094",
    groupId: "subscribe-with-parition-rebalnce-group",
    clientId: "subscribe-with-partition-rebalnce-consumer",
    metadataMaxAge: 100,
    defaultApiTimeout: 100
};

function funcKafkaGetKafkaConsumer() returns kafka:SimpleConsumer {
    return new(consumerConfigs);
}

function funcKafkaTestSubscribeWithPartitionRebalance(kafka:SimpleConsumer kafkaConsumer) {
    function(kafka:SimpleConsumer consumer, kafka:TopicPartition[] partitions) onAssigned = funcKafkaOnPartitionsAssigned;
    function(kafka:SimpleConsumer consumer, kafka:TopicPartition[] partitions) onRevoked = funcKafkaOnPartitionsRevoke;

    var result = kafkaConsumer->subscribeWithPartitionRebalance(topics, onRevoked, onAssigned);
}

function funcKafkaTestGetSubscribedTopicCount(kafka:SimpleConsumer kafkaConsumer) returns int|error {
    string[] subscribedTopics = check kafkaConsumer->getSubscription();
    return (subscribedTopics.length());
}

function funcKafkaGetAvailableTopicsCount(kafka:SimpleConsumer kafkaConsumer) returns int|error {
    string[] availableTopics = check kafkaConsumer->getAvailableTopics(duration = 100);
    return (availableTopics.length());
}

int rebalnceInvokedPartitions = -1;
int rebalnceAssignedPartitions = -1;

function funcKafkaOnPartitionsRevoke(kafka:SimpleConsumer kafkaConsumer, kafka:TopicPartition[] partitions) {
    rebalnceInvokedPartitions = partitions.length();
}

function funcKafkaOnPartitionsAssigned(kafka:SimpleConsumer kafkaConsumer, kafka:TopicPartition[] partitions) {
    rebalnceAssignedPartitions = partitions.length();
}

function funcKafkaGetRebalanceInvokedPartitionsCount(kafka:SimpleConsumer kafkaConsumer) returns int {
    var result = kafkaConsumer->poll(1000);
    return rebalnceInvokedPartitions;
}

function funcKafkaGetRebalanceAssignedPartitionsCount(kafka:SimpleConsumer kafkaConsumer) returns int {
    var result = kafkaConsumer->poll(1000);
    return rebalnceAssignedPartitions;
}
