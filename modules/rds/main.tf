resource "aws_db_subnet_group" "book-shop-subnet" {
  name= var.db_sub_name
  subnet_ids =[ var.pri_sub_5_a_id, var.pri_sub_6_b_id]
}

resource "aws_db_instance" "book-db"{
    identifier = "book-db"
    engine     ="mysql"
    engine_version = "5.7"
    instance_class="db.t2.micro"
    allocated_storage   = 20
    storage_type        = "gp2"
    username            = var.db_username
    password            = var.db_password
    db_name = var.db_name
    multi_az = true
    storage_encrypted = false
    publicly_accessible = false
    db_subnet_group_name= aws_db_subnet_group.book-shop-subnet.name
    vpc_security_group_ids=[var.db_sg_id ]
    skip_final_snapshot = true
    backup_retention_period = 0

    tags={
        Name="book-DB"
    }
    
}