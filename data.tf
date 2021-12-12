data "aws_ami" "debian" {
  most_recent = var.ami_most_recent
  owners = var.ami_owners

  dynamic "filter" {
    for_each =  var.ami_filters
    content {
      name = filter.key
      values = filter.value
    }
  }
}