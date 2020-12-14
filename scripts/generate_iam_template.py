import json
import yaml

from jinja2 import FileSystemLoader, Environment

CONFIG = "config/config.yaml"
IAM_USERS_TEMPLATE = "templates/iam_users.jinja"
IAM_USERS_AUTOGEN_CONFIG = "terraform/terraform_autogen_config.yaml"

# Load Jinja template
template_loader = FileSystemLoader(searchpath="./")
template_env = Environment(loader=template_loader)
iam_users_template = template_env.get_template(IAM_USERS_TEMPLATE)

# Load IAM config file
with open(CONFIG, "r") as raw_config:
    config = yaml.safe_load(raw_config)

# Generate IAM Users
iam_users = []
for group, group_attrs in config["iam_groups"].items():
    iam_users.extend(group_attrs["members"])
iam_users = sorted(set(iam_users))

# Generate IAM Groups
iam_groups = config["iam_groups"]

# Generate IAM Policies
assume_role_policies = {}
for policy, policy_attrs in config["assume_role_policies"].items():
    assume_role_policies[policy] = []
    for account_group in policy_attrs["accounts"]:
        assume_role_policies[policy].extend(
            [
                f"arn:aws:iam::{account_id}:role/{role}"
                for role in policy_attrs["roles"]
                for account_id in config["accounts"][account_group]
            ]
        )

# Generate IAM Policy Attachments
assume_role_policy_attachments = {}
for group, group_attrs in config["iam_groups"].items():
    assume_role_policy_attachments.update(
        {
            f"{group}_{policy}": {"group": group, "policy": policy}
            for policy in group_attrs["policies"]
        }
    )

# Update terraform_autogen_config.yaml with new template
with open(IAM_USERS_AUTOGEN_CONFIG, "w") as iam_config:
    rendered_iam_template = template.render(
        groups=iam_groups,
        users=users,
        policies=policies,
        policy_attachments=policy_attachments,
    )
    iam_config.write(rendered_iam_template)
