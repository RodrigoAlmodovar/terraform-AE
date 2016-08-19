provider "aws" {
  region     = "${var.region}"#Este accede al variables.tf
}

# Create a load balancer
resource "aws_elb" "web-elb" {
  name 					= "ELBTEST"
  subnets				= ["subnet-013c3c77", "subnet-48401d10", "subnet-c76030ed", "subnet-023f0c3f"]
  security_groups		= ["sg-2ce9ae57"]  
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "TCP:80"
    interval = 30
  }
  tags {
    Name 	= "ELB_TEST"
    ENV		= "TEST"
  }
}

# Create a launch configuration
resource "aws_launch_configuration" "web-lc" {
 name = "LC_TEST"
 image_id = "${lookup(var.amis, var.region)}"
 instance_type = "${var.instance_type}"
 security_groups = ["sg-b8f7b0c3"]
 iam_instance_profile = "${var.iam_profile}"
 user_data = "${file("shared/scripts/userdata.sh")}"
 key_name = "${var.key_name}"
}

# Create an autoscaling group
resource "aws_autoscaling_group" "web-asg" {
 name = "ASG_TEST"
 launch_configuration = "${aws_launch_configuration.web-lc.name}"
 load_balancers = ["${aws_elb.web-elb.name}"]
 max_size = "${var.asg_max}"
 min_size = "${var.asg_min}"
 desired_capacity = "${var.asg_desired}"
 vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
 health_check_type = "${var.health_check_type}"
 tag {
   key = "Name"
   value = "ASG_API"
   propagate_at_launch = true
 }
 tag {
   key = "ENV"
   value = "TEST"
   propagate_at_launch = true
 }
}

#Create scaling policies
resource "aws_autoscaling_policy" "increase-policy" {
  name = "IncreasePolicy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

resource "aws_autoscaling_policy" "decrease-policy" {
  name = "DecreasePolicy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

#Create metric alarms for the policies 
resource "aws_cloudwatch_metric_alarm" "80Percent" {
    alarm_name = "CPUReaches80Percent"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "3"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "80"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
    }
    alarm_description = "This metric monitors if ec2 cpu utilization reaches 80 percent"
    alarm_actions = ["${aws_autoscaling_policy.increase-policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "40Percent" {
    alarm_name = "CPULessThan40Percent"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "3"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "40"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
    }
    alarm_description = "This metric monitors ifec2 cpu utilization is 40 percent or less"
    alarm_actions = ["${aws_autoscaling_policy.decrease-policy.arn}"]
}
