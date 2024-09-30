import { DynamoDBClient, DeleteItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get 'id' from path parameters
        const id = event.pathParameters && event.pathParameters.id;

        if (!id) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: "Missing 'id' in path parameters" })
            };
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }
            }
        };

        const command = new DeleteItemCommand(params);
        await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Item deleted successfully" })
        };

    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};