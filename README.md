# 🚀 DevOps Project — GitLab CI/CD + Terraform + AWS
**ECS Fargate + ALB + ECR + RDS + SQS + Lambda
**
---

<details>
<summary>🎯 <strong>Objectif</strong></summary>
Ce dépôt implémente une chaîne CI/CD complète avec GitLab CI et Terraform pour provisionner et déployer une application Full Stack sur AWS ECS Fargate (2 containers : backend + frontend), exposée via un ALB, avec RDS, SQS + Lambda et ECR.
</details>

<details>
<summary>🏗 <strong>Architecture (Résumé)</strong></summary>

- **VPC (DEV/PROD)** : subnets publics + privés (multi-AZ) + NAT (DEV optimisé coût)  
- **ALB public** : écoute HTTP:80 → Target Group “frontend”  
- **ECS Fargate** : 1 task désirée avec 2 containers (backend + frontend)  
- **ECR** : 2 repos → brief3-backend & brief3-frontend  
- **RDS MySQL** : DB privée pour ECS  
- **SQS + Lambda** : Lambda packagée en zip → deploy depuis S3  

</details>

<details>
<summary>🧩 <strong>Architecture du projet (Vue logique AWS)</strong></summary>

- **VPC (us-east-1)** : public + private subnets  
- **NAT Gateway** : accès Internet pour tasks privées  
- **ALB** : HTTP:80 → Target Group IP:80 → [URL DEV](http://devops-project-dev-alb-973074401.us-east-1.elb.amazonaws.com/)  
- **ECS Fargate** : cluster + service + 2 containers (frontend Nginx 80, backend Spring 8080)  
- **ECR** : brief3-backend + brief3-frontend  
- **RDS (MySQL)** : privé, accessible ECS SG  
- **SQS + Lambda worker** : zip stocké en S3 → Terraform  

**Flux HTTP**: Navigateur → ALB → frontend (Target Group) → backend via localhost  
**Flux CI/CD**: package_lambda → upload_lambda_s3 → terraform plan/apply → build/package → deploy ECS

</details>

<details>
<summary>🔗 <strong>Liens Réels (DEV)</strong></summary>

- URL ALB : [frontend](http://devops-project-dev-alb-973074401.us-east-1.elb.amazonaws.com/)  
- AWS Region : us-east-1  

</details>

<details>
<summary>📂 <strong>Structure du repository</strong></summary>

- `terraform/modules/` : modules Terraform  
- `terraform/dev/` : environnement DEV  
- `terraform/prod/` : environnement PROD  
- `.gitlab-ci.yml` : pipeline CI/CD  

</details>

<details>
<summary>⚙️ <strong>Prérequis</strong></summary>

- Terraform, AWS CLI, Docker  
- Variables GitLab CI/CD : AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ACCOUNT_ID, AWS_REGION, TF_VAR_db_password, LAMBDA_S3_BUCKET  

</details>

<details>
<summary>🛠 <strong>Pipeline GitLab CI/CD (Stages)</strong></summary>

- validate  
- package_lambda → dist/lambda_nodejs.zip  
- upload_lambda_s3 → S3  
- terraform_validate → init + validate Terraform  
- infra_plan → tfplan  
- infra_apply → manuel  
- build → backend + frontend  
- package → push ECR  
- deploy → ECS redeploy  
- cleanup → destroy manuel  

</details>

<details>
<summary>🧪<strong> Tests post-déploiement (DEV)</strong></summary>

1. Test HTTP frontend via ALB  
2. Vérifier ECS → service stable  
3. Vérifier Target Group → au moins 1 target Healthy  

</details>

<details>
<summary>☁️ <strong>Buckets S3</strong></summary>

- bucket-dev-brief3  
- bucket-prod-brief3  

</details>

<details>
<summary>💻 <strong>Commandes utiles</strong></summary>

<pre style="background-color:#272822; color:#f8f8f2; padding:10px; border-radius:5px; overflow-x:auto;">
terraform -chdir=terraform/dev init
terraform -chdir=terraform/dev validate
terraform -chdir=terraform/dev output
terraform -chdir=terraform/dev output -raw alb_dns_name
</pre>

</details>

<details> <summary>⚠️ <strong>Troubleshooting<strong></summary>
<ul>
<li>amazon/aws-cli GitLab CI : entrypoint: [""] si erreurs</li>
<li>Variables ECS vides → lire via terraform output -raw</li>
<li>Terraform “Unsupported argument” → vérifier modules pushés</li>
<ul>
</details>
<hr style="border:1px solid #4CAF50;">
<p style="text-align:center; color:#777; font-size:0.9em;">Made with 😇 by Yassine Chahbounia & Khadija Makkaoui</p>