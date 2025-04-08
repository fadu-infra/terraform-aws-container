# ECS 모듈 테스트 시나리오

## ASG capacity provider를 통해 서비스 배포

- Task Definition 생성 및 container 정의 등록 확인
- ECS 서비스가 지정한 클러스터와 태스크 정의를 참조해 생성되는지 확인
- ECS 서비스가 지정한 Capacity Provider를 통해 태스크를 실행하는지 확인

## Fargate capacity provider를 통해 서비스 배포포

- Task Definition 정상 생성 및 container 정의 등록 확인
- ECS 서비스가 지정한 클러스터와 태스크 정의를 참조해 생성되는지 확인
- ECS 서비스가 지정한 Capacity Provider를 통해 태스크를 실행하는지 확인

## 기존 리소스 import 테스트

- 콘솔로 생성된 ECS 클러스터, 서비스, 태스크 정의에 대해 terraform import 수행
- import 후 terraform plan에서 상태 차이 없는지 확인
- 전체 리소스가 Terraform에 의해 관리되는지 확인
