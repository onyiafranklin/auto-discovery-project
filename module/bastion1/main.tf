# Create Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-bastion-sg"
  description = "Allow only outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}

# Create IAM role for SSM
resource "aws_iam_role" "bastion_ssm_role" {
  name = "${var.name}-bastion-ssmrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach SSM Core Policy for Session Manager Access
resource "aws_iam_role_policy_attachment" "bastion_ssm_attachment" {
  role       = aws_iam_role.bastion_ssm_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create IAM Instance Profile for Bastion
resource "aws_iam_instance_profile" "bastion_ssm_profile" {
  name = "${var.name}-ssm-bastion-profile"
  role = aws_iam_role.bastion_ssm_role.id
}

data "aws_ami" "redhat" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat official owner
  filter {
    name   = "name"
    values = ["RHEL-9.*x86_64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance to create a Bastion server
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.redhat.id
  instance_type               = "t2.medium"
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name # SSH key
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_ssm_profile.name
  associate_public_ip_address = true
    user_data = templatefile("${path.module}/userdata.sh", {
    privatekey = var.privatekey,
    nr-key     = var.nr-key,
    nr-acc-id  = var.nr-acc-id,
    region     = var.region
  })
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  metadata_options {
    http_tokens = "required"
  }
  # user_data = ""
  tags = {
    Name = "${var.name}-bastion"
  }
}


