const express = require('express');
const app = express();
var AWS = require("aws-sdk");
const REGION = process.env.REGION || "us-west-2";
AWS.config.update({ region: `${REGION}` });
const dynamoDB = new AWS.DynamoDB.DocumentClient()
app.get('/:item', readFromDynamoDB);
app.get('/', (req, res) => res.send('Hi bob, specify an item like /cats'));

app.listen(8080);
console.log("listening on port 8080, Dynamo Region", REGION);

function readFromDynamoDB(req, res) {
	console.log(`reading ${req.params.item} from DynamoDB`);
	dynamoDB.scan({
		TableName: req.params.item,
	}).promise().then(data => res.send(data.Items)).catch(err => res.send(err));
}


