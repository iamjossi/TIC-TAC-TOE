output "runner_public_ip" {
  value = aws_instance.self_hosted_runner.public_ip
  description = "Public IP address of the self-hosted runner EC2 instance"
}
