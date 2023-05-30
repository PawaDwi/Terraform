

resource "aws_eip" "example" {
  # instance = data.terraform_remote_state.ec2.outputs.aws_instance_id
  # vpc = true
}
