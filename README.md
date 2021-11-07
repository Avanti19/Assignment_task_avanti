# Assignment_task_avanti
This terrafrom snippet will create the aws Lambda function along with the api gateway, that api will work as a String Replacer which will use a string as input and find and replace for certain words and outputs the result.

After successfully running the "terraform apply" the Lambda function will be created along with the api gateway and Api will be accessible with POST method.

# Requirement:
* AWS account
* Terraform >= v1.0.6 
* linux_amd64

# List of the resources created as mentioned in the tf files:
* S3 bucket
* lambda function
* IAM Role
* Api Gateway

I have added resource path to '/replace' as a functionality required replacemant of string, so every time we need to add replace url for use of this functionality.
https://r2557th7z5.execute-api.ap-south-1.amazonaws.com/prod/replace

Not all methods are compatible with all AWS integrations. e.g., Lambda function can only be invoked via POST. 
Ref - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration
![Screenshot_postman_output](https://user-images.githubusercontent.com/49921401/140655501-b6aff0cb-c713-4d66-8ae9-78ea5917c52e.png)


When we run Terraform Apply it will create all required resources:
![Screenshot_terraform_apply_output](https://user-images.githubusercontent.com/49921401/140653620-658e8945-cad0-49df-8b08-1f527c198603.png)

After Terraform run sucessfully it will created resources in AWS ui:
![Screenshot_lambda_function_ui](https://user-images.githubusercontent.com/49921401/140653850-ae90599c-98d7-437c-9f8e-d1f4807b690d.png)

API Gateway - 
![Screenshot_api_gateway_ui](https://user-images.githubusercontent.com/49921401/140655402-b1ec8ed8-36d8-4ff3-a125-7fac741e76e4.png)

After sucessfully run teraform, we will get url, after that we can use Postman to check function:
I added default input parameters in function.py as a
* str: String parameter 
* oldstring: String parameter which you want to replace
* newstring: New string parameter from which you want to replace

Final URl looks like:
https://r2557th7z5.execute-api.ap-south-1.amazonaws.com/prod/replace

![Screenshot_postman_output](https://user-images.githubusercontent.com/49921401/140653905-0cf169f6-0cd3-46e3-9c1a-b33a95bc2593.png)

