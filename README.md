# My CI/CD Pipeline Project

## Overview

This project demonstrates the creation of a fully automated CI/CD pipeline using Jenkins, Terraform, Docker, and Amazon ECS. The pipeline deploys a React web application, containerized with Docker, onto an ECS Fargate cluster. The application features a carousel of BMW images, hosted on AWS S3 and served via CloudFront.

## Architecture Diagram

Below is a simplified architecture diagram showing the components involved:

```plaintext
  GitHub --> Jenkins --> Terraform --> AWS (ECR, ECS, S3, CloudFront, DynamoDB)
         \__________________________/          \__________________________/
                          |                                      |
                    Code Repository                     Infrastructure & Services