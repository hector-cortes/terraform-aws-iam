# Usage
Modify iam.yaml to create desired IAM Groups, IAM Users, and IAM Group Memberships

## Example
```yaml
IAM_GROUP:
  name: (string) The name of the IAM Group
  iam_policies: (string[]) List of policies to attach to the IAM Group
  members: (string[]) IAM Users to add to the IAM Group  
```