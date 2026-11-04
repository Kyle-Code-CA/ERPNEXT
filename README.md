# ERPNext 로컬 업무 시스템

Windows + Docker Desktop에서 실행하는 ERPNext 사용자 정의 화면과 운영 스크립트의 버전 기록입니다.

## 실행

기존 설치 PC에서는 바탕 화면 ERPNext 또는 `Manage-ERPNext.ps1 -Action Start`를 사용합니다. 주소는 http://localhost:8080 입니다.

이 저장소만 복제해서 기존 데이터가 복원되지는 않습니다. `.env`, 사이트 설정과 DB/첨부파일 백업은 로컬에 별도로 보관합니다. 공개 저장소에는 비밀번호와 업무 데이터를 저장하지 않습니다.

## 큰 변경마다 저장

1. 변경 전 `Manage-ERPNext.ps1 -Action Backup`으로 로컬 백업합니다.
2. 사용자 정의 화면/스크립트를 내보내 `customizations/site.json`에 저장합니다.
3. 변경 내용을 검증하고 CHANGELOG.md에 검증 결과와 대응 백업 폴더를 기록합니다.
4. Git 커밋 후 GitHub에 푸시하고 주요 상태에 checkpoint 태그를 남깁니다.

내보내기: `Get-Content -Raw scripts/export_customizations.py | docker exec -i erpnext-local-backend-1 /home/frappe/frappe-bench/env/bin/python -` (출력을 UTF-8로 customizations/site.json에 저장).

## 원복

코드 변경은 이전 커밋을 기준으로 검토 후 `git revert`로 되돌립니다. DB에 저장된 화면, 스크립트, 업무 데이터는 Git만으로 복구되지 않습니다. 해당 시점의 `backups` 폴더에 있는 DB/공개·비공개 첨부파일/사이트 설정을 함께 사용해야 합니다. 먼저 현재 상태도 백업하고, 별도 사이트에서 복원을 검증한 뒤 적용합니다. DB 복원은 백업 이후 입력된 데이터를 덮어쓸 수 있습니다.

`customizations/site.json`은 비교 및 재적용 개발용이며 자동 전체복원 도구가 아닙니다.

통합상황판 코드에는 브라우저 localStorage에 상태를 저장하는 부분도 있습니다. 이 상태는 Git 및 DB 백업에 포함되지 않으므로, 큰 화면 변경 전 화면의 내보내기/스냅샷 기능으로 별도 보관하고 복원 여부를 확인해야 합니다.

공식 ERPNext/Frappe 소스는 Docker 이미지에 포함됩니다. 저장소에는 사용한 compose 파일과 라이선스를 보관합니다.
