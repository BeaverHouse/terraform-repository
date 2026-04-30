# Route53 DNS Management

Route53 호스트 존 및 ExternalDNS / cert-manager 용 IAM 리소스를 관리합니다.

## 관리 리소스

- Route53 호스트 존: `haulrest.me`, `tinyclover.com` (개인 도메인 2개)
- IAM User `dns-manager-user` (+ 정책, Access Key)

## 사전 준비

### 1. AWS CLI 프로파일

AWS CLI가 없다면 설치합니다.

```bash
brew install awscli
```

관리자 권한 IAM User의 Access Key로 `personal` 프로파일을 설정합니다.

```bash
aws configure --profile personal
aws sts get-caller-identity --profile personal
```

### 2. Postgres Backend (Supabase)

state는 Postgres backend에 저장합니다.[^1]

```bash
export PG_CONN_STR="postgres://username:password@hostname:port/database?sslmode=require"
```

## 배포

```bash
terraform init
terraform plan
terraform apply
```

## 출력

```bash
terraform output dns_manager_access_key_id
terraform output dns_manager_secret_access_key  # sensitive
```

ExternalDNS / cert-manager Secret에 위 값을 주입해 사용합니다.

[^1]: https://developer.hashicorp.com/terraform/language/backend/pg
