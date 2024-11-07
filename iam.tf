# Create IAM Role for EC2
resource "aws_iam_role" "s3_full_access_role" {
  name = "s3-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com" # This allows EC2 instances to assume this role
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Create IAM Policy to Allow Full S3 Access
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Policy granting full access to a specific S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #   {
      #     Action   = "s3:CreateBucket"
      #     Effect   = "Allow"
      #     Resource = "arn:aws:s3:::*" # Allows Only creation of any bucket
      #   },
      #   {
      #     Action   = "s3:ListAllMyBuckets" # Allows Only Access of any bucket
      #     Effect   = "Allow"
      #     Resource = "*"
      #   },
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*" # Allows any action to perform with any bucket
        #     Resource = [
        #       "arn:aws:s3:::moduled-bucket-1",
        #       "arn:aws:s3:::moduled-bucket-1/*",
        #       "arn:aws:s3:::moduled-bucket-2",
        #       "arn:aws:s3:::moduled-bucket-2/*"
        #   ]
      }
    ]
  })
}

# Create EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-for-s3"
  role = aws_iam_role.s3_full_access_role.name
}

# Attach the S3 Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_s3_full_access_policy" {
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  role       = aws_iam_role.s3_full_access_role.name
}

