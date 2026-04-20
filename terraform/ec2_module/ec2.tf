resource "aws_key_pair" "docker_automation_keypair" {
  key_name   = "${var.environment}-CICD-key"
  public_key = file("${path.root}/ec2_module/keys/keys.pub")
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "CICD_Deployment" {
  name = "${var.environment}-CICD-automation-sg"
  description = "This is the security group for CICD Deployment instance"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "SSH-open"
  }
  ingress{
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "http access"
  }

  egress{
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1" # all protocol
    description = "all access open to outbound"
  }
  tags = {
    Environment = var.environment
  }
}

resource "aws_instance" "CICD_instance" {
  ami = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  key_name = aws_key_pair.docker_automation_keypair.key_name
  security_groups = [aws_security_group.CICD_Deployment.name]

  depends_on = [ aws_default_vpc.default,aws_key_pair.docker_automation_keypair,aws_security_group.CICD_Deployment ]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ec2_volume_size
  }

  tags = {
    Name = "${var.ec2_instance_name}"
    Environment = "${var.environment}"
  }
}