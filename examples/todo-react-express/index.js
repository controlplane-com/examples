const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { v4 } = require("uuid");
const AWS = require("aws-sdk");

const client = new AWS.DynamoDB({ region: "us-east-2" });

const TABLE_NAME = process.env.TABLE_NAME || "todo-db";

const app = express();
const port = 3001;

app.use(cors());
app.use(express.static("public"));

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// Serves the UI
app.get("/", (req, res) => {
  res.sendFile("public/index.html");
});

app.post("/todo", async (req, res) => {
  logRequest(req);
  try {
    const { title, description } = req.body;
    if (!title) {
      res.status(400).send("Title is required");
    }
    if (!description) {
      res.status(400).send("Description is required");
    }

    const id = v4();

    var params = {
      Item: {
        id: {
          S: id,
        },
        title: {
          S: title,
        },
        description: {
          S: description,
        },
        done: {
          BOOL: false,
        },
      },
      ReturnConsumedCapacity: "TOTAL",
      TableName: TABLE_NAME,
    };
    await client.putItem(params).promise();

    handleResponse(req, res, { code: 201 });
  } catch (e) {
    handleError(req, res, { code: 500, message: e.message });
  }
});

app.get("/todo", async (req, res) => {
  logRequest(req);
  try {
    var params = {
      ExpressionAttributeNames: {
        "#i": "id",
        "#t": "title",
        "#desc": "description",
        "#done": "done",
      },
      ProjectionExpression: "#i, #t, #desc, #done",
      TableName: TABLE_NAME,
    };
    const dynamoRes = await client.scan(params).promise();
    console.log(dynamoRes);
    const items = dynamoRes.Items.map((i) => ({
      id: i.id.S,
      title: i.title.S,
      description: i.description.S,
      done: i.done.BOOL,
    }));
    handleResponse(req, res, { data: items });
  } catch (e) {
    handleError(req, res, { code: 500, message: e.message });
  }
});

app.patch("/todo/:id", async (req, res) => {
  logRequest(req);
  try {
    const params = {
      ExpressionAttributeNames: {
        "#D": "done",
      },
      ExpressionAttributeValues: {
        ":d": {
          BOOL: req.body.done,
        },
      },
      Key: {
        id: {
          S: req.params.id,
        },
      },
      ReturnValues: "ALL_NEW",
      TableName: TABLE_NAME,
      UpdateExpression: "SET #D = :d",
    };
    await client.updateItem(params).promise();
    handleResponse(req, res, {});
  } catch (e) {
    handleError(req, res, { code: 500, message: e.message });
  }
});

app.delete("/todo/:id", async (req, res) => {
  logRequest(req);
  try {
    const params = {
      Key: {
        id: {
          S: req.params.id,
        },
      },
      TableName: TABLE_NAME,
    };
    await client.deleteItem(params).promise();
    handleResponse(req, res, {});
  } catch (e) {
    handleError(req, res, { code: 500, message: e.message });
  }
});

app.get("/envvars", (req, res) => {
  res.json({
    CPLN_GLOBAL_ENDPOINT: process.env.CPLN_GLOBAL_ENDPOINT,
    CPLN_GVC: process.env.CPLN_GVC,
    CPLN_LOCATION: process.env.CPLN_LOCATION,
    CPLN_GVC_ALIAS: process.env.CPLN_GVC_ALIAS,
    CPLN_PROVIDER: process.env.CPLN_PROVIDER,
    CPLN_ORG: process.env.CPLN_ORG,
    CPLN_WORKLOAD: process.env.CPLN_WORKLOAD,
  });
});

async function createTable() {
  try {
    const params = {
      AttributeDefinitions: [
        {
          AttributeName: "id",
          AttributeType: "S",
        },
      ],
      KeySchema: [
        {
          AttributeName: "id",
          KeyType: "HASH",
        },
      ],
      BillingMode: "PAY_PER_REQUEST",
      TableName: TABLE_NAME,
    };
    await client.createTable(params).promise();
    console.log(`Table named "${TABLE_NAME}" is created.`);
    return;
  } catch (e) {
    console.log("Table create error:", e.message);
  }
}

app.listen(port, async () => {
  createTable();
  console.log(`Listening on port: ${port}`);
});

function handleError(req, res, { code, message }) {
  console.error(
    `Response - Error - ${req.method} | ${req.path} | ${code} | ${message}`
  );
  res.status(code).send(message);
}

function handleResponse(req, res, { code = 200, data }) {
  console.error(
    `Response - Success - ${req.method} | ${req.path} | ${code} | ${
      typeof data === "object" ? JSON.stringify(data) : data
    }`
  );
  if (data) {
    res.status(code).send(data);
  } else {
    res.status(code).end();
  }
}

function logRequest(req) {
  if (req.body) {
    logRequestWithData(req);
  } else {
    console.log(`Request | ${req.method} | ${req.path}`);
  }
}

function logRequestWithData(req) {
  console.log(
    `Request | ${req.method} | ${req.path} | ${JSON.stringify(req.body)}`
  );
}
