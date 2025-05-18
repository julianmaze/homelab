# https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws
resource "aws_iam_policy" "external-dns" {
  name        = "external-dns"
  description = "External DNS policy for my private hosted zones"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResources"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user" "externaldns" {
  name = "externaldns"
}

resource "aws_iam_user_policy_attachment" "externaldns" {
  user       = aws_iam_user.externaldns.name
  policy_arn = aws_iam_policy.external-dns.arn
}

resource "aws_iam_access_key" "k8s" {
  user    = aws_iam_user.externaldns.name
}