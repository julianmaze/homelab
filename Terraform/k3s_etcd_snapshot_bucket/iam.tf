data "aws_iam_policy_document" "s3-etcd-snapshot-bucket" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      module.s3_bucket.s3_bucket_arn,
    ]
  }
}

resource "aws_iam_policy" "s3-etcd-snapshot-bucket" {
  name        = "s3-etcd-snapshot-bucket"
  description = "Policy for accessing S3 etcd snapshot bucket"
  policy      = data.aws_iam_policy_document.s3-etcd-snapshot-bucket.json
}

resource "aws_iam_user_policy_attachment" "s3-etcd-snapshot-bucket" {
  user       = aws_iam_user.k3s_etcd_svc_acc.name
  policy_arn = aws_iam_policy.s3-etcd-snapshot-bucket.arn
}

resource "aws_iam_user" "k3s_etcd_svc_acc" {
  name = "k3s-etcd-svc-acc"
}

resource "aws_iam_access_key" "k8s" {
  user = aws_iam_user.k3s_etcd_svc_acc.name
}

output "k8s_access_id" {
  value = aws_iam_access_key.k8s.id
}

output "k8s_access_secret" {
  value = nonsensitive(aws_iam_access_key.k8s.secret)
}
