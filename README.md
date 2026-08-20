# agents-dotfiles

컴퓨터를 바꿀 때 다시 설치할 수 있도록 개인 에이전트 지침과 사용자 제작 Skill을 보관하는 저장소입니다.

## 저장 범위

- `config/codex/AGENTS.md`: Codex 전역 지침
- `config/claude/CLAUDE.md`: Claude Code 전역 지침
- `config/claude/guides/`: Claude Code 작업별 가이드
- `skills/`: `.agents/skills`를 원본으로 삼는 사용자 제작 Skill
- `scripts/sync.ps1`: 현재 PC 내보내기, 새 PC 설치, 드리프트 확인

Skill은 저장소에서 한 번만 관리합니다. 설치할 때 `.agents/skills`와 `.claude/skills` 양쪽에 복사하므로 두 에이전트가 같은 사용자 제작 Skill을 사용합니다.

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

PowerShell 7(`pwsh`)에서 실행합니다. `Export`와 `Install`은 기본적으로 미리보기만 하며, 실제 복사에는 `-Apply`가 필요합니다.

현재 PC와 저장소의 차이를 확인합니다.

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

새 PC에 저장소 내용을 설치합니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install
pwsh -File ./scripts/sync.ps1 -Mode Install -Apply
```

`Install -Apply`는 덮어쓸 기존 파일과 Skill 폴더를 먼저 `~/.agents-dotfiles-backups/<timestamp>/`에 백업합니다. 관리 대상 밖의 로컬 파일이나 Skill은 삭제하지 않습니다.

동기화 스크립트는 어느 방향에서도 파일을 삭제하지 않습니다. 로컬에서 제거한 관리 파일이 저장소에 남아 있으면 `Check`가 차이를 보고하므로, 확인 후 Git에서 직접 제거합니다.

테스트용 홈 경로를 지정할 수도 있습니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install -HomePath ./work/test-home -Apply
```
