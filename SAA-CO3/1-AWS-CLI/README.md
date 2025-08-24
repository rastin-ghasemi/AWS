## install AWS CLI
1. bash ./install.sh
2. run aws
```bash
rgh@machine:~/Work/Main/AWS/SAA-CO3/1-AWS-CLI$ aws

usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help

aws: error: the following arguments are required: command

```
- We successfully installed the AWS Command Line Interface.

## The second step is to set our credentials 
How We check it ?
```bash
aws sts get-caller-identity

Unable to locate credentials. You can configure credentials by running "aws configure".
```
## Create user for our CLI
AWS Portal > IAM > User > Create 
Second:
user > Security credentials > create access key > CLI key

## Configuring environment variables for the AWS CLI
```bash
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_REGION=us-west-2
```
## The AWS CLI supports the following environment variables.
- Link: 
```bash
https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
```

## Configure auto-prompt

To configure auto-prompt you can use the following methods in order of precedence:

1. Command line options enable or disable auto-prompt for a single command. Use --cli-auto-prompt to call auto-prompt and --no-cli-auto-prompt to disable auto-prompt.

2. Environment variables use the aws_cli_auto_prompt variable.
```bash
export AWS_CLI_AUTO_PROMPT="on-partial"
or single command
aws --cli-auto-prompt
```
3. Shared config files use the cli_auto_prompt setting.
