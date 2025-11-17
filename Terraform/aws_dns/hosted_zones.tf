# __generated__ by OpenTofu
# Please review these resources and move them into your main configuration files.

# __generated__ by OpenTofu
resource "aws_route53_zone" "jmaz_tv" {
  comment       = "Voltaire and Gila DNS"
  force_destroy = null
  name          = "jmaz.tv"
  tags          = {}
  tags_all      = {}
  vpc {
    vpc_id     = local.us-west-2_networking_default_vpc
    vpc_region = var.region
  }
}

# __generated__ by OpenTofu
resource "aws_route53_zone" "julianmaze_com" {
  comment       = "Voltaire and Gila DNS"
  force_destroy = null
  name          = "julianmaze.com"
  tags          = {}
  tags_all      = {}
  vpc {
    vpc_id     = local.us-west-2_networking_default_vpc
    vpc_region = var.region
  }
}
