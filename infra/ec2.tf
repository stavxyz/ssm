
provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "ami_name_regex" {
  # For Amazon Linux, use '^amzn-ami-hvm'
  default = "^ubuntu/images/hvm-ssd/ubuntu-xenial"
}

variable "instance_type" {
  default = "t2.micro"
}


variable "ami_owners" {
  type = "list"
  # 099720109477 = Canonical
  default = ["amazon", "099720109477"]
}


# NOTE: At least one of executable_users, filter,
# owners, or name_regex must be specified.

data "aws_ami" "this" {
  most_recent = true
  name_regex = "${var.ami_name_regex}"
  owners = ["${var.ami_owners}"]

  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "is-public"
    values = ["true"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "image-type"
    values = ["machine"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "ssm_instance" {
  ami = "${data.aws_ami.this.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ssm_instance_profile.id}"
}

output "ssm_ec2_instance_id" {
  value = "${aws_instance.ssm_instance.id}"
}

output "image_id" {
  value = "${data.aws_ami.this.image_id}"
}

output "image_description" {
  value = "${data.aws_ami.this.description}"
}

output "image_name" {
  value = "${data.aws_ami.this.name}"
}

