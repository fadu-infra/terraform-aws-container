# ECS 모듈 테스트 시나리오

## 사전 조건

1. VPC 및 서브넷

- ALB와 ECS 용도의 퍼블릭 서브넷 2개, 프라이빗 서브넷 2개

2. ALB

- 퍼블릭 서브넷에 생성
- 타겟 그룹 1개
  - 포트: 80
  - 프로토콜: HTTP
  - 타겟 타입: IP
- 리스너 1개
  - 포트: 80
  - 프로토콜: HTTP
  - 기본 액션: forward type
  - 타겟 그룹: 생성한 타겟 그룹
- 보안 그룹
  - 포트: 80
  - 프로토콜: HTTP
  - 소스: 0.0.0.0/0

## ASG capacity provider를 통해 서비스 배포

1. ECS 클러스터 구성

- Capacity Provider에 ASG와 Fargate를 사용

2. Task Definition 구성

- Task execution IAM role 생성 여부: 활성화
- Task IAM role 생성 여부: 활성화
- CPU: 512
- MEMORY: 1024

- Container definition
  - 컨테이너 이름: "nginx"
  - 이미지: nginx:latest
  - CPU: 512
  - MEMORY: 1024
  - 포트 설정: 80
  - compatibility: "FARGATE", "EC2"
  - network mode: "awsvpc"

3. ECS 서비스 구성

- 1번에서 생성한 클러스터와 2번에서 생성한 태스크 정의를 참조
- Task 수 : 2개
- Capacity Provider Strategy 설정
  - FARGATE: weight 1, base 0
  - ASG: weight 1, base 0
    - Note: Fargate와 ASG를 capacity provider로 사용하는 경우, 서비스의 launch type은 명시하지 않고 capacity provider strategy만 명시합니다.
- 네트워크 설정
  - network 모드: awsvpc
  - security_groups: Task의 보안그룹 생성
    - ALB의 보안그룹을 80 포트로 ingress 허용
    - 0.0.0.0/0으로 모든 포트로 egress 허용
  - subnet: 프라이빗 서브넷
- 로드 밸런서 설정
  - 타겟 그룹 참조
  - 트래픽을 전달할 컨테이너 이름 및 포트 (80 포트) 설정

## 기존 리소스 import

- 콘솔로 생성된 ECS 클러스터, 서비스, 태스크 정의에 대해 terraform import 수행
- import 후 terraform plan에서 상태 차이 없는지 확인
- 전체 리소스가 Terraform에 의해 관리되는지 확인
