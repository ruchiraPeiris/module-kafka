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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import wso2/kafka;

string topic = "advanced-service-test";

kafka:ConsumerConfig consumerConfigs = {
    bootstrapServers: "localhost:9094",
    groupId: "advanced-service-test-group",
    clientId: "advanced-service-consumer",
    offsetReset: "earliest",
    topics: [topic],
    autoCommit:false
};

listener kafka:SimpleConsumer kafkaConsumer = new(consumerConfigs);

kafka:ProducerConfig producerConfigs = {
    bootstrapServers: "localhost:9094",
    clientID: "advanced-service-producer",
    acks: "all",
    noRetries: 3
};

kafka:SimpleProducer kafkaProducer = new(producerConfigs);

boolean isSuccess = false;

service kafkaService on kafkaConsumer {
    resource function onMessage(
        kafka:SimpleConsumer consumer,
        kafka:ConsumerRecord[] records,
        kafka:PartitionOffset[] offsets,
        string groupId
    ) {
        foreach kafka:ConsumerRecord kafkaRecord in records {
            byte[] result = kafkaRecord.value;
            if (result.length() > 0) {
                isSuccess = true;
            }
        }
    }
}

function funcKafkaGetResultText() returns boolean {
    return isSuccess;
}

function funcKafkaProduce() {
    string msg = "test_string";
    byte[] byteMsg = msg.toByteArray("UTF-8");
    var result = kafkaProducer->send(byteMsg, topic);
}
