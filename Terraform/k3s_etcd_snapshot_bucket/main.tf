module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=3170c8beeb346b53c10a3ac2164e637ed161f828" # -> v5.9.1

  bucket = "k3s-etcd-snapshots-jmaze-k8s-cilium"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

output "bucket-name" {
  value = module.s3_bucket.s3_bucket_id
}

output "bucket-arn" {
  value = module.s3_bucket.s3_bucket_arn
}