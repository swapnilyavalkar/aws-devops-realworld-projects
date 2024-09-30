import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Safely parse the event.body, handle cases where it's undefined
        let body = event.body;
        if (body) {
            if (typeof body === "string") {
                body = JSON.parse(body);
            }
        } else {
            throw new Error("Missing request body");
        }

        const { id, name } = body;

        if (!id || !name) {
            throw new Error("Missing 'id' or 'name' in the request body");
        }

        const params = {
            TableName: "ItemsTable",
            Item: {
                id: { S: id },
                name: { S: name }
            }
        };

        const command = new PutItemCommand(params);
        await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Item created successfully" })
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};
