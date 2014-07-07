elasticsearch = require 'elasticsearch'
client = new elasticsearch.Client({hosts: 'localhost:9200'})

module.exports = client