import boto3

s3 = boto3.resource('s3')
bucket = s3.Bucket('nginx-bucket.seun-project.com')

for obj in bucket.objects.filter(Prefix='index.html/'):
    print(obj.key)