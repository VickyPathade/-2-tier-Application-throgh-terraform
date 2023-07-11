# launch ec2 instance in pub-sub-1-a

resource "aws_instance" "jump_server"{
    ami =var.ami
    instance_type =var.cpu
    subnet_id=var.public_sub_1_a_id
    vpc_security_group_ids= [var.jump_sg_id]
  key_name               = var.Key_name

  tags={
    Name="book_app_server"
  }

}