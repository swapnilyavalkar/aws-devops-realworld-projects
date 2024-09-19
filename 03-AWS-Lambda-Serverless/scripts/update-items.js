import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get 'id' from pathParameters
        const id = event.pathParameters && event.pathParameters.id;

        // Safely parse the event.body for 'name'
        let body = event.body;
        if (body) {
            if (typeof body === "string") {
                body = JSON.parse(body);
            }
        } else {
            throw new Error("Missing request body");
        }

        const { name } = body;

        if (!id || !name) {
            throw new Error("Missing 'id' or 'name' in the request body or path");
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }
            },
            UpdateExpression: "SET #name = :name",
            ExpressionAttributeNames: {
                "#name": "name"
            },
            ExpressionAttributeValues: {
                ":name": { S: name }
            },
            ReturnValues: "UPDATED_NEW"
        };

        const command = new UpdateItemCommand(params);
        const result = await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify(result.Attributes)
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};
