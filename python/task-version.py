import boto3

client = boto3.client('ecs')
response = client.list_task_definitions(
    familyPrefix='nginx-app-task-family',
)

print(response)