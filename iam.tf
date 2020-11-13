#################################################
# Local Variables
#################################################
locals {
  iam_groups = yamldecode(file("${path.module}/config_files/iam.yaml"))["groups"]
  iam_policies = yamldecode(file("${path.module}/config_files/iam.yaml"))["policies"]
}

resource "aws_iam_user" "users" {
  for_each = local.iam_users

  name          = each.value
  path          = "/user_accounts/"
  force_destroy = true
}

resource "aws_iam_group" "groups" {
  for_each = local.iam_groups

  name = each.value.name
  path = "/user_groups/"
}

resource "aws_iam_user_group_membership" "group_members" {
  for_each = local.iam_group_memberships
  user     = each.key
  groups   = each.value

  depends_on = [aws_iam_user.users, aws_iam_group.groups]
}
