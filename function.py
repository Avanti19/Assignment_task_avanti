
import json

def lambda_handler(event, context):
    # get parameter from inputstring
    inputString = str(event['headers']['str'])
    replaceStringFrom = str(event['headers']['oldstring'])
    replaceStringWith = str(event['headers']['newstring'])
    
    print(inputString)
    print(replaceStringFrom)
    print(replaceStringWith)
    
    # creating response body
    responseBody = {}
    try:
        responseBody['replacedString'] = inputString.replace(replaceStringFrom, replaceStringWith)
        responseBody['message'] = "pass"
        print("Success!")
    except Exception as e:
        print("Exception", e)
        responseBody['replacedString'] = ""
        responseBody['message'] = 'fail'
    
    # creating response object
    responseObj = {}
    responseObj['statusCode'] = 200
    responseObj['headers'] = {}
    responseObj['headers']['content-type'] = 'application/json'
    responseObj['body'] = json.dumps(responseBody)
    
    return responseObj
