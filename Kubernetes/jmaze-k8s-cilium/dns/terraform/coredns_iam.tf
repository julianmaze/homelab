# We are going to reuse the externaldns IAM user for coredns
# We simply need to add the ability to list hosted zones by name

data "aws_iam_policy_document" "coredns" {
  statement {
    actions = [
      "route53:ListHostedZonesByName",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "coredns" {
  name        = "coredns"
  description = "CoreDNS policy for my private hosted zones"
  policy      = data.aws_iam_policy_document.coredns.json
}

resource "aws_iam_user_policy_attachment" "coredns" {
  user       = aws_iam_user.externaldns.name
  policy_arn = aws_iam_policy.coredns.arn
}