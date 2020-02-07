output "bucket_name" {
  value = aws_s3_bucket.default.bucket
}

output "kms_key_arn_in_transit" {
  value = aws_kms_key.in_transit.arn
}