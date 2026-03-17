terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  cluster_name = "dotohtwo-cluster"
}

module "iam" {
  source = "./modules/iam"
}

module "vpc" {
  source = "./modules/vpc"
}

module "keyspaces" {
  source = "./modules/keyspaces"
}

module "cognito" {
  source = "./modules/cognito"
}

module "rds" {
  source = "./modules/rds"

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.subnet_ids
  ecs_instances_security_group_id = module.vpc.ecs_instances_security_group_id
  db_password                     = var.db_password
  db_instance_class               = var.db_instance_class
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.subnet_ids
  alb_security_group_id           = module.vpc.alb_security_group_id
  ecs_instances_security_group_id = module.vpc.ecs_instances_security_group_id
  instance_profile_arn            = module.iam.instance_profile_arn
  cluster_name                    = local.cluster_name
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name                = local.cluster_name
  subnet_ids                  = module.vpc.subnet_ids
  ecs_tasks_security_group_id = module.vpc.ecs_instances_security_group_id
  dotohtwo_asg_arn            = module.ec2.dotohtwo_asg_arn
  dotohtwo_targetgroup_arn        = module.ec2.dotohtwo_targetgroup_arn
  review_ingestor_targetgroup_arn = module.ec2.dotohtwo_review_ingestor_tg_arn
  execution_role_arn          = module.iam.task_execution_role_arn
  task_role_arn               = module.iam.task_role_arn
  db_endpoint                 = module.rds.db_endpoint
  db_secret_arn               = module.rds.db_secret_arn
  keyspace_name               = module.keyspaces.keyspace_name
  cognito_issuer_uri          = module.cognito.issuer_uri
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
}
