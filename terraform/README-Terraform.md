# Infrastructure Lead (Person 1) — Terraform / AWS Networking / Provisioning

## Objectif
Ce dépôt contient l’infrastructure **AWS** provisionnée avec **Terraform** pour supporter une chaîne CI/CD et un déploiement applicatif sur **ECS Fargate**, avec une séparation **DEV / PROD**.  
Le périmètre de Person 1 couvre principalement : **réseau (VPC)**, **provisionnement des ressources de base**, et **socle ECS** prêt à consommer des images Docker (ECR) et à écrire des logs (CloudWatch). [file:1]

---

## Périmètre réalisé (Person 1)
### 1) Module VPC (réseau)
Implémentation d’un module réutilisable `terraform/modules/vpc` puis intégration dans :
- `terraform/dev` (2 AZ, *single* NAT gateway pour réduire les coûts)
- `terraform/prod` (3 AZ, NAT gateway par AZ pour meilleure disponibilité)

Ressources typiques créées par le module VPC :
- VPC
- Subnets publics + privés (multi-AZ)
- Internet Gateway + routes publiques
- NAT Gateway + routes privées (DEV = 1 NAT / PROD = 1 NAT par AZ)

**Outputs exposés (contrat réseau pour l’équipe ECS/ALB)** :
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids` [file:1]

### 2) Tests Terraform validés
Commandes exécutées avec succès :
- `terraform init`
- `terraform validate`
- `terraform plan` (DEV & PROD)
- `terraform apply` (DEV uniquement pour validation réelle des ressources)
- `terraform destroy` (DEV après test pour éviter les coûts NAT)

Objectif : vérifier que le module VPC fonctionne réellement et que les outputs nécessaires à ECS sont disponibles. [file:1]

### 3) Module ECS (Fargate) — Solution 2 (2 images)
Mise en place / adaptation du module `terraform/modules/ecs` pour déployer une application sous **ECS Fargate** avec **2 containers** dans une même task :
- `backend` : Spring Boot
- `frontend` : Angular servi par Nginx (reverse proxy possible vers le backend via `localhost`)

Le module ECS crée :
- CloudWatch Log Group (logs applicatifs)
- ECS Cluster
- IAM Execution Role pour Fargate
- Task Definition (2 containers)
- ECS Service (Fargate) dans les subnets privés [file:1]

> Remarque : le brief prévoit un déploiement (rolling/blue-green) et une mise à jour de service ECS via pipeline. [file:1]

---

## Architecture Terraform (résumé)
Conforme à la structure attendue : [file:1]
- `terraform/modules/vpc/` : réseau AWS
- `terraform/modules/ecs/` : cluster/service/task ECS Fargate
- `terraform/dev/` : orchestration DEV (variables + main + backend)
- `terraform/prod/` : orchestration PROD (variables + main + backend)

---

## Fichiers importants (Person 1)
### `terraform/modules/vpc/*`
- `main.tf` : VPC, subnets, IGW, NAT, routes
- `variables.tf` : CIDR, AZs, options NAT, tags
- `outputs.tf` : `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
- `versions.tf` : versions Terraform/providers

### `terraform/modules/ecs/*`
- `main.tf` : cluster, log group, IAM execution role, task definition (2 containers), service
- `variables.tf` : `frontend_image`, `backend_image`, ports, cpu/memory, subnets privés, vpc_id
- `outputs.tf` (si présent) : noms cluster/service/log group utiles à la CI

### `terraform/dev/*`
- `main.tf` : appelle `module vpc` + `module ecs`
- `variables.tf` : reçoit `frontend_image` et `backend_image` (fournies par la CI)
- `backend.tf` : backend remote state (S3 recommandé par le brief) [file:1]

### `terraform/prod/*`
Idem DEV mais paramétrage PROD (HA, apply manuel côté pipeline). [file:1]

---

## Comment exécuter (local)
### DEV — Init / Validate / Plan

terraform -chdir=terraform/dev init
terraform -chdir=terraform/dev validate
terraform -chdir=terraform/dev plan -out=plan.out


### DEV — Plan avec images (exemple)
Deux options :

**Option A : passer les variables en ligne (CMD Windows : une seule ligne)**
terraform -chdir=terraform/dev plan -out=plan.out -var="backend_image=<ECR_BACKEND_URI:tag>" -var="frontend_image=<ECR_FRONTEND_URI:tag>"


**Option B : fichier tfvars**
Créer `terraform/dev/terraform.tfvars` :

backend_image = "<ECR_BACKEND_URI:tag>"
frontend_image = "<ECR_FRONTEND_URI:tag>"

Puis :
terraform -chdir=terraform/dev plan -out=plan.out


### DEV — Apply (à faire seulement si nécessaire)
terraform -chdir=terraform/dev destroy


---

## Points d’attention / limites actuelles
- Les tâches ECS sont configurées en subnets privés (`assign_public_ip = false`). Sans **ALB** (prévu par le brief), l’application ne sera pas accessible publiquement. [file:1]
- Les images doivent exister dans ECR (poussées par la CI) avant un `apply` ECS, sinon le service peut échouer au démarrage. [file:1]
- Pour respecter complètement le brief, le backend Terraform (state) doit être stocké sur S3 séparé DEV/PROD, et les plans peuvent être gérés comme artefacts (`plan.out`). [file:1]

---

## Handover à l’équipe
À transmettre aux autres membres :
- Les outputs VPC (vpc_id + subnets) pour brancher ALB/ECS/monitoring. [file:1]
- Les variables attendues par le module ECS :
  - `backend_image` (ECR URI)
  - `frontend_image` (ECR URI)
- Recommandation : ajouter un ALB public (dans subnets publics) et router vers le container frontend:80, tout en gardant les tasks en subnets privés (pattern du diagramme). [file:1]
