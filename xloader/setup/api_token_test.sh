#!/bin/bash

# File: api_token_test.sh

# Define variables
CKAN_API_URL="http://ckan-dev:5000/api/3/action/datastore_create"
API_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJaeUJSRFg0WXFLT0s5XzJIay1LblFQN2RfVkxVNHZvTkVKcFBCRGR4NlpjIiwiaWF0IjoxNzM0NjA2MzYxfQ.qczOLD0Re3GiKzXJd7sCvU7SLFVhsWofn17vVC5YDRk"
PACKAGE_ID="6ebb8fec-943f-4ff6-8018-1ea8fa2aae5d"

# Validate API token
if [ -z "$API_TOKEN" ]; then
  echo "Error: API token is not set. Please export CKAN_API_TOKEN environment variable."
  exit 1
fi

# Prepare JSON payload with PACKAGE_ID substituted
JSON_PAYLOAD=$(cat <<EOF
{
  "resource": {
    "package_id": "$PACKAGE_ID"
  },
  "fields": [
    {"id": "a"},
    {"id": "b"}
  ],
  "records": [
    {"a": 1, "b": "xyz"},
    {"a": 2, "b": "zzz"}
  ]
}
EOF
)

# Making the POST request with curl
response=$(curl -v -s -o /dev/null -w "%{http_code}" -X POST "$CKAN_API_URL" \
  -H "Authorization: $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

# Check the response
if [[ "$response" =~ ^2[0-9]{2}$ ]]; then
  echo "Connection to CKAN API successful! HTTP status code: $response"
else
  echo "Failed to connect to CKAN API. HTTP status code: $response"
fi