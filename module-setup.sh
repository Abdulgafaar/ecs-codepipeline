#!//usr/bin/bash
# Creation of terraform folder struction for all project

sudo mkdir modules
sudo touch backend.tf
sudo touch local.tf
sudo touch main.tf
sudo touch output.tf
sudo touch variable.tf
sudo mkdir modules/ecs
sudo mkdir modules/codepipeline
