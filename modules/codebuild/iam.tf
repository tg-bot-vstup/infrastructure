resource "aws_iam_role" "codebuild" {
  name = "codebuild-executor-role-${var.app_name}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "role_policy" {
  role = aws_iam_role.codebuild.name
  name = "codebuild-executor-policy-${var.app_name}-${var.environment}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:*"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ecr:*",
            "ecs:*"
          ],
          "Resource": "*"
        },
        {
      "Effect": "Allow",
      "Action": [
        "rds:*"
      ],
      "Resource": "*"
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },
        {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "arn:aws:secretsmanager:${var.aws_region}:*:secret:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:${var.aws_region}:*:parameter*"
    },
    {
      "Effect": "Allow",
      "Action" : [
        "dynamodb:*" 
      ],
      "Resource": "*" 
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:CreatePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:PassRole",
        "iam:ListInstanceProfilesForRole",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:AttachRolePolicy"
      ],
      "Resource": "arn:aws:iam::*:role/*"
    },
        {
          "Effect": "Allow", 
          "Action": [
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeAvailabilityZones",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:DescribeTags",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          "Resource": "*" 
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterfacePermission"
            ],
            "Resource": "arn:aws:ec2:${var.aws_region}:*:network-interface/*",
            "Condition": {
                "StringEquals": {
                  "ec2:AuthorizedService": "codebuild.amazonaws.com"
                },
                "ArnEquals": {
                  "ec2:Subnet": [
                    "arn:aws:ec2:${var.aws_region}:*:subnet/*"
                  ]
                }
            }
        }
    ]
}
POLICY
}
