# Route53 DNS Management

이 디렉토리는 Route53 호스트 존과 DNS 관리에 필요한 IAM 리소스를 관리합니다.

## 포함된 리소스

- `haulrest.me` 호스트 존
- `tinyclover.com` 호스트 존
- ExternalDNS 및 cert-manager용 IAM User (Access Key/Secret Key 포함)

## 사전 준비사항

### 1. AWS IAM User 생성 (개인 사용자용)

AWS 콘솔에서 IAM User를 생성하고 권한을 부여해야 합니다:

1. **IAM User 생성**

   - AWS Console > IAM > Users > "Create user"
   - User name: `terraform-admin` (또는 원하는 이름)
   - "Provide user access to the AWS Management Console" 체크 해제 (CLI 전용)

2. **권한 부여** (다음 중 하나 선택)

   **옵션 A: AdministratorAccess (가장 간단)**

   ```
   - "Attach policies directly" 선택
   - "AdministratorAccess" 정책 검색 후 체크
   ```

   **옵션 B: 서울 리전 제한 (더 안전)**

   - "Create policy" 클릭하여 새 정책 생성
   - JSON 탭에서 다음 내용 입력:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": "*",
         "Resource": "*",
         "Condition": {
           "StringEquals": {
             "aws:RequestedRegion": "ap-northeast-2"
           }
         }
       },
       {
         "Effect": "Allow",
         "Action": ["iam:*", "route53:*", "sts:GetCallerIdentity"],
         "Resource": "*"
       }
     ]
   }
   ```

3. **Access Key 생성**
   - 생성된 User > "Security credentials" 탭
   - "Create access key" > "Command Line Interface (CLI)" 선택
   - Access Key ID와 Secret Access Key 저장 (한 번만 표시됨)

### 2. AWS CLI 로그인

생성한 IAM User의 Access Key로 AWS CLI 설정:

```bash
aws configure --profile personal
```

입력 정보:

- AWS Access Key ID: `위에서 생성한 Access Key ID`
- AWS Secret Access Key: `위에서 생성한 Secret Access Key`
- Default region name: `ap-northeast-2`
- Default output format: `json`

확인:

```bash
aws sts get-caller-identity --profile personal
```

### 3. Postgres Backend 설정 (Supabase)

Terraform 상태를 Postgres에 저장하기 위해 다음 환경변수를 설정하세요:

```bash
export PG_CONN_STR="postgres://username:password@hostname:port/database?sslmode=require"
```

Supabase 연결 정보는 Supabase 대시보드의 Settings > Database에서 확인할 수 있습니다.

### 4. 설정 파일 준비

```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 편집하여 AWS 리전 등 설정
```

## 배포 방법

### 초기 배포

```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 적용
terraform apply
```

### 기존 haulrest.me 존 가져오기

이미 존재하는 `haulrest.me` 호스트 존을 가져오려면:

1. 실제 Zone ID 확인:

```bash
aws route53 list-hosted-zones --query 'HostedZones[?Name==`haulrest.me.`].Id' --output text
```

2. import 스크립트 수정:

```bash
# import-haulrest.sh 파일에서 ZONE_ID_PLACEHOLDER를 실제 Zone ID로 교체
vim import-haulrest.sh
```

3. import 실행:

```bash
./import-haulrest.sh
```

## 출력 정보

배포 완료 후 다음 정보들이 출력됩니다:

- 각 도메인의 Zone ID
- 각 도메인의 Name Servers
- DNS 관리용 IAM User 정보
- Access Key ID
- Secret Access Key (sensitive)

## Access Key 확인

Secret Access Key는 민감한 정보로 표시됩니다. 확인하려면:

```bash
terraform output dns_manager_secret_access_key
```

## ExternalDNS/cert-manager 설정

생성된 IAM User의 Access Key와 Secret Key를 사용하여 ExternalDNS와 cert-manager를 설정하세요:

```yaml
# ExternalDNS secret 예시
apiVersion: v1
kind: Secret
metadata:
  name: external-dns-aws-credentials
  namespace: external-dns
type: Opaque
stringData:
  aws-access-key-id: "<terraform output에서 확인한 Access Key ID>"
  aws-secret-access-key: "<terraform output에서 확인한 Secret Access Key>"
```

## 주의사항

- Access Key와 Secret Key는 안전하게 관리하세요
- Kubernetes Secret으로 저장할 때 base64 인코딩이 자동으로 처리됩니다
- Postgres 연결 정보는 안전하게 관리하세요 (환경변수 권장)
