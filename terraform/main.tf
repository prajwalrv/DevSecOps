/*
# =====================================================
# Step 1 – Configure the AWS Provider
# =====================================================
provider "aws" {
  region = "us-east-1"
}

# =====================================================
# Step 2 – Generate a Random Bucket Suffix
# =====================================================
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# =====================================================
# Step 3 – Create an Amazon S3 Bucket
# =====================================================
resource "aws_s3_bucket" "vault_test_bucket" {
  bucket = "devsecops-vault-demo-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Vault Dynamic Secret Test"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# =====================================================
# Step 4 – Output the Bucket Name
# =====================================================
output "bucket_name" {
  value = aws_s3_bucket.vault_test_bucket.id
}
*/