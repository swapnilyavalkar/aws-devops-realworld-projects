import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

// Create DynamoDB client
const client = new DynamoDBClient({ region: "ap-south-1" });

export const handler = async (event) => {
    try {
        // Get the 'id' from path parameters
        const { id } = event.pathParameters;

        if (!id) {
            throw new Error("Missing 'id' in the path parameters");
        }

        const params = {
            TableName: "ItemsTable",
            Key: {
                id: { S: id }  // Dynamodb expects keys to be formatted as {type: value}
            }
        };

        // Use the GetItemCommand to retrieve the item from DynamoDB
        const command = new GetItemCommand(params);
        const result = await client.send(command);

        if (!result.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Item not found" })
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(result.Item)
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};