import json
import uuid
import pandas as pd
import boto3

from kedro.extras.datasets.json import JSONDataSet

dynamodb = boto3.client('dynamodb')
table = "mock_spur_database"

api_datasets = [
        "accounts-domains",
        "accounts",
        "associated-domains",
        "infrastructure-devices",
        "infrastructure-domains-activesubdomains-ports",
        "infrastructure-reputations",
        "runtime-requests",
        "subdomains"
]

for dataset in api_datasets:
    data = "resources/example_sanitized_data/raw_api_data/"+dataset+".json"
    df = pd.read_json(data)
    data_dump = df.to_json(orient="records")
    prefix = dataset.replace("-", "/");
    id = uuid.uuid4().hex
    response = dynamodb.put_item(TableName=table, Item={"id":{"S": id}, "table":{"S": table}, "prefix":{"S": prefix}, "data": {"S": data_dump}})
    json_data = json.loads(data_dump)
    payload = {
                "id": id,
                "table": table,
                "prefix": prefix,
                "data": json_data
            }
    data_set = JSONDataSet(filepath="resources/json_data/"+dataset+".json")
    data_set.save(payload)
    reloaded = data_set.load()
    assert payload == reloaded

response = dynamodb.get_item(
    TableName=table,
     Key={
        'prefix': {
            'S' : 'infrastructure/reputations'           
        }
     }
)
# print(response["Item"])




# from kedro.extras.datasets.pandas import JSONDataSet
# df = pd.DataFrame(data)
# print(df) 

# # import json
# # result = df.to_json(orient="records")
# # print(result) 

# # data_set = JSONDataSet(filepath="gcs://bucket/test.json")
# data_set = JSONDataSet(filepath="test.json")
# data_set.save(data)
# reloaded = data_set.load()
# assert data.equals(reloaded)
# 


