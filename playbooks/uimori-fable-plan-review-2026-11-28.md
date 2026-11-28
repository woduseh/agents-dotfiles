# Fable 리아's whole-plan review (2026-11-28 ~08:40 KST)

Requested by 재연님. Reviewer: Claude Fable 5.2 (xhigh), read-only. Source: T3 thread "Fable 리아: Uimori 전체 계획 검토". Verbatim below; the next step is a discussion with 니아.

---

# Uimori 개선 계획 전체 검토 (Fable 리아)

**결론:** 목표 플랜의 방향은 맞아요. 다만 Phase 1이 "경계 세우기"에서 "전수 감사·광택"으로 바뀌었고, 코드를 가장 많이 줄여 줄 구조 작업(도우미 이중 래핑, 러너 6개, `App()` 모놀리스)은 아직 시작 전이에요. Phase 1은 래칫으로 지금 닫고, 도우미 방향을 먼저 정한 뒤 Phase 3 → 2(축소) → 4 순서로 가길 권해요.

읽은 것: 니아의 두 원안 전문, 플레이북 3종, 백로그, `REVIEW-RUBRIC`·`CHECKS`·`CODE-MAP`, 코드 실측, PR·CI 기록. T3 스레드 원문과 실제 운영 DB는 보지 않았어요.

## 실측 요약

| 항목 | 값 |
| --- | --- |
| 라우트 | 계약 67개, raw 214개 |
| Wave 2 이후 19시간 (`d7d98b43..HEAD`) | 커밋 141개 중 `fix` 70개, +23,132/−12,201줄 |
| `tests/` 줄 수 | 198.7k (11-26) → 146.8k (Wave 1b 종료) → 152.3k (지금, +5.5k) |
| 미배포 분량 | `v0.18.1` 이후 184커밋, +30k/−23k. 그전에는 하루에도 여러 번 릴리스 |
| PR CI | 2–11분, 최근 40회 중 8회는 재푸시로 취소 |
| 도우미 | 제품 코드 110파일 38.4k줄, 테스트 65파일 26.9k줄 |

## 추천 5가지 (순위순)

"보호 대상" = AGENTS.md의 네 가지(저장된 글, 작성 중 초안, 유료 생성, 백업 복원).

### 1. Phase 1을 전 라우트 전환이 아니라 래칫으로 지금 닫기
- 무엇: P1-3h 가드를 먼저 넣어요. 모든 `/api` 라우트는 `registerEndpoint`이거나 줄어들기만 하는 허용목록에 있어야 하고, 새 `api<T>()`는 금지.
- 지금 전환할 것: 달리는 4개 레인, 그리고 risu와 context/outline까지.
- 보류할 것: `product-routes.ts` 41 + `app.ts` 36 + `helper-routes.ts` 35 + 삽화 22 = 134개(남은 것의 63%)는 Phase 3에서 한 번만 손대요.
- 근거: 이 134개는 유료 생성 접수 경로이거나, 도우미 결정에 따라 사라질 수 있거나, `TaskRuntime`이 다시 짤 곳. receipt 관련 단위(stored-errors B, prep-a)는 리뷰가 세 번씩 돌았어요.
- 포기하는 것: `request-validation` HTTP 헬퍼와 `api<T>()`가 Phase 1에서 0이 되지 않음. 두 스타일이 몇 주 공존, 이 라우트들의 감사도 미뤄짐.
- 뒤집는 증거: 달리는 4개 레인이 접수·receipt 지적 없이 1차 승인으로 끝나고, 커맨드 3개 파일럿에서 지금의 핸들러가 그대로 커맨드 안으로 옮겨진다면 끝까지 전환하는 편이 쌈.

### 2. 도우미 방향(인앱 유지 vs MCP 축소)을 Phase 3 앞에 세우기
- 무엇: 기존 도구 스키마(`app.tools`/`app.call`, `uimori call`)를 얇게 감싼 MCP 서버를 1–2단위 스파이크로. 재연님이 Claude Code나 Codex로 실제 카드·로어 작업을 며칠 해 보고 결정.
- 근거: 이 결정이 제품 코드 약 4분의 1의 운명과 P1-3g2, Phase 3 설계, `HelperPanel`(2.9k줄) 분해 여부를 한꺼번에 정함.
- 포기하는 것: 달력으로 며칠, 스파이크는 버려질 수 있음. 축소로 가면 모바일에서 도우미만으로 끝내는 사용성을 잃음.
- 뒤집는 증거: 써 보는 동안에도 인앱 도우미를 더 자주 찾거나(특히 폰), 외부 에이전트가 MCP로 CBS/Lua 작업을 인앱만큼 못 하면 유지.

### 3. 마이그레이션 전에 실제 스냅샷 재생 검사와 릴리스 체크포인트 두기
- 무엇: 운영 스냅샷 사본을 새 빌드로 열고(외부 호출 차단), 모든 읽기 엔드포인트 출력을 해시해 빌드 전후 비교하는 스크립트. Phase 경계마다 릴리스 후보와 "직접 볼 화면 목록" 한 장.
- 근거: AGENTS.md는 마이그레이션에 real-shaped data 테스트를 요구. 지금 픽스처는 합성이고 백로그에도 여러 테이블과 이벤트 종류가 비어 있다고 적혀 있음. 실사용 검증 없이 184커밋이 쌓여 있음.
- 포기하는 것: 새 인프라 1단위, 작업별 운영 접근 승인, 재연님의 릴리스 시간.
- 뒤집는 증거: 운영 DB와 픽스처의 형태 목록 비교에서 운영에만 있는 형태가 없으면 합성 픽스처로 충분.

### 4. 범위를 키우는 루프 규칙 세 개 바꾸기
- 리뷰 강도를 "새 메커니즘 여부"가 아니라 보호 대상을 건드리는지로: 건드리면 시아 필수 + xhigh, 아니면 리뷰어 한 명 `high`, pre-flight 없이.
- 보호 대상 밖의 기존 결함은 그 단위에서 고치지 않고 목록에만.
- "수정마다 실패 재현 테스트"는 `CHECKS`의 유지 기준에 드는 것만.
- 근거: 커밋 절반이 `fix`, 큰 몫이 드문 경합에서 어떤 오류 코드·문구가 뜨는지. `tests/settings-error-fallbacks.test.ts`는 `FileReader`를 목킹해 메시지 키를 확인(`CHECKS`가 쓰지 말라는 진단 문구 테스트). 보호 대상 결함(초안 덮어쓰기, 프리셋 중복 저장, 오류 중복 제거)은 시아가 다섯 번 잡았고 니아는 같은 diff를 통과시킴.
- 포기하는 것: 문구·정밀도 결함 일부가 남고, 같은 문구 버그가 돌아올 수 있음.
- 뒤집는 증거: 한 릴리스 안에서 "두 번째 리뷰어나 회귀 테스트가 막았을" 회귀를 두 번 이상 만나면 그 부류만 되돌림.

### 5. 순서를 Phase 3 → Phase 2(축소) → Phase 4로 바꾸고 P1-4는 접기
- Domain Command와 `TaskRuntime` 먼저, 스키마는 그 뒤 목표 형태를 한 번만 설계, P1-4a/b 파일 이동 대신 Biome 경계 규칙만, P1-4c 드롭.
- 근거: `TaskRuntime`이 `runs`/`jobs`/`illustration_jobs`를 어차피 다시 짬. 원안 순서면 실제 DB가 마이그레이션을 두 번 겪음. 도우미 결정에 따라 사라질 테이블을 미리 정규화할 이유 없음. risu 서버 파일 51개 중 `Store` import는 9개라 lint로 충분.
- 포기하는 것: `Store` 허브(164개 파일 import)와 `app_metadata` 우회가 더 오래 남음. SQL 직접 테스트 117개가 Phase 3 동안 브레이크.
- 뒤집는 증거: 커맨드 3개 파일럿에서 매번 `Store` 내부를 고쳐야 하거나 SQL 테스트가 무더기로 깨지면 `Store` 좁히기를 먼저.

## 1. 방향: Phase별 판단

| 항목 | 판단 | 이유 |
| --- | --- | --- |
| 오류 `{code, params}`, `UiMessage`, 계약 인프라, stale-tab 매트릭스 | 유지(완료) | 매트릭스는 실패 엔드포인트 11개를 잡음 |
| 전 라우트 타입 계약 | 래칫으로 축소 | 추천 1 |
| P1-4 패키지 추출 | lint 경계로 대체 | 엔진을 따로 쓸 두 번째 소비자가 없음 |
| 번호 i18n 키 1,758개 → 시맨틱 키 | 명시적으로 드롭 | 원안에 있다가 조용히 빠짐. 충돌 대비 이득이 작음 |
| Phase 2 | 러너 + 우회 제거 마이그레이션만 | `sqlite_sequence` 직접 UPDATE(`server/prompt-workspace-events.ts:10`). `versions` 분리와 `nativeRisu` SSOT는 실제 결함이 나올 때 |
| Phase 3 | 앞으로 당김 | 기능 하나에 6–8곳을 건드리는 문제의 본체. 접수 경로가 `server/app.ts:346` 주변 Map 3개와 `pump*()` 호출 십여 곳에 흩어짐 |
| Phase 4 | 유지, 순서만 조정 | `main.tsx` 3.7k줄에 `useState` 60개. 백로그 1·2·8번을 먼저 지우면 `useDurableMutation`이 통합할 곳이 3–4곳으로 줄어듦 |
| Wave 3 신호 | 지금 당김 | 테스트가 다시 늘고 있으니 PR 요약에 `tests/` 줄 수 변화를 바로 표시 |

빠져 있는 것: 실데이터 리허설, 마이그레이션 직전 스냅샷을 2일 보존 규칙 밖에 따로 보관, 릴리스 체크포인트.

## 2. Phase 1 잔여: 더 싼 길

- 출력 스키마 생략: 웹과 서버가 한 `tsc` 프로그램이라 남은 라우트는 입력 스키마만, 출력 타입은 핸들러 반환 타입을 type-only로. 복잡한 모델은 이미 `z.looseObject`와 웹 캐스팅(`prompts/operations.ts` 21곳, 캐스팅 5곳). 포기: 테스트 모드 strict 출력 parse(실제 결함을 잡았는지 미확인; 잡았다면 변이 응답에만 유지).
- 죽은 라우트 먼저 지우기(텍스트 검색 가설): `/api/chat-activities`, `/api/runs/:id/candidate`, `/api/chats/:id/transcript`, `/api/provider-management/:kind/:id/impact`, `/api/diagnostics/metrics`.

## 3. 루프

잘 됨: type-first 전환, shrink-only 래칫, PR 자동 병합, Sonnet 레인, 자기 종결 레인. 바꿀 것: 추천 4와 아래.
- 플레이북 분리: 80KB 대부분 일지, 조정자 세션 3·4·5가 연달아 컨텍스트 크기로 닫힘 → 40줄 `STATE.md` + 일지 보관 파일.
- 백로그 정리(80여 항목): 삭제 항목 먼저 / 보호 대상 결함 지금(receipt-before-digest, 백업 id 맵 분리) / 문구·정밀도 항목은 닫고 실사용에서 보이면 재오픈.
- 루브릭 첫 줄(stale-tab 순서)은 매트릭스가 강제하니 루브릭 규칙대로 삭제.
- pre-flight 메모는 보호 대상 단위에만.

## 4. 범위 증가와 "완료" 정의

| 가치 있음 | 보류 | 컷 |
| --- | --- | --- |
| stale-tab 매트릭스, `ProductStore.stored`, JSON 경계, 고정 프롬프트 백업 수정, 병합 큐, 스크립트 타입 검사 | 서버·코어 비-throw 한국어 검사, `t()` 키 타입화, `resolveRunError` 통합, 번호 키 정리 | P1-4c, 문구 전용 회귀 테스트 추가, `--allow` glob 목록 |

Phase 1 완료: wire `{code, params}`뿐(완료) · 한국어·`.message` 래칫 0(완료) · 라우트 가드+허용목록 · 달리는 레인 병합 · 릴리스 후보와 확인 목록 전달.
전체 완료: 변이 하나가 커맨드 한 곳에 정의 · 유료 호출 접수 경로 하나 + 불변식 모델 테스트 · `App()`/`useStory` 분해 · 스키마 우회 0 · 테스트 줄 수 Wave 1b 종료 시점 이하.

재추정("루프 하루치" = 지난 24시간 처리량, 커밋 약 140개·PR 20개): Phase 1 닫기 0.5 · 도우미 스파이크 0.5 + 재연님 시험 며칠 · Phase 3 3–7 · Phase 2 축소판 2–3 · Phase 4 5–8. 제안 범위 합계 12–20(쿼터 감안 3–5주), 원안 범위를 지금 철저함으로 하면 25–40. "전체 35%"는 낙관적, 원안 기준 15–20%.

## 5. 위험과 다음 한 수

데이터 위험: 합성 픽스처만으로 v16 마이그레이션 · 유료 생성 경로를 라우트 전환과 `TaskRuntime`으로 두 번 고침 · 184커밋 미배포로 회귀 늦게 발견 · 백업 2일 보존 상태에서 마이그레이션 실패.
완주 위험: 종료 조건 없이 범위 증가 · 도우미 결정 지연 · Phase 4에서 재연님 UI 판단 병목.

다음 한 수: P1-3h 가드를 허용목록 래칫으로 지금 넣고 Phase 1을 닫기. d1(Risu)과 e2a(context/outline/story-ui)는 진행해도 됨.

---

# 니아's discussion (2026-11-28 ~09:10 KST)

Full text: T3 thread "니아: Fable 리아 전체 계획 검토 논의". Summary:

- Agrees with the diagnosis. Corrections from code: routes are 67 contract / 218 raw; Fable's 134 deferred routes overlap the running lanes (d2/e1 already pull ~15 from `product-routes.ts`, d1 takes 3 + 2 from `app.ts`); after the 4 lanes ~164 raw remain (helper 35, run/job admission ~28, plain CRUD ~48, d1/e2a ~23, binary/ops ~15). Helper is 38.6k lines = 16.9% of product code (65.5k with tests), not a quarter. `operation.output.parse` never caught a real defect in `d7d98b43..HEAD` → new endpoints/commands: Zod input, type-only output (except credential/secret boundaries and MCP outputs).
- Disagrees with Fable on: (1) **defer d1 and e2a too** (d1 is the receipt/Risu hotspot that took 3 review rounds); (2) **keep the rubric's stale-tab line, shortened** to "unconverted write routes + invalid-body/exemption check for new matrix cases" (the matrix covers only `allEndpoints`; e2b just missed a valid-body probe); (3) Fable's premise that TaskRuntime means two migrations is half wrong — TaskRuntime is a runtime adapter over the existing tables (no DB migration); Phase 3 → 2 still right because helper tables may disappear and commands reveal the narrow Store ports; (4) Store: don't defer decoupling — new Domain Commands/TaskRuntime take narrow ports (`ChatWritePort`, `TaskQueuePort`) from the first commit.
- Dead-route check: delete `GET /api/provider-management/:kind/:id/impact`, `GET /api/chat-activities`, `POST /api/runs/:id/candidate` (move its 4 tests); ask 재연님 about `GET /api/chats/:id/transcript` (docs/CHAT-TRANSCRIPT.md); keep `GET /api/diagnostics/metrics` (documented operator API).
- Progress: 15–20% of the original scope, ~30–35% of the slimmed scope — report both.
- Helper spike: compare three options A keep / **B hybrid (recommended)**: heavy tools (~80) via MCP, light in-app creative helper (~10–15 tools) / C MCP only; spike excludes paid-generation tools and goes through an authenticated HTTP bridge so 재연님 can try it against the real Oracle instance.
- Snapshot check: normalized JSON diff (ignore timestamps/ETag/Server-Timing) + `.uimori`/`.chat.uimori` round trip, one `scripts/verify-snapshot-compat.ts` that also serves as the v15→v16 differential test later; snapshot supplied and approved by 재연님, never in the repo.
- Loop rules: protected data → 시아 required + 니아 xhigh + pre-flight; new shared architecture boundary → 니아 xhigh + pre-flight; mechanical/single-domain → one `high` reviewer, no pre-flight; lever 4 never without 시아; pre-existing non-protected defects listed only; fail-first tests only under CHECKS keep criteria, no wording/fallback-mapping or mocked-boundary unit tests; delete worktrees right after merge.
- Merged next units: U1 land the 4 lanes + delete 3 dead routes · U2 Phase 1 ratchet close (P1-3h guard incl. e2b's contracted-path check, Biome boundaries instead of P1-4, `tests/` line delta in `ci-summary`, chat-backup id-map split, `fail-next` flake, wording-mock test cleanup, worktree cleanup, `STATE.md`) · U3 snapshot-compat script + release checkpoint #1 · U4 helper MCP spike → A/B/C decision · U5 delete over-defenses (backlog 1/2/4/8; optional SQLite template clone for Vitest) · U6 Phase 3a Domain Command core + narrow Store ports + 3 pilots · U7 Phase 3b TaskRuntime over existing tables + app.ts split + state-machine PBT · U8 Phase 3c apply the helper decision, release #2 · U9 Phase 2 reduced v16 (snapshot kept outside the 2-day rule), release #3 · U10+ Phase 4 frontend, release #4.
- Missed by both: 37 worktrees piled up (+ `.build-…-previous/` in the repo root); `api()`↔`callEndpoint()` drift during coexistence (fold e2b's check into P1-3h); 260 browser specs coupled to Korean text/CSS will fight Phase 4 (move touched screens to `data-testid`/ARIA); Vitest SQLite init is 63% of test time → template-file clone is a standalone unit.
