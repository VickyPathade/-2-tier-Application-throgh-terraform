resource "aws_launch_template" "this" {
  name ="${var.project_name}-tpl"
  image_id=var.ami
  instance_type=var.cpu
  key_name=var.key_name
  user_data = filebase64("../module/asg/config.sh")
  vpc_security_group_ids=[var.client_sg_id]

  tags={
    Name= "${var.project_name}-tpl"
  }
}

resource "aws_autoscaling_group" "this" {
  name = "${var.project_name}"
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.desired_cap
  health_check_grace_period = 300
  health_check_type = var.asg_health_check_type
  vpc_zone_identifier = [ var.pri_sub_3_a_id, pri_sub_4_b_id ]
  target_group_arns = [ var.tg_arn ]

  enabled_metrics = [ 
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
   ]

   metrics_granularity = "1Minute"

   launch_template {
     id = aws_launch_template.this.id
     version=aws_launch_template.this.latest_version
   }
}

# scale up policy
resource "aws_autoscalling_policy" "scale_up" {
  name= "${var.project_name}-asg-scale-up"
  scaling_adjustment = "1"
  adjustment_type="ChangeInCapacity"
  autoscaling_group_name=aws_autoscaling_group.this.name
  cooldown = "300"
  policy_type = "SimpleScalling"

}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name ="CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
  dimensions ={
    AutoScalingGroupName=aws_autoscaling_group.this.name
  }
  actions_enabled = true
  alarm_actions=[aws_autoscalling_policy.scale_up.arn]
}
# scale down policy
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm"{
    alarm_name="${var.project_name}-asg-scale-down-alarm"
    alarm_description="asg-scale-down-cpu-alarm"
    comparison_operator="LessThanOrEqualToThreshold"
    evaluation_periods="2"
    metric_name="CPUUtilization"
    namespace="AWS/EC2"
    period="120"
    statistic="Average"
    threshold="5"
    dimensions={
        AutoScalingGroupName=aws_autoscaling_group.this.name,
    }
    actions_enabled = true
    alarm_actions=[aws_autoscalling_policy.scale_down.arn]

}