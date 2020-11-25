###################################################
# Local Variables
###################################################
locals {
  config = yamldecode(file("${path.module}/templater/generated.yaml"))

  iam_users              = config["users"]
  iam_groups             = config["groups"]
  iam_policies           = config["policies"]
  iam_group_memberships  = config["group_memberships"]
  iam_policy_attachments = config["policy_attachments"]
}

###################################################
# IAM Groups
###################################################
resource "aws_iam_group" "groups" {
  for_each = local.iam_groups

  name = each.key
  path = "/user_groups/"
}

###################################################
# IAM Users
###################################################
resource "aws_iam_user" "users" {
  for_each = local.iam_users

  name          = each.key
  path          = "/user_accounts/"
  force_destroy = true
}

###################################################
# IAM Group Memberships
###################################################
resource "aws_iam_user_group_membership" "group_members" {
  for_each = local.iam_group_memberships

  user   = each.key
  groups = each.value

  depends_on = [aws_iam_group.groups, aws_iam_user.users]
}

###################################################
# IAM Policy Documents
###################################################
data "aws_iam_policy_document" "policies_json" {
  for_each = local.iam_policies

  statement {
    sid       = "AssumeRolePermissions"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = each.value
  }
}

###################################################
# IAM Policies
###################################################
resource "aws_iam_policy" "group_policies" {
  for_each = local.iam_policies

  name = each.key
  path = "/assume-role/"

  policy = data.aws_iam_policy_document.policies_json[each.key].json
}

###################################################
# IAM Group Policy Attachments
###################################################
resource "aws_iam_group_policy_attachment" "group_policy_attachments" {
  for_each = local.iam_policy_attachments

  group      = aws_iam_group.groups[each.value.group].name
  policy_arn = aws_iam_policy.group_policies[each.value.policy].arn

  depends_on = [aws_iam_group.groups, aws_iam_policy.group_policies]
}