import { Handler, APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";

export const handler: Handler = async (
  event: APIGatewayEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const body = JSON.parse(event.body);
    const foo = body.foo;
    return {
      body: JSON.stringify({
        message: "Event received: " + foo,
      }),
      statusCode: 200,
    };
  } catch (e) {
    return {
      body: JSON.stringify({
        message: e.message,
      }),
      statusCode: 500,
    };
  }
};
