output "instance_public_ips" {
  description = "Public IPs of created instances"
  value       = aws_instance.web[*].public_ip
}
