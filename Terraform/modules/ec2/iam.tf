data "aws_iam_policy" "AmazonEC2ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
# resource "aws_iam_role" "instance" {
#   name               = "instance_role"
#   path               = "/system/"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }
# resource "aws_iam_role_policy_attachment" "instace-policy-attach" {
#   role       = aws_iam_role.instance.name
#   policy_arn = data.aws_iam_policy.AmazonEC2ReadOnlyAccess.arn
#   depends_on = [
#     data.aws_iam_policy.AmazonEC2ReadOnlyAccess,
#     aws_iam_role.instance
#   ]
# }
# resource "aws_iam_instance_profile" "ec2_read_only_profile" {
#   name = "ec2_read_only_profile"
#   role = aws_iam_role.instance.name
#   depends_on = [
#     aws_iam_role_policy_attachment.instace-policy-attach
#   ]
# }

resource "aws_iam_user" "ec2_read_only" {
  name = "ec2_read_only"
  path = "/system/"

  tags = {
    "Name" = "${var.project_prefix}-ec2_read_only"
  }
}

resource "aws_iam_access_key" "ec2_read_only" {
  user = aws_iam_user.ec2_read_only.name
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.ec2_read_only.name
  policy_arn = data.aws_iam_policy.AmazonEC2ReadOnlyAccess.arn
}