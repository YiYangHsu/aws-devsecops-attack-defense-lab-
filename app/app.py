import os
from http.server import BaseHTTPRequestHandler, HTTPServer

import boto3
from botocore.exceptions import ClientError

BUCKET_NAME = os.environ.get("IAM_LAB_BUCKET")

ALLOWED_KEY = "allowed/test-data.txt"
RESTRICTED_KEY = "restricted/decoy-data.txt"

s3 = boto3.client("s3")

class RequestHandler(BaseHTTPRequestHandler):

    def send_text(self, status_code, message):
        self.send_response(status_code)
        self.end_headers()
        self.wfile.write(message.encode())

    def read_s3_object(self, key):
        try:
            response = s3.get_object(
                Bucket=BUCKET_NAME,
                Key=key
            )

            body = response["Body"].read().decode()

            self.send_text(200, body)

        except ClientError as error:
            error_code = error.response["Error"]["Code"]

            self.send_text(
                403,
                f"S3 access failed: {error_code}"
            )   

    def list_s3_objects(self):
        try:
            response = s3.list_objects_v2(
                Bucket=BUCKET_NAME
            )

            objects = response.get("Contents", [])
            keys = [obj["Key"] for obj in objects]

            self.send_text(
                200,
                "\n".join(keys)
            )

        except ClientError as error:
            error_code = error.response["Error"]["Code"]

            self.send_text(
                403,
                f"S3 access failed: {error_code}"
            )            

    def do_GET(self):

        if self.path == "/health":
            self.send_text(200, "healthy")
            return

        if self.path == "/s3/allowed":
            self.read_s3_object(ALLOWED_KEY)
            return

        if self.path == "/s3/restricted":
            self.read_s3_object(RESTRICTED_KEY)
            return

        if self.path == "/s3/list":
            self.list_s3_objects()
            return

        self.send_text(
            200,
            "AWS DevSecOps Attack & Defense Lab"
        )

server = HTTPServer(("0.0.0.0",8080),RequestHandler)

print("Application listening on port 8080")
server.serve_forever()
