
resource "null_resource" "provision_bastion" {
  
  connection {
      type        = "ssh"
      host        = var.bastionhost_publicip
      user        = "ec2-user"
      private_key = file("bastionhost-key.pem") // Update with the correct path to your SSH private key
  }
  /*provisioner "file" {
    source      = "./argoapp-installations.sh"  // Path to your script in the Terraform repository
    destination = "/home/ec2-user/argoapp-installations.sh"  // Destination path on the Bastion host
  }*/
  provisioner "file" {
    source      = "./files"  // Path to your script in the Terraform repository
    destination = "/home/ec2-user/"  // Destination path on the Bastion host
  }

  provisioner "remote-exec" {
  inline =  [
    "chmod +x /home/ec2-user/files/argoapp-installations.sh",
    "/home/ec2-user/files/argoapp-installations.sh ${var.aws_region} ${var.eks_cluster_name} ${var.eks_cluster_arn} ${var.eks_cluster_namespace} ${var.eks_applicationcluster_url} ${var.github_username} ${var.github_password} ${var.argocd_clustername} ${var.argocd_application_helmrepo} ${var.argocd_application_helmvalues_filename} ${var.project_name} ${join("#", var.argocd_application_helmservicename-with-path)}" 
    ]
  }

 triggers = {
    #script_checksum = "${md5(file("files/argoapp-installations.sh"))}" # This will trigger only when there is a chnage in file
    always_run = "${timestamp()}"  # This will update the timestamp every time, forcing the trigger
  }
  
}
