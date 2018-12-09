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
import ballerina/transactions;

kafka:ProducerConfig producerConfigs = {
    bootstrapServers:"localhost:9094, localhost:9095, localhost:9096",
    clientID:"abort-transaction-producer",
    acks:"all",
    noRetries:3,
    transactionalID:"abort-transaction-test-producer"
};

kafka:SimpleProducer kafkaProducer = new(producerConfigs);

function funcKafkaAbortTransactionTest() returns boolean {
    string msg = "Hello World Transaction";
    byte[] serializedMsg = msg.toByteArray("UTF-8");
    var result = kafkaAdvancedTransactionalProduce(serializedMsg);
    if (result is error) {
        return false;
    }
    return true;
}

function kafkaAdvancedTransactionalProduce(byte[] msg) returns error? {
    error? returnValue = ();
    transaction {
        var result = kafkaProducer->send(msg, "test", partition = 0);
        returnValue = kafkaProducer->abortTransaction();
    }
    return returnValue;
}