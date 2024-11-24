<h1 align="center">TIC-TAC-TOE-GAME</h1>

I forked this github respository and recreated the project.

Build a robust CICD pipelines to deploy a containerized cloud-native application to AWS EKS using Terraform and Github Actions intergrated with Sonarqube and Trivy.


Created an S3 bucket for Terraform backend.

Used Terraform to create the Sonarqube-server. Code used is in the repository

SSH into server and install docker, start docker, enable docker and scripts.sh.

Verified the configuration versions.

Cloned my repository into my local machine. Changed directory into repository.
checked all files.

Changed directory into the Eks-terraform fie.
Ran Terraform commands to deploy EKS cluster

Copied the public IP of the EC2 instance with :9000 to set Sonarqube
Created project and tokens for github access.

Set up Github Action runners on the EC2 Instance

Created a repository on dockerhub for docker push. Ensure token generated for set up with Sonarqube is "read and write"

Deploy the workfile generated by sonarqube through githubaction.
File is present in the repository and contains all steps of application deployment.

Ran kubectl get all on my local machine to get the EKS Pod port and edit the inbound rule of the EKS cluster EC2 instance.

Got the application load balancer url and open in the browser.






