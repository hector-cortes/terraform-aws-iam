import os
import yaml
import argparse


def validate_name(name):
    with open('../config_files/iam.yaml') as raw_config:
        config = yaml.safe_load(raw_config)
        if name in config["groups"]:
            msg = format(
                "Invalid Name! Group with name '{name}' already exists")
            raise argparse.ArgumentError(msg)
    return name


def validate_policies(policies):
    print(type(policies))
    with open('../config_files/iam.yaml') as raw_config:
        config = yaml.safe_load(raw_config)
        if not all(policy in policies for policy in config["policies"]):
            raise argparse.ArgumentError("test")
    return policies


def add_name(name):
    with open('../config_files/iam.yaml', 'r') as raw_config:
        config = yaml.safe_load(raw_config)
        config["groups"].update({name: {"name": name}})
        with open('../config_files/iam.yaml', 'w+') as raw_config:
            yaml.safe_dump(config, raw_config)


parser = argparse.ArgumentParser(
    description="Adds a new IAM Group to the YAML config file")

parser.add_argument('name', action='store', type=validate_name,
                    help='The name of the IAM Group to create')
parser.add_argument('--policies', action='store', type=validate_policies,
                    help='The name(s) of the IAM Policy(ies) to attach')

args = parser.parse_args()
add_group(args.name)
