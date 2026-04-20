module "ec2" {
  source = "./ec2_module"
  ec2_instance_name = var.ec2_instance_name
  ec2_ami_id = var.ec2_ami__id
  ec2_volume_size = var.ec2_instance_volume_size
  ec2_instance_type = var.instance_type
  environment = local.Environment
}