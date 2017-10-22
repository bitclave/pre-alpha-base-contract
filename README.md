# pre-alpha-base-contract

##Introduction
This repository is used to prototype Smart Contracts behaviours for BASE. The focus here is to enable for quick prototyping of BASE vertical solutions and for performance evaluation of BASE on Ethereum. To support this goal we implement Smart Contracts in a generic way. Search and Offer are defined as a collection of key-value pairs and Search is implemented internally in contract using a small set of simple operators. This approach allows for quick prototyping, while it might be less efficient and capable for final product.

##Setup
for start with project install:
nodejs latest (^8.4.0)
truffle
ethereumjs-testrpc

start:
testrpc -u 0 -u 1
truffle test
