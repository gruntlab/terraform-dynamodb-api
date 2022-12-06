// Lambda function code

const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  let body;
  let prefix;
  // console.log("debug [event] =", event);
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
  };

  try {
    switch (event.requestContext.http.method) {
      case "DELETE":
        prefix = event.pathParameters.proxy
        await dynamo
          .delete({
            TableName: "mock_spur_database",
            Key: {
              prefix: prefix,
            },
          })
          .promise();
        body = `Deleted item ${event.queryStringParameters.id}`;
        break;
      case "GET":
        prefix = event.pathParameters.proxy
        if(!prefix){
          body = await dynamo.scan({ TableName: "mock_spur_database" }).promise();
        }
        else{
          body = await dynamo
            .get({
              TableName: "mock_spur_database",
              Key: {
                prefix: prefix,
              },
            })
            .promise();
        }
        break;
      case "PUT":
        prefix = event.pathParameters.proxy
        let requestJSON = JSON.parse(event.body);
        await dynamo
          .put({
            TableName: "mock_spur_database",
            Item: {
              id: requestJSON.id,
              table: requestJSON.table,
              prefix: prefix,
              data: requestJSON.data,
            },
          })
          .promise();
        body = `Put item ${requestJSON.id}`;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};



