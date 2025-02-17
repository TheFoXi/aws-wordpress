# # Create an IAM user with read-only permissions
# resource "aws_iam_user" "readonly_user" {
#   name          = "readonly" # Name of the IAM user
#   path          = "/"                    # Defines the hierarchical path for the user
#   force_destroy = true                   # Allows deletion of the user even if access keys exist
# }
#
# # Output the IAM user name
# output "readonly_user_name" {
#   value = aws_iam_user.readonly_user.name # Returns the created IAM user name
# }
#
# # Attach the AWS-managed ReadOnlyAccess policy to the user
# resource "aws_iam_user_policy_attachment" "readonly_attach" {
#   user       = aws_iam_user.readonly_user.name          # Specifies the IAM user to attach the policy to
#   policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS-managed policy providing read-only access
# }
#
# # Create an IAM access key for the user
# resource "aws_iam_access_key" "readonly_key" {
#   user = aws_iam_user.readonly_user.name # Assigns the access key to the read-only IAM user
# }
#
# # Output the Access Key ID for the IAM user
# output "readonly_user_access_key" {
#   description = "Access Key ID for readonly user"
#   value       = aws_iam_access_key.readonly_key.id # Retrieves the IAM access key ID
# }
#
# # Output the Secret Access Key for the IAM user (marked as sensitive for security)
# output "readonly_user_secret_key" {
#   description = "Secret Access Key (store securely!)"
#   value       = aws_iam_access_key.readonly_key.secret # Retrieves the IAM secret key
# }
#
# resource "aws_iam_user_login_profile" "readonly_user_profile" {
#   user                    = aws_iam_user.readonly_user.name
#   password_reset_required = false                      # Set false so that password reset is not required at first login
# }
