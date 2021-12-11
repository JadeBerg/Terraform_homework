output "nginx_external_ip" {
  value = aws_eip.elastic_ip.public_ip
}