data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]    
  }
}

resource "aws_instance" "bastion_host" { 
  ami                    = "ami-08718895af4dfa033" #data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instanceType  # Choose an appropriate instance type
  subnet_id              = var.public_subnet_ids[0]  # Replace with the subnet ID where you want to deploy the bastion host
  key_name               = var.keypairname  # Replace with your SSH key pair name
  iam_instance_profile = aws_iam_instance_profile.bastionhostinstance_profile.name
  //iam_instance_profile = var.instance_profile_arn //"eks-f2c78251-ec35-2f40-bf1f-1d36248aef38"
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  root_block_device {
      volume_size = var.ebs_rootvol_size["bastion"]
      volume_type = var.ebs_vol_type["default"]
      encrypted = "true"
      tags = {
          "Name" = "${var.project_name}-${var.environment}-bastionrootvol"
      }
    } 

  tags = {
    Name = "${var.project_name}-${var.environment}-bastionhost"
  }

/*  provisioner "remote-exec" {        
    inline = [
      "export AWS_ACCESS_KEY_ID='${var.aws_access_key_id}'",
      "export AWS_SECRET_ACCESS_KEY='${var.aws_secret_access_key}'",
      "sudo yum install -y docker", // Install Docker
      "sudo systemctl start docker", // Start Docker service
      "sudo systemctl enable docker", // Enable Docker to start on boot
      "sudo usermod -aG docker ec2-user",// Add ec2-user to Docker group to run Docker commands without sudo
      "sudo yum install -y git", // Install git
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl", // Download kubectl binary
      "chmod +x ./kubectl", // Make kubectl binary executable
      "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH", // Move kubectl binary to /usr/local/bin/
      "wget https://github.com/eksctl-io/eksctl/releases/download/v0.175.0/eksctl_Linux_amd64.tar.gz",
      "tar -xvzf eksctl_Linux_amd64.tar.gz -C /tmp",
      "sudo cp /tmp/eksctl /usr/local/bin/", // Move eksctl binary to /usr/local/bin/
      "eksctl version", // Verify the installation
      "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.eks_cluster_name}",
      "curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && chmod 700 get_helm.sh && ./get_helm.sh",
      "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.eks_cluster_name}",
      "kubectl get nodes",
      "helm repo add eks https://aws.github.io/eks-charts",
      "helm repo update"
      //"eksctl utils associate-iam-oidc-provider --region=${var.aws_region} --cluster=${var.eks_cluster_name} --approve",
      //"eksctl create iamserviceaccount --cluster=${var.eks_cluster_name} --namespace=kube-system --name=${var.ekslbcontroller_serviceaccountname} --role-name ${var.ekslbcontroller_iamrolename} --attach-policy-arn=${var.ekslbcontroller_iampolicyarn} --region ${var.aws_region} --approve",
      //"helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=${var.eks_cluster_name} --set serviceAccount.create=false --set serviceAccount.name=${var.ekslbcontroller_serviceaccountname}"
      //"helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kubesystem --set clusterName=stohrmv10-dev-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller"
    ]
    }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("bastionhost-key.pem") // Update with the correct path to your SSH private key
  }*/
  

}

