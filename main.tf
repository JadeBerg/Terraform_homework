resource "aws_eip" "elastic_ip" {
  instance = aws_instance.devops_task_6c.id
}

resource "aws_key_pair" "tf-key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_file)
}

resource "aws_instance" "devops_task_6c" {
  ami           = data.aws_ami.debian.id
  instance_type = var.ec2_instance_type

  vpc_security_group_ids = [aws_security_group.devops-task.id]

  key_name = aws_key_pair.tf-key.id

  root_block_device {
    volume_size = var.boot_disk_size
  }

  user_data = file(var.bootstrap_script_file)
}