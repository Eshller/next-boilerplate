# Next.js Boilerplate - AWS Deployment with Terraform

This project includes Terraform configuration to deploy your Next.js application to AWS infrastructure.

## Architecture

### Static Site Only (default)
- **S3 Bucket**: Hosts static build files
- **CloudFront**: Global CDN for fast content delivery
- **IAM Roles**: Secure access between services

### With Server-Side Rendering (optional)
All of the above plus:
- **VPC**: Isolated network environment
- **ECS with Fargate**: Container orchestration for SSR
- **Application Load Balancer**: Routes traffic to containers
- **CloudWatch**: Logging and monitoring

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (>= 1.0)
3. **Docker** (if using SSR with ECS)

## Deployment Options

### Option 1: Static Site Only (Recommended for most cases)

This deploys your Next.js app as a static site using S3 and CloudFront.

1. Build your Next.js application:
   ```bash
   npm run build
   ```

2. Configure Terraform variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred settings
   ```

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Upload your static files to S3:
   ```bash
   # Get the bucket name from terraform output
   BUCKET_NAME=$(terraform output -raw s3_bucket_name)
   
   # Upload static files
   aws s3 sync .next/static/ s3://$BUCKET_NAME/_next/static/
   aws s3 sync out/ s3://$BUCKET_NAME/
   ```

5. Invalidate CloudFront cache:
   ```bash
   DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
   aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
   ```

### Option 2: With Server-Side Rendering

This option uses ECS with Fargate for full Next.js functionality including SSR.

1. **Create ECR Repository**:
   ```bash
   aws ecr create-repository --repository-name next-boilerplate
   ```

2. **Build and Push Docker Image**:
   ```bash
   # Get ECR login
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   
   # Build image
   docker build -t next-boilerplate .
   
   # Tag image
   docker tag next-boilerplate:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/next-boilerplate:latest
   
   # Push image
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/next-boilerplate:latest
   ```

3. **Configure Terraform for SSR**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars`:
   ```hcl
   enable_ssr = true
   ecr_repository_url = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/next-boilerplate"
   ```

4. **Deploy Infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Name of the project | `"next-boilerplate"` |
| `aws_region` | AWS region | `"us-east-1"` |
| `enable_ssr` | Enable server-side rendering | `false` |
| `ecr_repository_url` | ECR repository URL (required for SSR) | `""` |
| `cloudfront_price_class` | CloudFront price class | `"PriceClass_100"` |
| `ecs_cpu` | CPU units for ECS task | `256` |
| `ecs_memory` | Memory for ECS task (MB) | `512` |
| `ecs_desired_count` | Number of ECS tasks | `2` |

## Outputs

After deployment, Terraform will output:

- `deployment_url`: Your application URL
- `s3_bucket_name`: S3 bucket name for uploads
- `cloudfront_distribution_id`: For cache invalidation
- Additional outputs for SSR setup (if enabled)

## Custom Domain

To use a custom domain:

1. **Create ACM Certificate** in `us-east-1` region
2. **Set up Route53 hosted zone** for your domain
3. **Configure variables**:
   ```hcl
   domain_name = "yourdomain.com"
   certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
   route53_zone_id = "Z1234567890123"
   ```

## Monitoring and Logs

- **CloudWatch Logs**: ECS logs (if SSR enabled) at `/ecs/next-boilerplate`
- **CloudFront Metrics**: Available in CloudWatch console
- **ECS Metrics**: Container insights enabled for monitoring

## Cost Optimization

- Use `PriceClass_100` for CloudFront (covers US, Europe)
- Start with minimal ECS resources and scale as needed
- Enable S3 versioning cleanup lifecycle rules for cost control

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **ECR Repository Not Found**: Ensure the ECR repository exists and the URL is correct
2. **ECS Tasks Not Starting**: Check CloudWatch logs for container errors
3. **CloudFront Not Updating**: Cache invalidation can take 10-15 minutes

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# View ECS task logs
aws logs tail /ecs/next-boilerplate --follow

# Check CloudFront distribution status
aws cloudfront get-distribution --id <distribution-id>
```

## Security Considerations

- S3 bucket is private with CloudFront-only access
- ECS tasks run with minimal required permissions
- Security groups restrict access to necessary ports only
- All data encrypted in transit and at rest where supported
