#!/bin/bash

# Swagger JSONを生成
swag init

# swagger-codegen-cliまたはopenapi-generatorでTypeScript型を生成
# Option 1: openapi-generator-cli (推奨)
npx @openapitools/openapi-generator-cli generate \
  -i docs/swagger.json \
  -g typescript-axios \
  -o ../dashboard/src/generated/api \
  --additional-properties=supportsES6=true,npmVersion=6.0.0

# Option 2: swagger-codegen-cli (古い)
# npx swagger-codegen-cli generate \
#   -i docs/swagger.json \
#   -l typescript-axios \
#   -o ../dashboard/src/generated/api

echo "TypeScript types generated successfully!"