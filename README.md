### About cfn2iam

- AWS Cloudformation (CFN) performs CRUD operations on CFN stacks using 'handlers'
- The permissions these handlers may use are defined by the resource provider schema for each resource
  - Region-specific resource provider schemas can be found [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/resource-type-schemas.html)
- CFN decides which handlers to invoke based on the type of operation being performed
  - Handler contract [here](https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/resource-type-test-contract.html)
  - Amazon Q provided clarification [here](./handlers.md)
- cfn2iam seeks to provide IAM policies with the same permissions used by the CFN handlers

### How cfn2iam works

1. cfn2iam iterates through each provided CFN stack template, and creates a changeset against the current stack of the stack, if any
2. Based on the proposed resource changes in the changeset, cfn2iam identifies which resource handlers will be invoked
3. cfn2iam then pulls the handler permissions from each resource handler, removes duplicates, and pushes them to an IAM policy
4. The end result is an IAM policy for each provided stack template with the permissions that may be used by the CFN handlers

### Running cfn2iam

1. Run `build.sh` to build image
2. Place CFN stack templates in `cfn/` directory
3. Copy `.env.base` to `.env`, and fill values
4. Run `run.sh` to run the image
5. Check the `iam/` directory for counterpart IAM policies matching the templates provided in `cfn/`
