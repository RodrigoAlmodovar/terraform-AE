#Terraform-AWS
===========

This project builds an autoscalable system in AWS by creating an ELB, a launch configuration and an autoscaling group in the same way as the previous projects jenkins&AWS and awscli.

How to use it
===========

##1. Manually

Previous to perform the terraform actions, the user must:
Create an VPC, Subnets and Security Groups.
- Bastion must be reachable by SSH from the admin IP and it must have access to the instance by SSH
- The API instances must be reachable by HTTP from anywhere and just from the Bastion by SSH
- ELB must be reachable by HTTP

##2. Terraform magic
- Clone the repository to your local folder:


    $ git clone https://RodrigoAlmodovar_sng@bitbucket.org/RodrigoAlmodovar_sng/terraform-aws.git
    $ terraform plan
    $ teraform apply


Whenever you decide to destroy your project:

    $ teraform destroy


##Explanation
===========
###createArchitecture.tf
Terraform file that will be loaded and runned. It creates the whole architecture calling the variables.tf file.

###variables.tf
Terraform variable file which includes different variables called by crateArchitecture.tf.
This file's main purpose is to act as a configuration file so the user would just modify the parameters here and not in the big createArchitecture.tf

###userdata.sh
This will be the code that the machine will execute (as root) as soon as it comes to life. It will update&upgrade the machine and install everything needed for the awscli, after all, it will copy the initialization.sh file from s3 to its dependencies, change its permissions and execute it.
It is passed to the machine in the createLaunchConfiguration script.

###initialization.sh
Install nginx and modify the files and virtual host needed to configure a site with 40 html files.
To access the pages: curl api.localhost
This file must be placed in a bucket within S3.
