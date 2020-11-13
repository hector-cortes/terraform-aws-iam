#################################################
# Local Variables
#################################################
locals {
  iam_groups = yamldecode(file("${path.module}/config_files/iam.yaml"))["groups"]
  iam_policies = yamldecode(file("${path.module}/config_files/iam.yaml"))["policies"]
}

#################################################
# IAM Users
# Creates an IAM User for each unique entry in
# local.iam_groups.members
#################################################
resource "aws_iam_user" "users" {
  for_each = toset(distinct(flatten([
    for iam_group in local.iam_groups:
    iam_group.members
  ])))

  name          = each.value
  path          = "/user_accounts/"
  force_destroy = true
}

#################################################
# IAM Groups
# Creates an IAM Group for each key in
# local.iam_groups
#################################################
resource "aws_iam_group" "groups" {
  for_each = local.iam_groups

  name = each.value.name
  path = "/user_groups/"
}

#################################################
# IAM Group Membership
# Assigns IAM users to IAM groups, based off of
# local.iam_groups.members
#################################################
resource "aws_iam_user_group_membership" "group_members" {
  for_each = transpose({
    for iam_group in local.iam_groups :
    iam_group.name => iam_group.members
  })

  user   = each.key
  groups = each.value

  depends_on = [aws_iam_group.groups, aws_iam_user.users]
}
}
