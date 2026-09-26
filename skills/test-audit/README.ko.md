# 개인용 Test Audit

테스트를 많이 만들거나 많이 지우는 대신, 실제 결함 검출력과 유지보수 비용을
기준으로 테스트를 작성하고 정리하는 개인용 코딩 에이전트 스킬입니다.
특정 언어, 프레임워크, 저장소, 모델 버전에는 의존하지 않습니다.

## 구성

- `SKILL.md`: 호출 조건, 테스트 작성 판단 기준, 검증과 종료 조건.
- `references/audit.md`: 테스트 정리를 요청했을 때만 읽는 감사 절차.
- `README.ko.md`: 설치와 사용 안내. 작업마다 읽을 필요는 없습니다.
- `LICENSE.txt`: 기반으로 삼은 OpenClaw 자료의 MIT 고지.

별도 스크립트, 패키지 설치, MCP 연결, 추가 스킬은 필요하지 않습니다.
실제 테스트 실행에는 각 프로젝트의 기존 도구와 환경을 사용합니다.

## 설치: 개인 Codex

`test-audit` 폴더 전체를 다음 위치에 두세요.

```text
$HOME/.agents/skills/test-audit/
  SKILL.md
  references/audit.md
  README.ko.md
  LICENSE.txt
```

Windows PowerShell에서는 아래 명령을 ZIP을 저장한 폴더에서 실행할 수 있습니다.
기존 `test-audit` 폴더가 있으면 덮어쓰지 않고 중단합니다.

```powershell
$ErrorActionPreference = 'Stop'
$archive = (Resolve-Path -LiteralPath '.\test-audit-personal.zip').Path
$skills = Join-Path $HOME '.agents\skills'
$target = Join-Path $skills 'test-audit'
if (Test-Path -LiteralPath $target) {
    throw "이미 설치된 폴더가 있어요: $target. 내용을 비교한 뒤 수동으로 교체하세요."
}
New-Item -ItemType Directory -Path $skills -Force | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $skills
```

저장소에만 적용하려면 개인 경로 대신 `<repository>/.agents/skills/test-audit/`에
설치하세요. 같은 이름의 개인용 스킬과 저장소용 스킬을 중복 설치하면 자동으로
합쳐지지 않으므로 한 범위를 선택하는 편이 명확합니다.
Codex에서 `/skills` 또는 `$test-audit`로 확인하세요. 변경이 나타나지 않으면
Codex를 재시작하세요. 설치 위치와 호출 방식은 아래 공식 문서를 기준으로 합니다.

## AGENTS.md와의 연결

자동 선택은 스킬 설명과 요청의 일치 여부에 달려 있습니다. 테스트 작업에 이
기준을 일관되게 적용하려면 기존 테스트 지침을 다음 한 줄로 연결할 수 있습니다.
상충하는 `NEVER write unit tests after code`나 `E2E-only` 규칙을 함께 남기지 마세요.
기존 프로젝트의 필수 검증 지침은 유지하세요.

```markdown
- Use $test-audit when adding, changing, or reviewing tests, or choosing regression coverage; do not expand a local task into a repository-wide audit.
```

## 사용 예시

읽기 전용 감사:

```text
$test-audit
이 저장소의 중복·구현 결합 테스트를 점검해줘.
우선 수정하지 말고, 삭제 후보와 남는 검증 근거를 정리해줘.
```

구현과 함께 사용:

```text
$test-audit
응답 파싱 버그를 수정하고, 이 실패를 실제로 잡는 회귀 검증을 추가하거나
기존 검증을 보완해줘. 관련 검증까지 마치되 무관한 테스트 정리는 하지 마.
```

이 스킬은 다음을 의도합니다.

- E2E, 통합, 단위, 계약, 속성 테스트를 이름이 아니라 검출할 실패로 선택합니다.
- 구현 후 테스트 작성을 금지하지 않고, 기대값의 독립성과 실패 감지 여부를 봅니다.
- mock 사용을 금지하지 않지만, mock으로 검증하지 않은 외부 경계까지 성공으로
  보고하지 않습니다.
- 유효한 Clock·난수·전송 계층 주입은 유지하고, 저가치 테스트용 우회 구조를 줄입니다.
- 테스트 삭제 전 사라질 검증과 남는 검증을 확인합니다. 애매하면 유지합니다.
- 복잡한 흐름은 기존 도구로 얻을 수 있는 최소 증거와 재실행 방법을 남깁니다.
- 요청된 결과와 필수 검증을 충족하면 종료합니다. 습관적인 전수 검사나 반복
  검증, 불필요한 감사 문서는 요구하지 않습니다.

## 확인 범위

이 배포본은 Markdown 파일 구성, YAML frontmatter, 로컬 참조 경로와 ZIP 무결성을
검사했습니다. 실제 Codex 세션에서의 자동 호출·작업 행동이나 특정 저장소의
테스트는 실행하지 않았습니다. 위 PowerShell 예시도 Windows에서 실행하지 않았습니다.
지침에 실행 권한이나 CI 강제력이 생기는 것은 아닙니다.

## 출처와 변경

OpenClaw의 `test-audit`를 바탕으로 새롭게 구성한 개인용 변형입니다.
OpenClaw 전용 테스트·리뷰·PR 명령, 대규모 캠페인 전제, 삭제량 중심 보고를
제거하고, 검증 경계 선택·DI 예외·증거의 한계·종료 조건을 조정했습니다.
원본 저작권 및 MIT 허가 고지는 `LICENSE.txt`에 보존했습니다.
OpenClaw의 공식 배포본이거나 공식 승인을 받은 스킬은 아닙니다.

확인일: 2026-09-26.

- OpenClaw 원본: https://github.com/openclaw/openclaw/blob/main/.agents/skills/test-audit/SKILL.md
- OpenClaw 라이선스: https://github.com/openclaw/openclaw/blob/main/LICENSE
- Codex 스킬 형식·설치: https://developers.openai.com/codex/skills/
- OpenAI의 스킬 범위·분리 지침: https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra
