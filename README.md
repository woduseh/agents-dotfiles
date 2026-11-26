# agents-dotfiles

컴퓨터를 바꿀 때 다시 설치할 수 있도록 개인 에이전트 지침과 관리 대상 Skill을 보관하는 저장소입니다.

## 저장 범위

- `config/claude/CLAUDE.md`: Claude Code 전역 지침 (말투, 글쓰기, 승인 경계, 코딩 기본 규칙)
- `config/claude/agents/advisor.md`: Claude Code 서브에이전트. Fable이 아닌 메인 모델 세션에서 사용자가 요청할 때와 정해진 세 시점(되돌리기 비싼 결정 전, 진단 두 번 실패 후, 지침·Skill 변경 마무리 전)에 쓰며, Fable·effort high로 고정하고 파일을 수정하지 못합니다
- `config/codex/AGENTS.md`: Codex 전역 지침 (작업 완수·권한·검증에 관한 짧은 기본 계약)
- `config/antigravity/GEMINI.md`: Antigravity(Gemini 4 Neon) 전역 지침 (상시 안전·호칭·판단 큐 위주로 경량화하고 작업별 규칙은 Skill로 위임)
- `skills/`: 설치 대상 Skill 원본
- `manifest.psd1`: 동기화할 파일, 설치할 Skill(`Skills`), 제거할 Skill(`RemovedSkills`), 제거할 홈 경로(`RemovedPaths`), PC마다 있어야 하는 Claude 권한 규칙(`ClaudePermissionRules`)
- `scripts/sync.ps1`: 현재 PC 내보내기, 새 PC 설치, 드리프트 확인. 확인에는 권한 규칙과 Git 훅 연결 여부도 포함됩니다
- `scripts/lint-skills.ps1`: Skill frontmatter, 크기, 참조 링크, `manifest.psd1` 일치 여부, 라우팅 시드가 가리키는 Skill 이름 정적 검사
- `scripts/lint-skills.sh`: 같은 정적 검사의 macOS·Linux용(bash)
- `scripts/test-lint-skills.ps1`: 일부러 망가뜨린 Skill 묶음에 두 린트가 같은 결과를 내는지 검증
- `hooks/pre-commit`: 커밋할 내용으로 정적 검사를 돌리고 실패하면 커밋을 막는 Git 훅
- `scripts/test-sync.ps1`: 임시 홈에서 설치·제거·백업·경로 보호 동작 검증
- `scripts/agent-doctor.ps1`: 에이전트가 쓰는 도구(git, gh, fnm, uv, jq, node 등)의 경로와 버전, 프로젝트가 고정한 Node 버전의 준비 상태를 보고. 아무것도 설치하지 않습니다
- `scripts/repo-run.ps1`: 프로젝트의 `.node-version`이나 `.nvmrc`가 고정한 Node 버전으로 명령을 실행
- `scripts/agent-tools-common.ps1`: 위 두 스크립트가 함께 쓰는 함수
- `scripts/test-agent-tools.ps1`: 위 두 스크립트의 동작 검증
- `evals/routing-cases.json`: Skill 선택(트리거) 확인용 수동 시드
- `evals/instruction-cases.json`: 승인·작업 범위·중단 조건·보고 형식을 확인하는 수동 시드

## Skill

Skill은 저장소에서 한 번만 관리하고 `Install`이 `.agents/skills`, `.claude/skills`, `.gemini/config/skills`에 적용합니다.

| Skill | 사용할 때 |
| --- | --- |
| `pre-compact` | 세션을 압축하거나 끝내기 전에 남은 일 점검, 압축 초점 문장 또는 단계 핸드오프 정리 |
| `writing-for-readers` | 릴리스 노트·PR·이슈 본문·제안서를 보이는 결정 층과 접는 근거 층의 2계층으로 작성 |

Skill에는 모델이 스스로 알 수 없는 판단 기준과 개인 선호만 둡니다. 일반적인 절차, 승인 규칙, 교과서적 지식은 넣지 않습니다. 승인과 범위는 전역 지침이 담당하므로 Skill마다 반복하지 않습니다. 공용 Skill에는 특정 프로젝트의 전제나 문서 경로를 넣지 않습니다.

### 제거한 Skill

다음 Skill은 삭제했고 원본은 Git 이력에만 있습니다. 오래 동기화하지 않은 PC에서도 설치본이 제거되도록 `RemovedSkills` 항목은 유지합니다.

| Skill | 제거 이유 |
| --- | --- |
| `engineering-review` | 9월 말 설치 이후 실전 호출 0회. 대부분 프런티어 모델이 이미 내재화한 설계 교과서였고, 고유 기준(검사 실패 메시지에 대안 포함, 리뷰 점수표·억지 채우기 금지 및 결함·리스크·가설 구분)은 전역 지침으로 옮겼습니다. |
| `explain-with-artifacts` | 10월 초 설치 이후 실전 호출 0회. Claude·Antigravity 모두 시각화·아티팩트용 내장 도구를 별도로 제공합니다. |
| `project-docs` | 전역 지침의 문서 원칙 한 문장과 사실상 동일해 별도 Skill로 둘 실익이 없었습니다. "문서가 의도를 적었는데 코드가 못 미치면 결함으로 보고" 기준만 전역 지침에 흡수했습니다. |
| `test-audit` | 절반 이상이 교과서·전역 중복이었고, 정작 중요한 테스트 무결성(구현 복붙 oracle 금지, 테스트 삭제·완화 시 대체 보호 경로 명시, 조합 문제 불변식 검증)은 Skill이 불리지 않는 세션에서도 상시 작동해야 하므로 전역 지침으로 승격했습니다. 과거 MIT 원본 고지는 Git 이력의 `skills/test-audit/LICENSE.txt`에 남아 있습니다. |
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

지침과 Skill은 대상 모델의 공식 프롬프팅 가이드에 맞춰 점검합니다. `CLAUDE.md`, `advisor.md`, `AGENTS.md`, Skill은 2026-11-19에 아래 가이드 중 Claude 두 편과 OpenAI의 GPT-6.2 가이드를 기준으로 마지막으로 점검했습니다(아래 "2026-11-19 점검").

- [Prompting Claude Fable 5.2](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2)
- [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
- [Using GPT-6.2: Prompting best practices](https://developers.openai.com/api/docs/guides/latest-model#prompting-best-practices) (GPT-6.2 Astra와 Sol 공통)
- [Prompting GPT-6.2 in Codex](https://learn.chatgpt.com/guides/prompting-gpt-6-2-astra)

`AGENTS.md`에는 GPT-6.2 가이드가 짚은 성향과 권고를 반영했습니다.

- 간결해진 문체: GPT-6.2 Astra는 기본 문체가 이미 간결하므로 "간결하게"라는 지시를 뺐습니다. 대신 설명이 정확해지는 기술 세부와 도메인 용어는 남기고, 사용자와 출처가 쓰는 용어를 따르게 합니다.
- 작업 중 약어가 최종 답변에 섞이는 성향: 최종 답변은 진행 메시지를 읽지 않은 사람이 처음 보는 글로 새로 쓰고, 추론·도구 호출·다른 에이전트와 주고받은 약어와 라벨을 빼게 합니다. 사용자가 쓴 글을 고칠 때는 요청한 부분만 바꿉니다.
- 다음 단계를 제안하고 멈추는 성향: 요청형 표현을 실행 지시로 보고, 가정을 밝힌 채 계속 진행하며, 턴을 끝내기 전에 요청의 모든 부분이 끝났고 검증됐는지 확인합니다. 승인은 검토 가능한 결과를 준비한 뒤 마지막 단계로 받습니다. 가이드는 draft PR 생성까지 자율로 두지만 여기서는 커밋·푸시·PR에 승인을 기본으로 유지하고, 프로젝트가 병합 게이트를 선언한 경우만 예외로 둡니다(아래 "2026-11-18에 바꾼 정책").
- 코드 작성: 기존 클래스·메서드·API를 재사용하고, 호출자가 기대는 동작을 보존하며, 줄 수를 줄이려고 압축한 코드와 불필요한 헬퍼·추상화를 피합니다. 테스트는 요청받았거나, 저장소가 요구하거나, 기존 테스트가 놓칠 특정 회귀를 잡을 때만 더합니다.
- 프런트엔드와 시각 작업: 결과를 렌더링해 실제로 보이는 크기에서 확인하고, 지원해야 하는 동작을 직접 해 봅니다. 화면 문구는 필요한 것만 둡니다. 가이드가 권한 이미지 종류와 서체 지정은 프로젝트마다 다르므로 전역 지침에 넣지 않았습니다.
- 서브에이전트: Codex 가이드(Prompting GPT-6.2 in Codex)는 반복되는 작업이면 언제 위임할지를 `AGENTS.md`에 적으라고 합니다. API 가이드에는 위임 지침이 없습니다. 언제 위임하고 어떻게 맡기는지 적은 문장이 여기에 해당합니다. 2026-11-19부터는 Astra 사용량을 아끼려고 기본을 직접 작업으로 두고 위임 조건을 좁혔습니다.
- 함께 쓰는 컴퓨터: 사용자가 같은 PC에서 계속 일하고 다른 에이전트도 함께 돌 수 있으므로, 커넥터·CLI·API로 할 수 있는 일은 앞에 떠 있는 앱을 조작하지 않고 처리합니다. 동시에 돌리는 빌드와 테스트 수를 조절하고, 끝낼 때 자신이 시작한 백그라운드 작업과 임시 파일을 정리합니다.

GPT-6 Astra 가이드를 기준으로 넣었던 두 가지는 GPT-6.2 가이드에 언급이 없지만 그대로 둡니다. 사용자 지시가 Skill보다 우선하고 Skill 때문에 멈추면 해당 `SKILL.md`와 문장을 밝히게 하는 규칙, 그리고 문단을 기본으로 하고 상투적 표현을 피하게 하는 규칙입니다. reasoning effort 선택은 `AGENTS.md`가 아니라 요청할 때 정하는 설정이므로 지침에 넣지 않았습니다.

Claude 쪽에 적용한 원칙은 다음과 같습니다.

- 승인이 필요한 행동은 정확한 이름으로 나열하고, 이미 받은 승인이 유효하다는 예외를 같은 규칙 안에 씁니다. 승인이 필요 없는 단계(읽기, 로컬 수정, 빌드·테스트, 재시도)도 이름으로 적습니다.
- 일반적인 장애(오류, 타임아웃, 도구 실패)는 진단하고 계속 진행하게 하고, 의도적으로 막아 둔 것(수정 금지 파일, 회수된 권한)은 건드리지 않고 보고하게 합니다.
- 일반 위임을 권하는 문장을 두지 않습니다. 기본은 메인 대화에서 직접 작업합니다. 예외는 이름으로 한정한 시점의 조언자 한 번입니다.
- 주의 문구는 범위와 이유가 있는 것만 남깁니다. 이유가 사라진 금지 규칙과 여러 파일에 반복된 경고는 지웁니다.
- 글쓰기 규칙은 글자 수 같은 강한 제한 대신 독자 기준(도구 호출을 보지 않은 사람이 읽는다)으로 씁니다.
- 생각 과정을 답변에 적으라는 지시, 덜 생각하라는 지시, 토큰 예산 문구는 쓰지 않습니다. 사고량은 effort 설정으로 조절합니다.
- 개인 계정용 지침이므로 코드 소유권 문장을 넣었습니다. 작업 영역의 중복을 합치고 관련 문제를 함께 고치는 대신, 요청 밖의 변경은 작은 것까지 보고하고 기존 기능의 동작 변경은 승인을 받습니다. 가이드에 따르면 이 문장은 출력 토큰을 약 1.5배로 늘리고 요청하지 않은 변경을 만들 수 있으므로 요약만 보지 말고 diff를 확인합니다. 남의 저장소(포크, vendored 사본, upstream)에서는 가장 작은 변경이 기본입니다.

2026-11-10에 다른 환경에서 쓰던 지침에서 다음을 가져왔습니다.

- 도구로 보이는 글(질문 카드, 다음 단계 요약, 버튼, 계획 항목)도 한국어로 쓰고, 읽어야 할 초안은 메시지 본문에 싣습니다. 영어로 쓰인 압축 요약 뒤에 답변이 영어로 바뀌거나 본문 없이 요약 상자만 나오는 일이 반복됐습니다. Claude 앱의 동작이라 `CLAUDE.md`에만 둡니다.
- 작업을 알리거나 무언가를 요청하는 글(릴리즈 노트, PR·이슈 본문, 제안서)은 두 층으로 씁니다. 보이는 층은 결정하는 사람용, 접는 층은 근거용입니다. 프로젝트에 정해진 형식이 있으면 그 형식을 유지하고, 커밋 범위나 PR이 근거를 이미 담고 있으면 링크로 대신합니다. 가이드, 참조 문서, 아티클, 소설에는 적용하지 않습니다.
- 이름 짓기 선호는 프로젝트와 프레임워크에 정해진 규칙이 없을 때만 적용합니다. `handleClick` 같은 프레임워크 관용은 그대로 둡니다.
- `pre-compact`는 압축 전에 남은 일을 묻는 습관을 Skill로 옮긴 것입니다. 아이콘은 아직 없습니다.
- `advisor`는 처음에 사용자가 부를 때만 쓰게 했고, 2026-11-19에 호출 시점을 넓혔습니다(아래 "2026-11-19 점검"). `Export`는 설치본이 없으면 실패하므로 새 PC에서는 `Install`을 먼저 실행합니다.

### 2026-11-18에 바꾼 정책

Lauren Tan의 발표 「All Code Is Slop (Except Mine)」의 주장을 받아들였습니다. 에이전트에게 좋은 코드를 쓰라고 글로 가르치는 것보다 나쁜 코드를 쓰기 어렵게 만드는 편이 낫고, 수단의 우선순위는 설계와 API, 결정론적 검사, 실행 검증, 글로 쓴 지침 순이라는 내용입니다. 발표 영상은 직접 확인하지 않았고, 다른 에이전트가 정리한 요약과 같은 발표자가 만든 pstack 플러그인의 스킬 본문을 근거로 삼았습니다. 아래 문장은 `CLAUDE.md`와 `AGENTS.md`에 같은 내용으로 넣었고, 각각 `evals/instruction-cases.json`에 시드가 있습니다. 시드는 아직 실행하지 않았습니다.

- 같은 실수는 검사로 막습니다. 같은 실수나 같은 리뷰 지적이 두 번째로 나오면 잘못된 선택을 없애는 API·타입 변경을 먼저, 그다음 실패 메시지가 대안을 알려 주는 린트 규칙·아키텍처 테스트·훅을 씁니다. 지침·메모리·주석에 문장을 더하는 것은 판단이 필요한 경우만입니다. `engineering-review`의 처방 순서와 `pre-compact`의 점검 항목에도 같은 기준을 넣었습니다.
- 기존 임시방편은 따라 할 패턴이 아닙니다. 옆 코드에 있다는 이유로 sleep, 타이머, 재시도, 억제 지시문, 포괄 catch를 새 코드에 복사하지 않습니다.
- 내 코드에서는 주석을 기본적으로 쓰지 않습니다. 남기는 것은 세 가지입니다. 프로젝트가 바꿀 수 없는 것(외부 시스템, 명세, 플랫폼 버그)에서 오는 제약과 그 출처, 도구가 게시하거나 사용자가 읽는 문서(공개 API의 Javadoc), 도구나 라이선스가 요구하는 문구입니다. 주석은 강제력이 없고 구현과 어긋나며, 임시방편을 정당화하는 주석은 다음 에이전트가 같은 임시방편을 복사하는 근거가 되기 때문입니다. 바꾼 이유는 커밋 본문에 둡니다. 남의 저장소는 그 저장소의 관례를 따릅니다. 수정하는 코드의 서술·변명 주석을 지우게 했으므로 한동안 diff에 주석 삭제가 섞일 수 있습니다.
- 프로젝트가 선언하면 병합을 검사에 맡깁니다. 프로젝트 지침이 자동 병합을 선언했고 대상 브랜치에 저장소가 강제하는 필수 검사가 있을 때만, 커밋·푸시·PR·병합을 묻지 않고 진행하고 병합 결정은 필수 검사에 넘깁니다(예: GitHub auto-merge). 둘 중 하나라도 없으면 기존 승인 규칙 그대로입니다. 배포·릴리즈·파괴적 작업·운영 의존성·마이그레이션, 게이트 자체의 변경(CI 설정, 린트 규칙, 브랜치 보호, 지침 파일), 인증·비밀값·권한 변경은 게이트가 있어도 승인을 받습니다. 발표가 말하는 자율은 검사 체계가 갖춰진 코드베이스에서만 성립하므로 전역으로 풀지 않고 프로젝트별 선언으로 두었습니다. 이 저장소는 필수 검사가 없어서 선언하지 않았습니다.
- 조합이 많은 문제는 불변식으로 검증합니다. 동시 갱신, 서비스 간 재시도와 순서 뒤바뀜, 기기 간 동기화처럼 예시로 다 덮을 수 없는 경우에는 속성 기반 테스트나 모델(jqwik, TLA+ 명세 등)을 평소의 선택지로 씁니다. 도구가 없는 프로젝트에서는 검사할 불변식과 함께 먼저 제안합니다. `test-audit`의 수준 선택에도 넣었습니다.

같은 원칙을 이 저장소에도 적용했습니다. README가 글로만 요구하던 PC별 작업(Git 훅 연결, 권한 규칙)을 `sync.ps1 -Mode Check`가 점검하고, 주석으로만 유지하던 두 린트의 동등성을 `test-lint-skills.ps1`이 검증하며, 저장소에서 지운 뒤에도 홈에 남던 `.claude/guides`를 `RemovedPaths`로 제거합니다.

### 2026-11-19 점검

모델별 사용량 여유가 Opus 5.5 > Fable 5.2 > GPT-6.2 Astra 순이라는 전제로, 메인 작업은 Opus, 판단이 필요한 지점의 두 번째 의견은 Fable, Codex(Astra)는 위임을 줄여 아끼는 방향으로 맞췄습니다. Fable 조언자가 사용량 한도로 중단돼 Opus 독립 에이전트에게 검토를 받았고, 지적 여섯 가지(서브에이전트 안 호출, 넓은 호출 시점, 브리핑과 advisor 본문의 어긋남, 종료 사유 누락, 진행 알림의 적용 범위, README의 가이드 출처)를 반영했습니다. 새 문장마다 `evals/instruction-cases.json`에 시드를 더했고, 시드는 아직 실행하지 않았습니다.

- 진행 알림(`CLAUDE.md`): 두 Claude 가이드 모두 긴 도구 작업 중 사용자에게 보이는 글이 적어지는 성향을 짚고, 첫 도구 호출 전 한 줄과 몇 번의 호출마다 한 줄 업데이트를 권합니다. 가이드는 사람이 보고 있을 때만 쓰라고 하므로 그 조건을 적고, 서브에이전트는 건너뛰게 했습니다. 예고만 하고 턴을 끝내지 않도록 첫 도구 호출과 같은 메시지에 쓰게 했습니다. Fable 가이드 기준으로 출력 토큰이 약 20% 늘 수 있습니다. 마무리 요약은 기존 "최종 메시지는 결과부터" 문장이 담당합니다.
- 조기 종료 유형(`CLAUDE.md`): Opus 5.5는 피해야 할 멈춤을 이름으로 적으면 잘 따르고, Fable 5.2는 "남은 일을 나열하고 멈추는" 종료가 일반 지시만으로는 잘 줄지 않습니다. 다음 단계 예고 요약, 계속할지 묻는 제안, 남은 일 목록, 막지 않는 결정 목록을 이름으로 적고, 멈춰도 되는 경우(승인 대기를 포함해 사용자 없이는 진행 불가, 의도적 차단, 진척이 멈춤, 완료)를 함께 적었습니다. 가이드의 무인 실행용 문단 전체는 사람이 있는 대화에 맞지 않아 쓰지 않았습니다.
- 조언자 호출 시점(`CLAUDE.md`, `advisor.md`): 사용자가 요청할 때만 쓰던 조언자를 Fable이 아닌 메인 모델 세션의 메인 대화에서 세 시점에 최대 한 번씩 쓰게 했습니다. 되돌리는 데 데이터 마이그레이션·공개 계약 변경·여러 모듈 재작성이 드는 설계·계획을 정하기 전, 진단이 두 번 실패한 뒤, 문구 수정을 넘는 지침·Skill 변경을 끝내기 전입니다. 서브에이전트 안에서는 부르지 않습니다. 서브에이전트에도 전역 지침과 `advisor`가 그대로 보여서 같은 결정에 두 번 부를 수 있기 때문입니다. Fable 가이드가 위임 설명에 비용을 적으면 서브에이전트 수가 절반쯤 줄었다고 해서 description과 지침에 Fable·high effort의 사용량 비용을 적었습니다. 선호안을 빼고 브리핑하므로 `advisor.md` 본문의 "호출자 방향과의 일치·불일치"는 브리핑에 방향이 있을 때만 답하게 했습니다. 이 점검 중 조언자가 Fable 사용량 한도로 중단된 일이 있어, 쓸 수 없으면 그렇다고 말하고 계속하는 문장도 넣었습니다.
- Codex 위임(`AGENTS.md`): Codex 가이드는 필요할 때 서브에이전트를 쓰고 위임 시점을 적으라고 하지만, Astra 사용량이 가장 빠듯하고 서브에이전트도 같은 한도를 씁니다. 기본을 직접 작업으로 바꾸고, 큰 작업이 병렬로 잘 나뉠 때만 필요한 수만큼 위임하게 했습니다. "위험한 변경에 두 번째 시선"은 위임 사유에서 뺐습니다.
- 프런트엔드 문구(`AGENTS.md`): GPT-6.2 가이드가 짚은 장식용 번호, 채우기용 배지, 화면에 이미 있는 내용을 반복하는 문구를 빼는 예를 더했습니다.

점검했지만 바꾸지 않은 항목입니다.

- Skill 4개: 위임 지시, 생각 과정을 답변에 쓰라는 지시, 덜 생각하라는 지시, 범위 없는 "never"가 없고 가이드와 어긋나는 문장을 찾지 못했습니다.
- 넣지 않은 가이드 권고: 이전 답을 끝난 것으로 보라는 문장(스스로 실수를 짚는 일이 줄어듦), 덜 생각하라는 문장(Fable 5.2에는 효과 없음, effort로 조절), 여러 앱을 먼저 둘러보라는 문장(커넥터 자동화가 주 용도가 아님), 붙여 넣은 글 표시(앱이 이미 처리), 시간 예산(하네스 기능). effort, `display`, `max_tokens`는 지침 파일로 정할 수 없는 설정입니다.
- 프런트엔드 기본 스타일 회피: Opus 5.5 가이드는 피할 스타일을 이름으로 적으라고 하지만, 재연님이 피하고 싶은 스타일 목록이 정해지지 않아 넣지 않았습니다.

### 2026-11-21에 더한 문서 원칙

Uimori에서 도우미 도구 문서 두 개(`HELPER-TOOLS.md`, `TOOL-CONTRACTS.md`)를 코드와 문장 단위로 대조한 결과를 원칙으로 옮겼습니다. 두 문서는 링크와 코드 경로가 모두 유효했지만, 도구 설명·스키마·테스트를 되풀이한 문장 가운데 열 군데 넘게 코드와 어긋나 있었습니다. 코드를 되풀이하는 문서는 그 글을 읽는 코드가 없어서 손으로 맞춰야 하고, 어긋나도 검사에 걸리지 않기 때문입니다. 되풀이한 내용을 지우자 두 문서는 합쳐 140KB에서 76KB가 됐고, 코드에 없는 이유·소유 경계·의도적으로 하지 않는 일은 그대로 남았습니다.

아래 내용을 한 문단으로 `CLAUDE.md`와 `AGENTS.md`의 주석 규칙 바로 뒤에 같은 문장으로 넣었고, `evals/instruction-cases.json`에 시드 두 개(`docs-hold-what-code-cannot`, `doc-dedup-finds-the-carrier`)를 더했습니다. 시드는 아직 실행하지 않았습니다.

- 문서는 코드가 독자에게 이미 말해 주는 것(타입, 스키마, 도구·API 설명, 테스트)을 되풀이하지 않습니다. 남기는 것은 코드가 말할 수 없는 것입니다. 당연하지 않은 규칙의 이유, 기능이 일부러 하지 않는 일, 두 번째 경로를 만들지 않도록 어느 경로가 동작을 소유하는지, 기능 사이의 경계, 그리고 코드를 읽지 않는 독자를 위한 안내서입니다. 계약은 베끼지 않고, 정의하는 파일과 강제하는 테스트의 이름을 적습니다.
- 중복이라고 지우기 전에 그 내용을 실제로 담고 있는 곳을 찾고, 어디에도 없으면 남깁니다. 이 조건이 없으면 "코드에 있을 것"이라는 추정으로 문서에만 있던 내용까지 지우게 됩니다.
- 문서가 코드와 어긋나면 현재 동작에 대해서는 문서가 틀린 것입니다. 문서를 코드에 맞추고, 문서가 의도를 적은 것이라면 결함으로 보고합니다.
- 주석 규칙과 같은 구분입니다. 주석 규칙의 "제약은 강제되는 곳에 둔다"를 문서로 넓혔고, 남의 저장소는 그 저장소의 문서 관례를 따릅니다.

프로젝트의 문서 구조에 맞춘 적용 규칙은 프로젝트 지침에 둡니다. Uimori는 같은 날 `AGENTS.md`에 넣었습니다. 이번에는 프롬프팅 가이드와 다시 대조하지 않고 문단 하나만 더했으므로, 위의 마지막 점검 날짜는 바꾸지 않았습니다.

### 2026-11-26 점검 (Gemini 4 Neon 경량화 및 공용 Skill 분리)

Philipp Schmid의 「5 Habits I changed when working with Gemini 4 Neon」을 바탕으로 Antigravity 전역 지침(`GEMINI.md`)을 Gemini 4 Neon 성향에 맞게 재정비하고, 작업별 규칙을 공용 Skill로 분리해 `CLAUDE.md`와 `AGENTS.md`의 중복도 함께 덜어냈습니다.

- `writing-for-readers` Skill 신설: 세 전역 지침(`GEMINI.md`, `CLAUDE.md`, `AGENTS.md`)에 중복돼 있던 2계층 PR·릴리스 노트·이슈·제안서 작성 규칙을 공용 Skill로 옮기고 `evals/routing-cases.json`에 트리거 시드를 추가했습니다.
- `GEMINI.md` 경량화(약 14.8KB → 5.1KB): `CLAUDE.md` 복제본에서 도구 설명·기본 시스템 프롬프트와 겹치는 규칙(`edit_file` 분할 편집, 서브에이전트 일반 기준)과 장문의 금지·예외 목록을 덜어내고, 한국어·호칭·승인 경계·출처 검증·시각 스크린샷 확인·단계 핸드오프 등 모든 세션에 적용되는 핵심 판단 큐만 남겼습니다.
- `CLAUDE.md`·`AGENTS.md`·기존 Skill 정합성: 두 지침의 모델별 튜닝(Claude Opus 5.5/Fable 5.2, GPT-6.2 Astra)과 2026-11-18/21 원칙은 유지하되, `writing-for-readers`와 `test-audit`에 있는 상세 문단 중복을 줄이고, 단계 전환 시 압축 대신 짧은 핸드오프를 우선하는 규칙(`pre-compact`에도 반영)과 렌더링 스크린샷 직접 확인(`CLAUDE.md`)을 맞췄습니다.

### 2026-11-26 추가 점검 (공식 가이드 대조 후 `CLAUDE.md`·`AGENTS.md` 정리)

같은 날 `GEMINI.md`에 적용한 방식을 `CLAUDE.md`와 `AGENTS.md`에도 쓸 수 있는지 공식 가이드와 대조했습니다. 읽은 문서는 Claude 프롬프팅 모범 사례 페이지, Fable 5.2 가이드, Opus 5.5 가이드, GPT-6.2 프롬프팅 모범 사례입니다. Claude 모범 사례 페이지의 뒷부분은 요약으로만 확인했고, Codex용 가이드(Prompting GPT-6.2 in Codex)는 이번에 다시 읽지 않았습니다. 그래서 위의 마지막 점검 날짜는 바꾸지 않았습니다.

- 문장을 짧은 큐로 압축하는 방식은 두 파일에 적용하지 않았습니다. Claude 가이드는 규칙마다 이유를 붙이라고 하고, Fable 5.2 가이드는 남은 일을 나열하고 멈추는 종료가 일반 지시만으로는 잘 줄지 않는다고 합니다. 두 가이드 모두 길이 목표는 제시하지 않고, 이전 모델용 지시를 지우라고만 합니다. GPT-6.2 가이드는 길이와 중복을 다루지 않습니다.
- `project-docs` Skill 신설: 2026-11-21 문서 원칙의 상세를 `CLAUDE.md`와 `AGENTS.md`에서 Skill로 옮겼습니다. 두 지침에는 원칙 한 문장과 Skill 이름을 남겼습니다. 코드 변경에 딸린 문서 수정처럼 Skill이 불리지 않는 경우에도 원칙이 적용되게 하기 위해서입니다. `evals/routing-cases.json`에 시드 세 개를 더하고, 사용자 가이드 작성 시드의 기대값을 `project-docs`로 바꿨습니다.
- 조언자 호출 규칙: `CLAUDE.md`의 문장을 줄이고, 호출 시점의 구체 기준과 브리핑 방법을 `advisor.md`의 설명으로 옮겼습니다. 설명은 호출하는 쪽이 읽는 인터페이스이므로 한 곳에만 둡니다.
- 반복되는 실수 규칙: 두 지침의 문장을 줄였습니다. 실패 메시지가 대안을 알려 줘야 한다는 기준은 `engineering-review`에 있습니다.
- `GEMINI.md`의 프로젝트 게이트 한계 복원: 경량화하면서 괄호 한 줄로 줄었던 예외에 한계를 다시 적었습니다. 실패하거나 빠진 검사를 넘어 병합하지 않고, 게이트 자체나 인증·시크릿·권한을 바꾸는 변경은 게이트 대상이 아닙니다. 승인 경계는 세 지침이 같은 뜻이어야 하고, 표현과 길이는 모델별 가이드를 따릅니다.

`scripts/lint-skills.sh`는 통과했습니다. `sync.ps1`과 PowerShell 린트는 `pwsh`가 없는 머신에서 작업해 실행하지 않았습니다. 시드는 실행하지 않았으므로 모델 동작은 확인하지 않은 상태입니다.

### 2026-11-27 개편 (위임·검증 관점 전면 재정비 및 Skill 4개 제거)

"인간 보스가 자기보다 유능한 AI 에이전트에게 위임해 성과를 얻는 구조" 관점으로 니아(Gemini 4 Neon)와 리아(Claude Fable 5.2)의 교차 검토를 종합해 전역 지침 3개(`GEMINI.md`, `CLAUDE.md`, `AGENTS.md`), `advisor.md`, Skill을 전면 다듬었습니다.

- **Skill 4개 제거:** `engineering-review`, `explain-with-artifacts`, `project-docs`, `test-audit`를 삭제하고 `manifest.psd1`의 `RemovedSkills`로 옮겼습니다. 활성 Skill은 모델이 추측할 수 없는 개인 출력 포맷(`writing-for-readers`)과 세션 연속성 체크리스트(`pre-compact`) 두 개만 남겼습니다.
- **경계와 기본값 분리:** 세 전역 지침 모두 `Authority and boundaries`(승인 목록·프로젝트 게이트·작업 범위·검증 정직성 — 절대 경계)와 `Engineering defaults`(설계·코딩 선호 — 결과가 분명히 더 나으면 이유를 보고하고 벗어날 수 있는 기본값)를 명시적으로 나눴습니다.
- **보스 검증 비용을 낮추는 장치 추가:** 비사소한 추천·설계 시 포기하는 것(핵심 약점)과 판단을 뒤집을 반증 증거를 함께 쓰게 하고, 자동 검사가 덮지 못하는 판단·UI·경계 지점이 있을 때 재연님이 직접 확인할 1~3곳을 지목하도록 했습니다. 사용자 노출 정책·UX 트레이드오프도 조용히 가정하지 않고 1안과 포기하는 가치로 거부권을 올리게 했습니다.
- **삭제 Skill의 핵심 상시화 및 How 축소:** 교과서적 코딩·네이밍 지시(`Read before changing`, `Edit files surgically`, `KISS > YAGNI > DRY`, `serNm`/`Info`/`Data` 예시 등)를 덜어내는 대신, 테스트 oracle 독립성과 삭제·완화 시 대체 보호 경로 명시, 검사 실패 메시지의 대안 제시, 문서 의도 미달 결함 보고, 리뷰 점수표·억지 채우기 금지와 결함·리스크·가설 구분을 세 전역 지침에 상시 규칙으로 흡수했습니다. `advisor.md`에는 가장 그럴싸한 실패 시나리오(pre-mortem) 항목을 더했습니다.
- **`evals/`:** 삭제된 Skill을 참조하던 `evals/routing-cases.json`은 린트에 맞게 정리했고, `evals/instruction-cases.json`은 이번 개편에서 건드리지 않았습니다.

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

### 새 PC에서 직접 넣는 권한 규칙

`.claude/settings.json`은 저장소가 관리하지 않으므로 권한 규칙은 PC마다 직접 넣습니다. 규칙 목록의 원본은 `manifest.psd1`의 `ClaudePermissionRules`이고, `sync.ps1 -Mode Check`가 빠진 규칙을 `[PERMISSION-MISSING]`으로 알려 줍니다. 파일을 고쳐 주지는 않습니다.

`deny`는 에이전트가 자격증명 파일을 읽어 대화 기록에 남기지 않도록 막습니다. 한번 기록에 남은 비밀값은 되돌릴 수 없어서 모델의 판단에 맡기지 않고 규칙으로 막습니다. `ask`는 병합 게이트가 있어도 승인이 필요한 행동 중 명령으로 알아볼 수 있는 것(강제 푸시, 관리자 권한 병합, 릴리즈, 패키지 게시)을 실행 전에 항상 묻게 합니다. 일반 `git push`와 PR 생성은 넣지 않았습니다. `ask` 규칙은 더 구체적인 `allow` 규칙보다 먼저 적용되어서, 넣으면 병합 게이트를 선언한 프로젝트에서도 매번 묻게 되기 때문입니다.

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/id_*)",
      "Read(~/.ssh/*.pem)",
      "Read(~/.codex/auth.json)",
      "Read(~/.claude/.credentials.json)"
    ],
    "ask": [
      "Bash(git push *--force*)",
      "Bash(git push -f*)",
      "Bash(git push * -f*)",
      "Bash(gh pr merge *--admin*)",
      "Bash(gh release create *)",
      "Bash(npm publish *)",
      "PowerShell(git push *--force*)",
      "PowerShell(git push -f*)",
      "PowerShell(git push * -f*)",
      "PowerShell(gh pr merge *--admin*)",
      "PowerShell(gh release create *)",
      "PowerShell(npm publish *)"
    ]
  }
}
```

- 이미 `permissions`가 있으면 `deny`와 `ask` 배열에 항목만 더합니다. 다른 설정은 그대로 둡니다.
- `ask` 규칙은 Claude가 보통 쓰는 형태의 명령을 잡을 뿐 보안 경계가 아닙니다. `git -C . push --force`처럼 다르게 쓴 명령은 잡지 못합니다. Maven이나 Gradle 게시처럼 다른 게시 명령을 쓰는 PC에서는 같은 형식으로 더합니다. 2026-11-18에 Windows의 Claude 데스크톱 앱 세션에서 네 명령에 승인 창이 뜨는 것을 확인했습니다. Bash와 PowerShell 각각의 `npm publish --dry-run`, PowerShell의 `git push --dry-run --force-with-lease origin main`, Bash의 `git push --dry-run -f origin main`입니다. Bash의 `npm publish` 창에는 한 번만 허용하는 선택지만 있었고, 규칙을 넣은 세션에서 다시 시작하지 않고도 적용됐습니다. `gh pr merge --admin`과 `gh release create` 규칙은 예행 실행 방법이 없어서 실행해 보지 않았습니다.
- deny 규칙은 allow 규칙과 auto 모드보다 먼저 적용됩니다. Read 도구와, 셸의 `cat`·`head`·`tail` 같은 파일 명령에 적용됩니다. 스크립트가 파일을 직접 여는 경우까지는 막지 못합니다.
- 비밀값이 실제로 어느 파일에 있는지는 PC마다 다릅니다. macOS는 Claude 로그인 정보를 키체인에 두므로 `.credentials.json`이 없을 수 있습니다. 토큰이 든 다른 파일이 있으면 같은 형식으로 더합니다. SSH 키 이름이 `id_`로 시작하지 않고 `.pem`으로 끝나는 PC가 있어서 `~/.ssh/*.pem`도 넣었습니다.
- 2026-11-17에 macOS의 Claude Code 2.1.308에서 `~/.ssh/id_*` 규칙이 Read 도구와 `cat`을 모두 막는 것을 확인했습니다.
- 2026-11-18에 Windows의 Claude 데스크톱 앱 세션에서 네 규칙을 확인했습니다. `~/.ssh/id_*`와 `~/.ssh/*.pem`은 실제 키 대신 없는 파일 이름으로 시험했습니다. Read 도구와 Bash의 `cat`이 두 규칙 모두에서, PowerShell의 `Get-Content`가 `id_*`에서 거부됐고, 같은 폴더의 규칙에 맞지 않는 이름은 거부되지 않고 "파일 없음" 오류를 냈습니다. 두 자격증명 파일은 내용을 출력하지 않는 `cat <파일> | wc -c`가 거부되는 것으로 확인했고, Codex 인증 파일은 PowerShell의 `Get-Content`도 거부됐습니다. 두 자격증명 파일에 Read 도구는 쓰지 않았습니다. 규칙이 작동하지 않으면 비밀값이 기록에 남기 때문입니다.
- 규칙에 맞는 경로를 인자로만 넘기는 `ssh -V -i <경로>`는 거부되지 않았습니다. 키 파일을 읽지 못하게 막아도 `ssh -i`로 키를 쓰는 명령은 그대로 실행된다는 뜻으로 보이지만, 실제 접속 명령으로 확인한 것은 아닙니다.

## 사용법

PowerShell 7(`pwsh`)에서 실행합니다. `Export`와 `Install`은 기본적으로 미리보기만 하며, 실제 복사·제거에는 `-Apply`가 필요합니다.

현재 PC와 저장소의 차이를 확인합니다. `Check`는 모든 설치 경로를 검사하며, 제거 대상 Skill이나 경로가 남아 있으면 `[REMOVE-PENDING]`, 권한 규칙이 빠져 있으면 `[PERMISSION-MISSING]`, 이 클론에 pre-commit 훅이 연결돼 있지 않으면 `[HOOK-MISSING]`을 출력하고 종료 코드 1을 반환합니다.

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

`Install -Apply`는 덮어쓸 기존 파일과 Skill 폴더를 먼저 `~/.agents-dotfiles-backups/<run-id>/`에 백업합니다. 제거 대상 Skill 폴더와 `RemovedPaths`의 경로는 같은 백업 디렉터리로 이동하므로 로컬 수정분과 하위 파일도 보존됩니다. 별도 설치한 Skill은 건드리지 않습니다. Skill 자체가 심볼릭 링크·정션이면 연결 항목만 이동하며 연결 대상은 따라가지 않습니다. 설치 루트나 그 상위 경로가 연결이면 제거를 거부합니다.

Skill을 제거하려면 이름을 `Skills`에서 빼고 `RemovedSkills`로 옮긴 뒤 `skills/`의 원본을 삭제합니다. 단순히 원본 폴더가 없다는 이유로 설치본을 삭제하지는 않으며, 설치 대상 원본이 없으면 오류로 처리합니다. `Export`는 활성 `Skills`만 내보냅니다. 활성 Skill 내부에서 지운 파일은 설치본에서 자동으로 정리되지 않습니다.

Skill을 추가하거나 고친 뒤에는 정적 검사를 돌립니다.

```powershell
pwsh -File ./scripts/lint-skills.ps1
```

macOS와 Linux에서는 같은 검사를 bash로 돌립니다.

```bash
bash ./scripts/lint-skills.sh
```

린트 규칙을 더하거나 고친 뒤에는 두 스크립트가 같은 입력에 같은 결과를 내는지 검증합니다. `pwsh`와 bash가 모두 있어야 하고, Windows에서는 Git에 포함된 bash를 씁니다. 새 규칙에는 이 스크립트의 망가뜨린 Skill 묶음에 해당 사례와 기대 메시지를 더합니다.

```powershell
pwsh -File ./scripts/test-lint-skills.ps1
```

`hooks/pre-commit`은 커밋할 때마다 이 검사를 자동으로 돌립니다. 작업 폴더가 아니라 스테이징된 내용을 검사하고, Windows에서는 PowerShell 쪽을, 그 밖에서는 bash 쪽을 씁니다. Git은 훅 설정을 클론과 함께 옮기지 않으므로 클론마다 한 번 연결합니다. 연결하지 않은 클론은 `Check`가 `[HOOK-MISSING]`으로 알려 줍니다.

```bash
git config core.hooksPath hooks
```

동기화 스크립트를 변경한 뒤에는 실제 사용자 홈 대신 `work/` 아래 임시 홈을 사용하는 검증을 실행합니다. 검증 자료는 확인을 위해 해당 폴더에 남습니다.

```powershell
pwsh -File ./scripts/test-sync.ps1
```

테스트용 홈 경로를 지정할 수도 있습니다.

```powershell
pwsh -File ./scripts/sync.ps1 -Mode Install -HomePath ./work/test-home -Apply
```

### 도구 점검과 프로젝트 Node 실행

에이전트가 작업을 시작하기 전에 도구가 준비됐는지 확인합니다. 종료 코드 0은 준비됨(경고가 있을 수 있음), 1은 필수 도구(git, fnm, uv, jq)나 프로젝트 Node 점검 실패, 2는 프로젝트 설정 오류입니다. `-Json`을 붙이면 같은 결과를 JSON으로 냅니다.

```powershell
pwsh -File ./scripts/agent-doctor.ps1 -ProjectPath C:\src\my-project
```

프로젝트가 고정한 Node 버전으로 명령을 실행합니다. 정확한 버전(예: `26.10.0`)이 적힌 `.node-version`이나 `.nvmrc`가 있어야 하고, 그 버전이 fnm에 이미 설치돼 있어야 합니다. 없으면 다른 버전으로 대신 실행하지 않고 실패합니다. 프로젝트 경로 뒤의 인자는 셸 코드로 해석하지 않고 그대로 넘깁니다.

```powershell
pwsh -File ./scripts/repo-run.ps1 C:\src\my-project npm run check
```

두 스크립트를 고친 뒤에는 검증을 실행합니다. 기본값으로 Node 24.21.0과 26.10.0이 fnm에 설치돼 있어야 하고, 다른 버전은 `-NodeVersions`로 지정합니다. PowerShell에서 실행합니다. 2026-11-18에 Git Bash에서 띄웠을 때는 작업 폴더 비교 단계에서 실패했고, 원인은 확인하지 않았습니다.

```powershell
pwsh -File ./scripts/test-agent-tools.ps1
```

## 평가 시드

`evals/`는 실제 모델 실행용 입력과 기대 행동을 기록한 수동 평가 자료입니다. 정적 검사 통과는 모델의 행동 검증을 뜻하지 않습니다. 지침 변경 전후를 비교할 때는 같은 모델·effort·테스트 자료를 사용한 별도 세션에서 실행하고, 한 번에 한 가지 변경만 비교합니다.
