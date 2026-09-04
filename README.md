# agents-dotfiles

컴퓨터를 바꿀 때 다시 설치할 수 있도록 개인 에이전트 지침과 사용자 제작 Skill을 보관하는 저장소입니다.

## 저장 범위

- `config/codex/AGENTS.md`: Codex 전역 지침 (작업 완수·권한·검증에 관한 짧은 기본 계약)
- `config/claude/CLAUDE.md`: Claude Code 전역 지침 (말투, 권한 경계, 코딩 기본 규칙; 작업별 절차는 Skill이 담당)
- `skills/`: 사용자 제작 Skill 원본 (현재 6개는 보관만 하고 전역 설치하지 않음)
- `scripts/sync.ps1`: 현재 PC 내보내기, 새 PC 설치, 드리프트 확인
- `scripts/lint-skills.ps1`: Skill frontmatter, 크기, 참조 링크, `manifest.psd1` 일치 여부 정적 검사
- `scripts/test-sync.ps1`: 임시 홈에서 설치·제거·백업·경로 보호 동작 검증
- `evals/routing-cases.json`: 설명이 인접한 Skill 쌍의 트리거 시드
- `evals/instruction-cases.json`: 승인·작업 범위·검증 종료·모델 보존을 확인하는 수동 평가 시드

Skill은 저장소에서 한 번만 관리합니다. `manifest.psd1`의 `Skills`는 설치 대상, `RemovedSkills`는 이전 관리 대상 중 제거할 이름입니다. `Install`은 `.agents/skills`와 `.claude/skills` 양쪽에 적용됩니다. 현재 `Skills`는 비어 있고 기존 6개는 `RemovedSkills`에 등록되어 있습니다.

## 의도적으로 제외한 항목

다음 항목은 비밀값, 런타임 상태, 머신별 경로 또는 제품이 관리하는 파일이므로 저장하지 않습니다.

- Codex/Claude/Gemini 인증 및 OAuth 파일
- 세션, 대화 기록, 메모리, 로그, SQLite, 캐시, 첨부 파일
- 플러그인 캐시와 설치 상태
- 머신별 프로젝트 경로와 MCP 환경이 포함된 `.codex/config.toml`
- 승인 기록인 `.codex/rules/`
- `.codex/skills/.system`, `pdf`, `playwright`, `hatch-pet` 등 제품·별도 설치 Skill
- `.claude/settings.json`의 로컬 플러그인 경로와 활성화 상태

비밀값이 필요한 설정은 이 저장소에 넣지 말고 새 컴퓨터에서 다시 인증합니다.

## 사용법

PowerShell 7(`pwsh`)에서 실행합니다. `Export`와 `Install`은 기본적으로 미리보기만 하며, 실제 복사·제거에는 `-Apply`가 필요합니다.

현재 PC와 저장소의 차이를 확인합니다. `Check`는 양쪽 설치 경로를 검사하며, 제거 대상이 남아 있으면 `[REMOVE-PENDING]`과 종료 코드 1을 반환합니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Check
```

현재 PC의 설정을 저장소로 내보냅니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Export
pwsh -File ./scripts/sync.ps1 -Mode Export -Apply
git diff --check
git status --short
```

현재 또는 새 PC에 저장소 내용을 적용합니다. 기존 6개 스킬의 전역 설치본을 제거할 때도 같은 명령을 사용합니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install
pwsh -File ./scripts/sync.ps1 -Mode Install -Apply
```

`Install -Apply`는 덮어쓸 기존 파일과 Skill 폴더를 먼저 `~/.agents-dotfiles-backups/<run-id>/`에 백업합니다. 제거 대상 Skill 폴더는 같은 백업 디렉터리로 이동하므로 로컬 수정분과 하위 파일도 보존됩니다. 별도 설치한 스킬과 저장소의 보관 원본은 건드리지 않습니다. Skill 자체가 심볼릭 링크·정션이면 연결 항목만 이동하며 연결 대상은 따라가지 않습니다. 설치 루트나 그 상위 경로가 연결이면 제거를 거부합니다.

향후 Skill을 제거하려면 이름을 `Skills`에서 빼고 `RemovedSkills`로 옮깁니다. 원본은 `skills/`에 보관하거나 삭제할 수 있습니다. 오래 동기화하지 않은 PC에서도 제거되도록 `RemovedSkills` 항목은 유지하세요. 다시 설치하려면 반대로 옮기고 원본을 준비합니다.

단순히 원본 폴더가 없다는 이유로 설치본을 삭제하지는 않습니다. 설치 대상 원본이 없으면 오류로 처리합니다. `Export`는 활성 `Skills`만 내보내며, 제거 목록과 보관 원본을 변경하지 않습니다. 일반 파일 삭제와 활성 스킬 내부의 불필요한 파일 정리는 자동화하지 않습니다.

Skill을 추가하거나 고친 뒤에는 정적 검사를 돌립니다.

```powershell
pwsh -File ./scripts/lint-skills.ps1
```

동기화 스크립트를 변경한 뒤에는 실제 사용자 홈 대신 `work/` 아래 임시 홈을 사용하는 검증을 실행합니다. 검증 자료는 확인을 위해 해당 폴더에 남습니다.

```powershell
pwsh -File ./scripts/test-sync.ps1
```

`evals/`는 실제 모델 실행용 입력과 기대 행동을 기록한 수동 평가 자료입니다. 스킬 평가 시드는 현재 보관된 스킬을 별도 평가 환경에 설치했을 때의 자료입니다. 정적 검사 통과는 모델의 행동 검증을 뜻하지 않습니다. 지침 변경 전후를 비교할 때는 같은 모델·설정·테스트 자료를 사용한 별도 세션에서 실행합니다.

테스트용 홈 경로를 지정할 수도 있습니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install -HomePath ./work/test-home -Apply
```
