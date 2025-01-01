
resource "null_resource" "provision_bastion" {
  
  connection {
      type        = "ssh"
      host        = var.bastionhost_publicip
      user        = "ec2-user"
      private_key = file("bastionhost-key.pem") // Update with the correct path to your SSH private key
  }
  /*provisioner "file" {
    source      = "./bastionhost-installations.sh"  // Path to your script in the Terraform repository
    destination = "/home/ec2-user/bastionhost-installations.sh"  // Destination path on the Bastion host
  }*/
  provisioner "file" {
    source      = "./files"  // Path to your script in the Terraform repository
    destination = "/home/ec2-user/"  // Destination path on the Bastion host
  }

  provisioner "remote-exec" {
  inline =  [
    "chmod +x /home/ec2-user/files/bastionhost-installations.sh",
    "/home/ec2-user/files/bastionhost-installations.sh ${var.aws_access_key_id} ${var.aws_secret_access_key} ${var.aws_region} ${var.eks_cluster_name} ${var.eks_applicationcluster_url} ${var.eks_cluster_arn} ${var.eks_cluster_namespace} ${var.ekslbcontroller_serviceaccountname} ${var.ekslbcontroller_iamrolename} ${var.ekslbcontroller_iampolicyarn} ${var.github_username} ${var.github_password} ${var.argocd_clustername} ${var.argocd_application_helmrepo} ${var.argocd_application_helmvalues_filename} ${var.project_name} ${join("#", var.argocd_application_helmservicename-with-path)}" 
    ]
  }

 triggers = {
    script_checksum = "${md5(file("files/bastionhost-installations.sh"))}"
  }
}
