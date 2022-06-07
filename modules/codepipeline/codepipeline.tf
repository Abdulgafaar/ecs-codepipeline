provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "source" {
  bucket = "etz-middleware-pipeline-artifacts-source"
  acl    = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-terraform"
  assume_role_policy = file("codepipeline_role.json")

}

data "template_file" "codepipeline_policy"{
  template = file("codepipeline.json")

  vars = {
    aws_s3_bucket_arn = aws_s3_bucket.source.arn
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  policy = data.template_file.codepipeline_policy.rendered
  role   = aws_iam_role.codepipeline_role.id
}

/*
/* CodeBuild
*/

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role-terraform"
  assume_role_policy = file("codebuild_role.json")
}

data "template_file" "codebuild_policy" {
  template = file("codebuild_policy.json")

  vars = {
    aws_s3_bucket_arn = aws_s3_bucket.source.arn
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy"
  policy = data.template_file.codebuild_policy.rendered
  role   = aws_iam_role.codebuild_role.id
}

data "template_file" "buildspec" {
  template = file("buildspec.yml")

  vars = {
    repository_url     = var.repository_url
    cluster_name       = var.ecs_cluster_name
    subnet_id          = var.run_task_subnet_id
    security_group_ids = var.run_task_security_group_ids
  }
}

resource "aws_codebuild_project" "etz-middleware_build" {
  name          = "etz-middleware-codebuild"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type = "CODEPIPELINE"
    buildspec = data.template_file.buildspec.rendered
  }
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "etz-middleware_terraform-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.source.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn     = var.codestar_connections
        #        Owner            = "AWS"
        FullRepositoryId  = var.repository_url
        BranchName        = "dev"

      }
    }
  }

  stage {
    name = "Build_Staging"

    action {
      name             = "Build_staging"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["imagedefinitions"]

      configuration = {
        ProjectName = "etz-middleware-codebuild"
      }
    }
  }

  stage {
    name = "Deploy_Staging"

    action {
      name            = "Deploy_Staging"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
