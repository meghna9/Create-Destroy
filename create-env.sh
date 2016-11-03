#! /bin/bash

aws ec2 run-instances --image-id ami-06b94666  --key-name meghnalaveti9 --security-group-ids sg-861163ff --instance-type t2.micro --count 1

meghnacloud=`aws ec2 describe-instances  --query 'Reservations[*].Instances[].InstanceId' --filters "Name=instance-state-name, Values=pending"`

aws ec2 wait instance-running --instance-ids $meghnacloud

#echo" Attach load balancer and register instances"
aws elb create-load-balancer --load-balancer-name load-meghna --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-e098b184


#echo "Attach instances to load balancers"
aws elb register-instances-with-load-balancer --load-balancer-name load-meghna --instances $meghnacloud

#echo "Create launch configuration"
aws autoscaling create-launch-configuration --launch-configuration-name launchmeghna --image-id ami-06b94666 --key-name meghnalaveti9 --instance-type t2.micro

#echo "Autoscaling"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name automeghna --launch-configuration launchmeghna --availability-zone us-west-2b --load-balancer-name load-meghna --max-size 5 --min-size 0 --desired-capacity 1



