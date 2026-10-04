# agents-dotfiles

컴퓨터를 바꿀 때 다시 설치할 수 있도록 개인 에이전트 지침과 관리 대상 Skill을 보관하는 저장소입니다.

## 저장 범위

- `config/codex/AGENTS.md`: Codex 전역 지침 (작업 완수·권한·검증에 관한 짧은 기본 계약)
- `config/claude/CLAUDE.md`: Claude Code 전역 지침 (말투, 권한 경계, 코딩 기본 규칙; 작업별 절차는 Skill이 담당)
- `skills/`: 개인·외부 Skill 원본 (`engineering-review`, `test-audit`, `explain-with-artifacts`, `commit-context`, `delegate-research`, `codebase-design`은 설치 대상, 기존 6개는 보관만 함)
- `scripts/sync.ps1`: 현재 PC 내보내기, 새 PC 설치, 드리프트 확인
- `scripts/lint-skills.ps1`: Skill frontmatter, 크기, 참조 링크, `manifest.psd1` 일치 여부 정적 검사
- `scripts/test-sync.ps1`: 임시 홈에서 설치·제거·백업·경로 보호 동작 검증
- `evals/routing-cases.json`: 설명이 인접한 Skill 쌍의 트리거 시드
- `evals/instruction-cases.json`: 승인·작업 범위·검증 종료·모델 보존·스킬 행동을 확인하는 수동 평가 시드

Skill은 저장소에서 한 번만 관리합니다. `manifest.psd1`의 `Skills`는 설치 대상, `RemovedSkills`는 이전 관리 대상 중 제거할 이름입니다. `Install`은 `.agents/skills`와 `.claude/skills` 양쪽에 적용됩니다. 현재 `engineering-review`, `test-audit`, `explain-with-artifacts`, `commit-context`, `delegate-research`, `codebase-design`이 설치 대상이며 기존 6개는 `RemovedSkills`에 등록되어 있습니다.

`engineering-review`는 설계·모듈 경계·리팩터링·구조 단순화 검토에, `test-audit`은 테스트 작성·수정·가치 검토에, `explain-with-artifacts`는 근거가 있는 시각적·인터랙티브 설명에, `commit-context`는 중요한 변경의 결정 근거 기록과 관련 이력 조회에, `delegate-research`는 독립적으로 나눌 수 있는 조사 위임과 근거 통합에 사용합니다. 공용 스킬에는 특정 프로젝트의 전제나 문서 경로를 넣지 않고, 작업 중인 저장소의 지침과 계약을 따릅니다.

## 코드베이스 설계 스킬

`codebase-design`은 [Matt Pocock의 원본 스킬](https://github.com/mattpocock/skills/tree/d81f3a183412e71a5b1e84ca21bc1a35eea03a60/skills/engineering/codebase-design)을 가져온 외부 스킬입니다. 작은 인터페이스 뒤에 동작을 모으는 깊은 모듈, 호출자가 알아야 할 규칙, 변경 지점과 테스트 범위를 검토할 때 사용합니다. `engineering-review`의 근거 중심 구조 검토에 설계 용어와 판단 기준을 더합니다.

원본 `SKILL.md`, `DEEPENING.md`, `DESIGN-IT-TWICE.md`, `agents/openai.yaml`을 수정 없이 보관합니다. 출처와 고정 커밋은 [UPSTREAM.md](skills/codebase-design/UPSTREAM.md), 원본 라이선스는 [LICENSE](skills/codebase-design/LICENSE)에 있습니다. `manifest.psd1`에 등록되어 다음 `Install -Apply`에서 Codex와 Claude 양쪽으로 동기화됩니다.

## 시각적 설명 스킬

`explain-with-artifacts`는 흐름도, 단계별 설명, 변경 전후 비교, 입력에 따른 결과 탐색을 요청할 때 사용합니다. 간단한 설명은 글이나 표로 끝내며, 긴 답변·큰 변경·표 크기만으로 HTML을 만들지 않습니다. 기존 리뷰나 테스트를 다시 수행하는 스킬도 아닙니다.

예시 요청:

```text
$explain-with-artifacts
이 요청이 UI에서 처리기로 전달되는 흐름을 실제 코드에 근거해 보여줘.
글이나 도식으로 충분하면 파일은 만들지 마.
```

```text
$explain-with-artifacts
이 변경의 전후를 같은 입력으로 비교하는 작은 HTML을 만들어줘.
중요한 설명에 관련 코드와 기준 커밋을 연결하고,
실제 확인한 동작과 설명용 모형을 구분해줘. 앱 본체는 수정하지 마.
```

HTML이 필요할 때는 [가벼운 예제 템플릿](skills/explain-with-artifacts/assets/explainer.html)을 출발점으로 사용합니다. 외부 라이브러리나 서버 없이 브라우저에서 직접 열 수 있고, 단계 이동·초기화·근거 펼치기를 포함합니다. JavaScript 없이도 설명 본문은 읽을 수 있습니다. 템플릿 자체는 실제 프로젝트에 연결되지 않은 가상의 예시입니다.

설명 결과물은 요청한 위치나 임시 산출물 공간에 두며 기본적으로 앱이나 Git에 추가하지 않습니다. 실제 코드·실행 근거, 추정, 모형을 구분하고 브라우저 검증을 하지 못한 경우에는 그 한계를 알립니다. 영상·음성 생성, 별도 MCP 서버, 전용 렌더러는 포함하지 않습니다.

## 커밋 맥락 스킬

`commit-context`는 diff만으로 알기 어려운 선택의 이유와 제약을 커밋 본문에 남기거나, 현재 코드와 지침으로 설명되지 않는 중요한 선택을 관련 Git 이력에서 찾습니다. 전역 지침에는 짧은 원칙만 두고, 선별·작성·조회 절차는 스킬이 담당합니다. 단순 수정은 한 줄로 끝낼 수 있고, 정해진 분량이나 필수 항목은 없습니다.

예시 요청:

```text
$commit-context
이번 변경의 확인된 이유와 중요한 호환성 영향을 커밋 메시지로 정리해줘.
단순 변경이면 짧게 끝내고, 커밋이나 푸시는 하지 마.
```

```text
$commit-context
이 분기를 일부러 유지한 이유가 현재 코드와 지침만으로는 불분명해.
관련 이력만 찾아 근거 커밋과 함께 설명하고, 지금도 전제가 맞는지 확인해줘.
코드는 수정하지 마.
```

실제로 확인하지 않은 이유·기각 대안·검증 결과는 만들지 않습니다. 메시지는 실제 커밋에 포함될 변경만 설명하고, 과거 이력은 현재 지침이나 새 승인으로 취급하지 않습니다. 스쿼시를 사용하는 승인된 작업에서는 중요한 근거가 최종 메시지에도 남도록 합니다. 현재 계약은 기존 코드·문서에 유지하며, 별도 의사결정 문서 체계나 Git hook, 스크립트는 추가하지 않습니다.

## 조사 위임 스킬

`delegate-research`는 읽을 자료가 많고 범위를 명확히 나눌 수 있을 때, 적절한 모델의 서브 에이전트에게 조사를 맡기고 근거를 통합합니다. 단순 조회는 직접 처리하며, 위임·검증·재작업을 포함한 전체 비용을 고려합니다. 모델명·가격·에이전트 수를 고정하지 않고 현재 런타임과 사용자의 명시적 선택을 따릅니다.

예시 요청:

```text
$delegate-research
이 SDK 버전의 재시도 조건과 제한을 공식 문서와 구현에서 조사해줘.
독립적으로 나눌 가치가 있는 부분만 적절한 경량 에이전트에게 맡기고,
근거 위치·확인한 범위·미확인 사항을 받아 핵심 결론을 확인해줘.
코드는 수정하지 마.
```

메인은 조사 방향과 중요한 판단을 맡습니다. 검색 결과가 없다는 사실을 부재나 안전성의 증명으로 취급하지 않으며, 실제 측정 없이 비용·할당량 절감률을 주장하지 않습니다. 조사량이나 관련 파일 수만으로 위임하지 않고, 결과를 확인하는 비용이 전체 재조사보다 작은 경우에 사용합니다.

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

`evals/`는 실제 모델 실행용 입력과 기대 행동을 기록한 수동 평가 자료입니다. 스킬 평가 시드에는 활성 스킬과 보관된 스킬의 사례가 함께 있습니다. 각 사례에서 필요한 스킬을 별도 평가 환경에 설치한 뒤 확인합니다. 정적 검사 통과는 모델의 행동 검증을 뜻하지 않습니다. 지침 변경 전후를 비교할 때는 같은 모델·설정·테스트 자료를 사용한 별도 세션에서 실행합니다.

테스트용 홈 경로를 지정할 수도 있습니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install -HomePath ./work/test-home -Apply
```
