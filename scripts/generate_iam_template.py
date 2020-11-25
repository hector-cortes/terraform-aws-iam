import json
import yaml

from jinja2 import FileSystemLoader, Environment

CONFIG = "./iam_struct.yaml"
TEMPLATE = "./iam_template.jinja"

template_loader = FileSystemLoader(searchpath="./")
template_env = Environment(loader=template_loader)
template = template_env.get_template(TEMPLATE)


with open(CONFIG, "r") as raw_config:
    config = yaml.safe_load(raw_config)

iam_groups = config["iam_groups"]
iam_policies = config["iam_policies"]
aws_accounts = config["accounts"]

users = []
for group, group_attrs in iam_groups.items():
    users.extend(group_attrs["members"])
users = sorted(set(users))

policies = {}
for policy, policy_attrs in iam_policies.items():
    for account_group in policy_attrs["accounts"]:
        role_arns = [
            f"arn:aws:iam::{account_id}:role/{role}"
            for role in policy_attrs["roles"]
            for account_id in aws_accounts[account_group]
        ]
    policies.update({policy: role_arns})

policy_attachments = {}
for group, group_attrs in iam_groups.items():
    policy_attachments.update(
        {
            f"{group}_{policy}": {"group": group, "policy": policy}
            for policy in group_attrs["policies"]
        }
    )

with open("iam_temp.yaml", "w") as temp:
    test = template.render(
        groups=iam_groups,
        users=users,
        policies=policies,
        policy_attachments=policy_attachments,
    )
    temp.write(test)
