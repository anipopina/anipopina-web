#!/usr/bin/env bash
# Run with AWS credentials for account 209018279507 (AWS_PROFILE is supported).
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

account_id="$(aws sts get-caller-identity --query Account --output text)"
if [[ "$account_id" != "209018279507" ]]; then
  echo "Expected AWS account 209018279507; current account is $account_id." >&2
  exit 1
fi

bucket="anipopina-com-web-209018279507"
files=(index.html style.css anipopina.png QR_BTC.png QR_MONA.png favicon.ico favicon-32.png)
for file in "${files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing file: $file" >&2; exit 1; }
done
for file in "${files[@]}"; do
  case "$file" in
    *.html) content_type="text/html; charset=utf-8" ;;
    *.css) content_type="text/css; charset=utf-8" ;;
    *.ico) content_type="image/x-icon" ;;
    *.png) content_type="image/png" ;;
  esac
  aws s3 cp "$file" "s3://$bucket/$file" \
    --region ap-northeast-1 \
    --content-type "$content_type" \
    --cache-control "public, max-age=300" \
    --only-show-errors
done
aws cloudfront create-invalidation \
  --distribution-id E2L72PR9WA8CS --paths '/*'
