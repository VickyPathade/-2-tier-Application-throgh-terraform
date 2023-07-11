terraform {
  backend "s3" {
    bucket         = "terraform-book-store"
    key            = "backend/booksssss_shop_app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamoDB-state-locking"
    skip_credentials_validation = true
  }
}


