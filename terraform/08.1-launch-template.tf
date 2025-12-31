resource "aws_launch_template" "eks-launch-template" {
  name_prefix   = "eks-nodes-"
  instance_type = "t3.large"             

  metadata_options {
    http_tokens               = "required"
    http_put_response_hop_limit = 2
    http_endpoint             = "enabled"
    http_protocol_ipv6        = "disabled"
    instance_metadata_tags    = "disabled"
  }

  lifecycle {
    create_before_destroy = true
  }

}