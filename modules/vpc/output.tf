output "region" {
  value=var.region
}

output "project_name"{
    value=var.project_name
}

output "vpc_id"{
    value=aws_vpc.vpc_id
}

output "pub_sub_1_a_id"{
    value= aws_subnet.pub-sub-1-a.id
}

output "pub_sub_2_b_id"{
    value= aws_subnet.pub-sub-2-b.id
}


output "pri_sub_3_a_id"{
    value= aws_subnet.pri-sub-3-a.id
}

output "pri_sub_4_b_id"{
    value= aws_subnet.pri-sub-4-b.id
}

output "pri_sub_5_a_id"{
    value= aws_subnet.pri-sub-5-a.id
}

output "pri_sub_6_b_id"{
    value= aws_subnet.pri-sub-6-b.id
}