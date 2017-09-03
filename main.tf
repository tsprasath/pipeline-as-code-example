# This stack assumes that a Default VPC is present

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
   values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

#resource "aws_instance" "example" {
 #   ami = "ami-6e1a0117"
  #  instance_type = "t2.micro"
   # tags {
    #   Name = "Terraform"
#}

resource "aws_key_pair" "prasath" {
 key_name = "prasath"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx0Jf1esX92CKy8ue88VJ5LK/PCHWvz8JMHpgS8lOIfFj3wIjxs418Ty9uVHsDjST19oSldFbgjGJCE9GyI57tuDCvh8Iesoitb8lLFioFmHcl9nDu378Ts5sbAOQyJa5Ec2Br/xIu2w8XAhz5FwczXrtdNCNhh9WzpgfM1Vy6wr/Mrtv3B1f2yc4ajEcvDtPiHlHaDWjlCYcdQ3MPf/rhjOOmwekDyzxlzObOxt0hXJ4vac9wtnUbNNXrQ2E9HoYeHFZtqWvU31108XXtBtFKh/GAhiDitVT4lnKQvcKDukvp8HXsuTROSnSRLcFAPJEmxo4DykPyolJdy3VhlMa1QIDAQAB"
}


resource "aws_launch_configuration" "test-lc" {
  name_prefix = "test-lc-"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  
  security_groups = [ "${aws_security_group.instance.id}" ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test-asg" {
  name = "test-asg"
  min_size = 1
  max_size = 1
  launch_configuration = "${aws_launch_configuration.test-lc.id}"
  availability_zones = ["${var.region}a"]
}

resource "aws_security_group" "instance" {
  name = "test-sg"
  description = "Allow traffic for test-asg instances"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
