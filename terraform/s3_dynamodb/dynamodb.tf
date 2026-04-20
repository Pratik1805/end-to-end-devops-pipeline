resource "aws_dynamodb_table" "tf_lock" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  name         = "terraform-lock"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "${local.environment}"
  }
}