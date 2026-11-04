# ERPNext 작업 규칙

- 실제 설치 경로는 이 저장소이며 Docker 프로젝트는 erpnext-local, 사이트는 erp.localhost, 포트는 localhost:8080이다.
- 사용자는 큰 변경마다 GitHub Kyle-Code-CA/ERPNEXT에 저장하고 원복 가능하도록 유지하기를 요청했다.
- 큰 변경 전: 현재 상태를 커밋하고 데이터베이스/첨부파일을 Manage-ERPNext.ps1 -Action Backup으로 로컬 백업한다.
- 큰 변경 후: scripts/export_customizations.py로 DB에 저장된 사용자 정의 화면/스크립트를 내보내고, 검증 결과와 변경 내용을 CHANGELOG.md에 기록하고 커밋 및 GitHub 푸시한다. 성공한 주요 버전에는 checkpoint/날짜-설명 브랜치 또는 태그를 만든다.
- .env, credentials.txt, DB 덤프, 첨부파일, 암호화 키, 실제 업무 데이터는 공개 GitHub에 올리지 않는다. git add -f로 제외 규칙을 우회하지 않는다.
- Git 원복은 코드만 되돌린다. DB 변경이 있는 경우 해당 시점 로컬 백업도 필요하다. 복원 전 현재 상태를 다시 백업하고 임의로 업무 데이터를 덮어쓰지 않는다.
- 원격 저장은 실제 원격 커밋 확인 후 완료로 보고한다. 기존 이력을 강제 푸시하거나 삭제하지 않는다.
- 통합상황판에는 브라우저 localStorage 저장도 있다. 큰 화면 변경 전에 이 상태의 별도 내보내기를 확보해야 하며 DB 백업만으로 모든 상태가 보존된다고 주장하지 않는다.

- 현재 Git CLI의 GitHub 쓰기 인증은 미설정이다. 연결된 GitHub 도구로 원격 커밋을 저장하고 git fetch로 동기화한다. 원격 기준점 브랜치는 checkpoint/2026-11-04-baseline이다.
