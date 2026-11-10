# agents-dotfiles

컴퓨터를 바꿀 때 다시 설치할 수 있도록 개인 에이전트 지침과 관리 대상 Skill을 보관하는 저장소입니다.

## 저장 범위

- `config/claude/CLAUDE.md`: Claude Code 전역 지침 (말투, 글쓰기, 승인 경계, 코딩 기본 규칙)
- `config/codex/AGENTS.md`: Codex 전역 지침 (작업 완수·권한·검증에 관한 짧은 기본 계약)
- `skills/`: 설치 대상 Skill 원본
- `manifest.psd1`: 동기화할 파일, 설치할 Skill(`Skills`), 제거할 Skill(`RemovedSkills`)
- `scripts/sync.ps1`: 현재 PC 내보내기, 새 PC 설치, 드리프트 확인
- `scripts/lint-skills.ps1`: Skill frontmatter, 크기, 참조 링크, `manifest.psd1` 일치 여부 정적 검사
- `scripts/test-sync.ps1`: 임시 홈에서 설치·제거·백업·경로 보호 동작 검증
- `evals/routing-cases.json`: Skill 선택(트리거) 확인용 수동 시드
- `evals/instruction-cases.json`: 승인·작업 범위·중단 조건·보고 형식을 확인하는 수동 시드

## Skill

Skill은 저장소에서 한 번만 관리하고 `Install`이 `.agents/skills`와 `.claude/skills` 양쪽에 적용합니다.

| Skill | 사용할 때 |
| --- | --- |
| `engineering-review` | 구조·모듈 경계·인터페이스 설계, 리팩터링 계획, 유지보수성 점검 |
| `test-audit` | 테스트 작성·수정·검토, 회귀 검증 선택, 중복·구현 결합 테스트 정리 |
| `explain-with-artifacts` | 근거가 있는 도식, 변경 전후 비교, 단계별 설명, 작은 인터랙티브 HTML |

Skill에는 모델이 스스로 알 수 없는 판단 기준과 개인 선호만 둡니다. 일반적인 절차, 승인 규칙, 교과서적 지식은 넣지 않습니다. 승인과 범위는 전역 지침이 담당하므로 Skill마다 반복하지 않습니다. 공용 Skill에는 특정 프로젝트의 전제나 문서 경로를 넣지 않습니다.

`engineering-review`의 모듈 형태 기준(깊은 모듈, 삭제 테스트, 경계의 근거)은 John Ousterhout의 *A Philosophy of Software Design*과 [Matt Pocock의 codebase-design 스킬](https://github.com/mattpocock/skills)의 개념을 다시 쓴 것입니다. `test-audit`는 OpenClaw의 `test-audit`를 바탕으로 다시 구성한 개인용 변형이며 원본의 MIT 고지를 `skills/test-audit/LICENSE.txt`에 보존합니다.

### 제거한 Skill

다음 Skill은 삭제했고 원본은 Git 이력에만 있습니다. 오래 동기화하지 않은 PC에서도 설치본이 제거되도록 `RemovedSkills` 항목은 유지합니다.

| Skill | 제거 이유 |
| --- | --- |
| `delegate-research` | 위임을 권하는 상시 지침은 현재 Claude 모델에서 서브에이전트를 필요 이상으로 늘립니다. 위임 기준은 전역 지침 한 줄로 충분합니다. |
| `commit-context` | 커밋 본문에 확인된 이유를 남기는 규칙은 전역 지침 한 줄이 담당합니다. 이력 조회 절차는 모델이 이미 수행합니다. |
| `codebase-design` | 판단 기준을 `engineering-review`에 통합했습니다. 원본은 서브에이전트 3개 이상 병렬 실행을 지시했고 경계 기준이 다른 Skill과 충돌했습니다. |
| `prompt-engineering` | 모델별 참고 문서가 한 세대 전(Fable 5.1) 기준이었습니다. 아래 공식 가이드를 직접 봅니다. |
| `creative-writing`, `creative-worldbuilding`, `creative-lore-consolidation`, `release-prep`, `work-continuity` | 이미 설치 대상에서 빠져 보관만 하던 Skill입니다. |

되살리려면 이력에서 폴더를 복원하고 이름을 `RemovedSkills`에서 `Skills`로 옮깁니다.

```powershell
git checkout c975f3c -- skills/commit-context
```

## 지침을 고칠 때의 기준

지침과 Skill은 대상 모델의 공식 프롬프팅 가이드에 맞춰 점검합니다. 마지막 점검은 2026-11-10입니다. `CLAUDE.md`와 Skill은 Claude 가이드 두 편, `AGENTS.md`는 OpenAI 가이드를 기준으로 했습니다.

- [Prompting Claude Fable 5.2](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2)
- [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
- [Using GPT-6: Prompting best practices](https://developers.openai.com/api/docs/guides/latest-model#prompting-best-practices) (GPT-6 Astra 기준, GPT-6.1 Sol에도 같은 출발점)

`AGENTS.md`에는 Astra 가이드가 짚은 다섯 가지 성향을 반영했습니다.

- 질문하며 멈추는 성향: 요청형 표현을 실행 지시로 보고, 승인은 검토 가능한 결과를 준비한 뒤 마지막 단계로 받습니다. 가이드는 draft PR 생성까지 자율로 두지만 여기서는 커밋·푸시·PR에 승인을 유지합니다.
- Skill 지침에 민감한 성향: 사용자 지시가 Skill보다 우선하고, Skill 때문에 멈추면 해당 `SKILL.md`와 문장을 밝히게 합니다.
- 목록·표 위주의 서식과 상투어: 문단을 기본으로 하고 상투적 표현을 피하게 합니다.
- 위임을 덜 하는 성향: 언제 위임하고 어떻게 맡기는지 적었습니다. Claude 쪽과 방향이 반대인 이유입니다.
- 과한 테스트: 필수 검사가 통과하면 끝내고, 구현을 그대로 옮긴 테스트는 쓰지 않습니다.

Claude 쪽에 적용한 원칙은 다음과 같습니다.

- 승인이 필요한 행동은 정확한 이름으로 나열하고, 이미 받은 승인이 유효하다는 예외를 같은 규칙 안에 씁니다. 승인이 필요 없는 단계(읽기, 로컬 수정, 빌드·테스트, 재시도)도 이름으로 적습니다.
- 일반적인 장애(오류, 타임아웃, 도구 실패)는 진단하고 계속 진행하게 하고, 의도적으로 막아 둔 것(수정 금지 파일, 회수된 권한)은 건드리지 않고 보고하게 합니다.
- 위임을 권하는 문장을 두지 않습니다. 기본은 메인 대화에서 직접 작업합니다.
- 주의 문구는 범위와 이유가 있는 것만 남깁니다. 이유가 사라진 금지 규칙과 여러 파일에 반복된 경고는 지웁니다.
- 글쓰기 규칙은 글자 수 같은 강한 제한 대신 독자 기준(도구 호출을 보지 않은 사람이 읽는다)으로 씁니다.
- 생각 과정을 답변에 적으라는 지시, 덜 생각하라는 지시, 토큰 예산 문구는 쓰지 않습니다. 사고량은 effort 설정으로 조절합니다.
- 개인 계정용 지침이므로 코드 소유권 문장을 넣었습니다. 작업 영역의 중복을 합치고 관련 문제를 함께 고치는 대신, 요청 밖의 변경은 작은 것까지 보고하고 기존 기능의 동작 변경은 승인을 받습니다. 가이드에 따르면 이 문장은 출력 토큰을 약 1.5배로 늘리고 요청하지 않은 변경을 만들 수 있으므로 요약만 보지 말고 diff를 확인합니다. 남의 저장소(포크, vendored 사본, upstream)에서는 가장 작은 변경이 기본입니다.

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

현재 또는 새 PC에 저장소 내용을 적용합니다. 제거한 Skill의 전역 설치본을 지울 때도 같은 명령을 사용합니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install
pwsh -File ./scripts/sync.ps1 -Mode Install -Apply
```

`Install -Apply`는 덮어쓸 기존 파일과 Skill 폴더를 먼저 `~/.agents-dotfiles-backups/<run-id>/`에 백업합니다. 제거 대상 Skill 폴더는 같은 백업 디렉터리로 이동하므로 로컬 수정분과 하위 파일도 보존됩니다. 별도 설치한 Skill은 건드리지 않습니다. Skill 자체가 심볼릭 링크·정션이면 연결 항목만 이동하며 연결 대상은 따라가지 않습니다. 설치 루트나 그 상위 경로가 연결이면 제거를 거부합니다.

Skill을 제거하려면 이름을 `Skills`에서 빼고 `RemovedSkills`로 옮긴 뒤 `skills/`의 원본을 삭제합니다. 단순히 원본 폴더가 없다는 이유로 설치본을 삭제하지는 않으며, 설치 대상 원본이 없으면 오류로 처리합니다. `Export`는 활성 `Skills`만 내보냅니다. 활성 Skill 내부에서 지운 파일은 설치본에서 자동으로 정리되지 않습니다.

Skill을 추가하거나 고친 뒤에는 정적 검사를 돌립니다.

```powershell
pwsh -File ./scripts/lint-skills.ps1
```

동기화 스크립트를 변경한 뒤에는 실제 사용자 홈 대신 `work/` 아래 임시 홈을 사용하는 검증을 실행합니다. 검증 자료는 확인을 위해 해당 폴더에 남습니다.

```powershell
pwsh -File ./scripts/test-sync.ps1
```

테스트용 홈 경로를 지정할 수도 있습니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install -HomePath ./work/test-home -Apply
```

## 평가 시드

`evals/`는 실제 모델 실행용 입력과 기대 행동을 기록한 수동 평가 자료입니다. 정적 검사 통과는 모델의 행동 검증을 뜻하지 않습니다. 지침 변경 전후를 비교할 때는 같은 모델·effort·테스트 자료를 사용한 별도 세션에서 실행하고, 한 번에 한 가지 변경만 비교합니다.
