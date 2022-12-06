
INVOKE_URL="https://x7p3u5gf32.execute-api.us-east-1.amazonaws.com/serverless_lambda_stage"

# Create or update an item. The command includes a request body with the item's ID, price, and name.

curl -X "PUT" -H "Content-Type: application/json" -d "{
    \"id\": \"10234\",
    \"price\": 12345,
    \"item\": \"myitem\"
}" $INVOKE_URL/items


# curl -s $INVOKE_URL/items | js-beautify 

# export INVOKE_URL="https://afsqb9jpad.execute-api.us-east-1.amazonaws.com/serverless_lambda_stage"

