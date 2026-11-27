# Uimori Wave 1b browser-spec cut plan (니아, 2026-11-27, against 0b41f164)

Source: T3 delegated task "니아: Wave 2 브라우저 스펙 다이어트 계획". Kept verbatim below.

안녕, 리아! 23개 도메인 스펙 파일 111개 전체와 오늘 실측 실행 기록([playwright.json](file:///C:/Users/wodus/ai-workspace/uimori/output/playwright/browser-2026-11-27T00-50-38-084Z-84e85ec9/playwright.json), HEAD `0b41f164`)을 전수 확인해서 Wave 2 브라우저 스펙 다이어트 계획을 정리했어요.

## 핵심 요약 (목표 수치)

- **대상 범위 (`npm run verify -- all`)**: 등록 스펙 111개 중 별도 러너인 `self-host`(3건)와 비공개 opt-in인 `risu-native-samples`를 제외한 **109개 스펙 / 333 런타임 케이스**가 기준이에요. *(참고: 프롬프트의 정적 `test()` 333건과 우연히 숫자가 같은데, `self-host` 3건·비공개 샘플이 빠지는 대신 `for` 루프 확장 6건이 들어가서 런타임도 정확히 333건이에요.)*
- **목표치**:
  - `verify -- all` 스펙 파일: **109개 → 86개** (-23개 삭제, -21.1%; `self-host`·비공개 포함 등록 111 → 88개)
  - `verify -- all` 런타임 케이스: **333건 → 165건** (**-168건, -50.5%**) — `self-host` 3건과 `risu-native-samples`는 그대로 유지
  - 실측 케이스 합산 시간(`sumDur`): **1,075.6초 → 609.3초** (**-466.3초, -43.4%**)
  - 8워커 벽시계 시간(**추정**): 현재 실측 **175.8초**(하네스 전체 179.5초) → 케이스 정리만 적용 시 **약 100~110초 (-40% 안팎 추정)**, 5절의 구조 개선까지 얹으면 **약 85~95초 추정**
- **유일한 Vitest 이관 권장**: `chat-generation`의 `QUEUE02/05/07/09/10`(클라이언트 다음 요청 자동 전송 중단·초안 복귀 가드)은 현재 대응하는 Vitest 단위 테스트가 없어서, 브라우저 5건을 지우는 대신 순수 가드 로직을 Vitest 1파일로 옮기는 편이 안전해요. (`READERREC invalid view caches` 1건도 [tests/reader-sync.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-sync.test.ts)에 보강 권장)

---

## 1. 도메인별 판단 (23개 전체)

표기는 **실측 런타임 케이스 수 / 실측 합산 시간(`sumDur`)** 기준이에요. 삭제마다 근거 기준과 남은 보호처를 적었어요.

### 1) `reader` — 파일 10 → 7 / 케이스 42 → 18 (-24) / 108.5s → 50.9s
- **[tests/ui-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/ui-browser.spec.ts)** (12 → 4)
  - **유지**: `UI01..09`(12.2s, 대표 리더/XSS/무호출 뷰 전환 — 내부 2뷰포트×3스크롤 루프는 5절에서 축소 권장), `UI18 lazy translation`(3.8s, 의도치 않은 유료 자동 번역 차단), `UI18 source/translation edits`(3.0s, 저장 본문·다음 생성 반영), `UI18 two-tab conflicts`(2.3s, 2탭 CAS 충돌·초안·지연 번역)
  - **삭제 (8)**:
    - `UI03 bot-first retry`(2.3s) — 제거된 컨트롤 단언 + 프로필 재시도 중복 / 보호: `NSUI01`, [tests/product.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/product.test.ts)
    - `UI05 UI10 late auxiliary`(2.2s) — 실패 번역 재시도 5중 중복 중 하나 / 보호: `AUXREC`, [tests/translation-auto-retry.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/translation-auto-retry.test.ts)
    - `UI12 lost response`(0.9s) — 불확실 요청 재확인 중복 / 보호: `READERREC confirming`, [tests/run-retry-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/run-retry-browser.spec.ts)
    - `UI07 UI12 lost fork`(1.9s) — 제거된 컨트롤(`보관된 분기`/`다른 응답` count 0) 고정 / 보호: `P09`, [tests/chat-fork.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-fork.test.ts)
    - `UI03 starting without a model`(2.3s) — 설정 안내 문구 + 제거된 컨트롤 단언 / 보호: 없음(안내 문구)
    - `UI03 UI12 creating a chat never overwrites global models`(1.5s) — 전역 모델 경계 중복 / 보호: `GMUI01`, [tests/prompt-workspace-store.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-workspace-store.test.ts)
    - `UI17 prompts use latest settings`(1.8s) — 프롬프트 동시 수정 중복 / 보호: `PWS01`/`PWS02`, `DECISION`
    - `UI whole-source translation`(3.0s) — 실패 번역 재시도 5중 중복 / 보호: `AUXREC`, [tests/source-translation.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/source-translation.test.ts)
- **[tests/reading-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `READUI01`(8.1s) — `28px`/`42px`/`2.2`/색상 CSS 고정 + 탭 동기화 중복 / 보호: `SETSYNC01`, [tests/reading-preferences.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-preferences.test.ts)
- **[tests/reading-markdown-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-markdown-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제**: 2건(3.7s, 3.2s) — 사설 `startFixtureVite` 기하(`getBoundingClientRect` 단조성) 고정 / 보호: [tests/reading-markdown.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-markdown.test.ts), [tests/risu-reading-markdown.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-reading-markdown.test.ts), `UI01`
- **[tests/reader-navigation-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-navigation-browser.spec.ts)** (4 → 0, **파일 삭제**, `READERNAV` 1건만 `reader-recovery-browser.spec.ts`로 이동)
  - **이동 유지**: `READERNAV initial loading recovers after A-B-A`(1.6s, 실제 A→B→A 비동기 경합)
  - **삭제 (3)**: `explicit source navigation`(2.9s), `late native message growth`(2.7s) — 사설 Vite 스크롤 기하 고정 / 보호: [tests/reader-navigation.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-navigation.test.ts); `CHATREC03`(3.3s) — 사설 Vite에서 제거된 버튼(`이전 장면`/`다음 장면` count 0) 단언 / 보호: `PWUI03`, [tests/reader-navigation.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-navigation.test.ts)
- **[tests/reader-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-recovery-browser.spec.ts)** (7 → 4 + 이동 1 = 5; CI `--grep READERREC` 유지)
  - **유지**: `initial reader loading`(1.1s — 내부 `activity-spin`/`36px` 픽셀 단언 제거 권장), `leaving during a position write`(2.3s), `confirming an uncertain request`(1.8s), `failed command persistence`(0.8s) + 이동된 `READERNAV`(1.6s)
  - **삭제 (3)**: `late position ack (old-refresh)`(2.2s), `(new-move)`(2.4s) — 같은 지연 ack 상태머신 2회 반복 / 보호: `leaving during a position write`, [tests/reader-sync.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-sync.test.ts); `invalid view caches`(0.7s) — 손상된 `localStorage` JSON 폴백 / 보호: [tests/reader-sync.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-sync.test.ts)에 단위 테스트 1건 보강 권장
- **[tests/reader-selection-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-selection-browser.spec.ts)** (10 → 4)
  - **유지**: `RSEL02 bot chat drawn by Risu`(2.0s), `RSEL03`(2.5s), `RSEL04`(2.6s), `RSEL13`(2.5s, 열린 편집기 강제 전환 방지)
  - **삭제 (6)**: `RSEL01 plain`(1.8s)·`RSEL01 bot`(1.3s) — 버튼 노출 조건 중복 / 보호: [tests/reader-selection.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-selection.test.ts), [tests/selection-revision.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/selection-revision.test.ts); `RSEL02 plain`(1.9s) — 실제 앱은 모든 봇 채팅이 Risu 렌더러라 목업 plain 중복 / 보호: `RSEL02 bot`; `RSEL07`(1.9s) — 스크롤 배지 UI 세부 / 보호: `RSEL13`, [tests/reader-selection.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-selection.test.ts); `RSEL17`(1.9s) — `RSEL02`/`03` 부분집합 / 보호: `RSEL02`/`03`; `RSEL22`(1.8s) — 터치 툴바 픽셀 도킹(`>= bottom + 32`) 고정 / 보호: 없음(기하)
- **[tests/reader-visibility-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reader-visibility-browser.spec.ts)** (1 → 1): `READVIS01`(3.1s) **유지**
- **[tests/selection-revision-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/selection-revision-browser.spec.ts)** (2 → 2): `SREV 360`(3.0s), `SREV late proposal`(1.8s) **유지** (편집기 내 대표 흐름 + 지연 응답 초안 보호)
- **[tests/source-edit-focus-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/source-edit-focus-browser.spec.ts)** (2 → 1)
  - **유지**: `C04V`(2.7s, 저장 버전 비교·복원·읽기 전용 경계)
  - **삭제**: `C04E`(1.8s) — 일반 503 저장 실패·포커스 복귀 반복 / 보호: `UI18`, [tests/source-history-storage.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/source-history-storage.test.ts)
- **[tests/writing-tools-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/writing-tools-browser.spec.ts)** (1 → 1): `WRITINGTOOLS`(2.1s, `.md` 범위 내보내기) **유지**
- *문서 포인터 갱신*: [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L79(`RSEL22`), L109(`RSEL01`–`RSEL04` → `RSEL02`–`RSEL04`), L225(`RSEL07` 제거), L249(삭제 스펙 3개 정리)

### 2) `chat-generation` — 파일 10 → 10 / 케이스 32 → 15 (-17) / 104.7s → 53.0s
- **[tests/product-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/product-browser.spec.ts)** (3 → 2)
  - **유지**: `P01`(`@smoke`, 7.0s), `P09`(5.0s, 장면 복사 분기·탭 초안)
  - **삭제**: `P02`(3.0s) — 옵션 초안/빠른 페르소나 중복 / 보호: `PWS01`, `OPTIONSCOPE1`, `CSUI04`
- **[tests/browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/browser.spec.ts)** (3 → 1) *(파일 유지로 [docs/plans/ux-redesign.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/plans/ux-redesign.md) 경로도 그대로 통과)*
  - **유지**: `F03 F05 older HTTP response cannot hide committed source`(3.8s, 실제 HTTP 역순 경합)
  - **삭제 (2)**: `F02 F03 F05 two contexts`(11.4s) — 다른 스펙에 이미 분산된 모놀리스 중복 / 보호: `P01`, `UI18 two-tab`, `LOADUI04`, [tests/server.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/server.test.ts); `F05 failed auxiliary retry`(4.2s) — 실패 번역 재시도 5중 중복 / 보호: `AUXREC`
- **[tests/chat-composer-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-composer-browser.spec.ts)** (1 → 1): `shared composer`(1.1s, 한글 IME 가드, `chat-unification` 프리셋) **유지**
- **[tests/composer-next-request-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/composer-next-request-browser.spec.ts)** (8 → 2)
  - **유지**: `QUEUE01`(4.8s, 대표 예약·자동 전송), `QUEUE03`(2.1s, 새로고침 시 자동 전송 없이 초안 복원)
  - **삭제 (6)**: `QUEUE02`(1.5s), `QUEUE05`(1.9s), `QUEUE07`(1.7s), `QUEUE09`(1.9s), `QUEUE10`(3.5s) — 단일 클라이언트 예약 전송 가드의 분기별 5회 반복(전부 풀 루프백 프로바이더 기동) / 보호: **현재 Vitest 공백 → Unit 7에서 순수 큐 가드 단위 테스트(`tests/composer-draft.test.ts` 등)로 이관 권장**; `NEXTREQ01`(2.6s) — 입력창 요약 배지·대화상자 열기 UI 점검 / 보호: 각 설정 스펙
- **[tests/request-edit-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/request-edit-browser.spec.ts)** (2 → 2): `SCCTX01`(2.7s), `REDIT01`(2.4s, `chat-unification`) **유지**
- **[tests/request-images-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/request-images-browser.spec.ts)** (6 → 2)
  - **유지**: `RIMAGE 360`(3.3s, 대표 첨부·새로고침·이미지만 생성·재시도), `RIMAGE failed IndexedDB`(1.3s, IDB 실패 시 텍스트 보존·첨부 복구)
  - **삭제 (4)**: `image-only uncertain admission`(2.0s), `rejected submission and another tab`(2.1s), `pasted/dropped invalid files`(1.1s), `leaving a chat during upload`(1.7s) — 공유 불확실 접수/실패/이탈 패턴 반복 / 보호: `RIMAGE 360`, `run-retry-browser`, [tests/request-images-storage.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/request-images-storage.test.ts)
- **[tests/request-preview-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/request-preview-browser.spec.ts)** (1 → 1): `REQUESTPREVIEW`(4.5s, 대표 요청 미리보기) **유지**
- **[tests/response-actions-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/response-actions-browser.spec.ts)** (4 → 1)
  - **유지**: `RACOM04`(5.9s, 마지막 응답 교체/복사 재시도·실패 시 원문 보존)
  - **삭제 (3)**: `RACOM07`(4.4s) — 취소 카드 닫기 503 재시도(부차 UI 닫기) / 보호: 없음; `RACOM08`(1.9s) — 취소 카드에서 부분 출력·기록 열기 중복 / 보호: `STREAMLIVE`, `SCENEDIAG`; `RACOM05`(4.0s) — `.source-actions > button` 개수 3 고정 + 복사/편집/책갈피 중복 / 보호: `UI18`, `PWUI03`, `ITRAN`
- **[tests/response-stream-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/response-stream-browser.spec.ts)** (3 → 2)
  - **유지**: `STREAMLIVE`(4.4s), `STREAMTRANSLATION`(2.2s)
  - **삭제**: `STREAMFOLLOW`(2.7s) — 하단 추적 스크롤 픽셀 기하(`< 2px`) 고정 / 보호: 없음(기하)
- **[tests/run-retry-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/run-retry-browser.spec.ts)** (1 → 1): `failed request edit`(2.5s, `chat-unification`) **유지**

### 3) `chat-settings` — 파일 6 → 5 / 케이스 12 → 6 (-6) / 38.7s → 19.1s
- **[tests/chat-settings-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-settings-browser.spec.ts)** (5 → 2)
  - **유지**: `CSUI04`(2.9s, 대표 빠른 페르소나/채팅 설정 첨부·입력창 보존), `CSUI10`(3.6s, 대표 원작 참고/스토리 가이드; [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md))
  - **삭제 (3)**: `CSUI02`(4.9s) — 뒤로가기/리사이즈 초안 보존이 공유 설정 셸의 `SCUI02`와 중복 / 보호: `SCUI02`; `CSUI05`(3.7s) — 작가 노트 저장·유효성 반복 / 보호: `S04`, `SETTINGSFLOW`, [tests/story-storage.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-storage.test.ts); `CSUI11`(1.9s) — 드롭다운 1개 저장 / 보호: [tests/chat-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-settings.test.ts)
- **[tests/chat-option-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-option-recovery-browser.spec.ts)** (2 → 1)
  - **유지**: `OPTIONSCOPE1`(3.2s, 고정/1회 범위 구분 저장)
  - **삭제**: `OPTIONREVIEW2`(2.5s) — 공유 충돌·유실 응답 멱등 패턴 반복 / 보호: `DECISION`(`settings-save-decisions`), [tests/chat-options.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-options.test.ts), [tests/chat-option-draft.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-option-draft.test.ts)
- **[tests/chat-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-recovery-browser.spec.ts)** (1 → 1): `CHATREC02`(4.3s, 유일한 채팅 변수 UI/JSON 편집) **유지**
- **[tests/model-picker-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/model-picker-browser.spec.ts)** (2 → 1)
  - **유지**: `MP01`(1.0s, 대표 채팅 모델 선택·상속)
  - **삭제**: `MP02`(1.1s) — 공유 저장 거절/유실 응답 반복 / 보호: [tests/provider-selection.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/provider-selection.test.ts)
- **[tests/agent-collaboration-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/agent-collaboration-browser.spec.ts)** (1 → 1): `AGENTUI02`(4.0s, 대표 협업 편집→미리보기; [docs/dev/PROVIDERS-AND-CODEX.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/PROVIDERS-AND-CODEX.md)) **유지**
- **[tests/evaluation-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/evaluation-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `EVALUI02`(5.5s) — 프로바이더 2개 등록해서 체크박스 3개·제거된 컨트롤 0개 확인 / 보호: [tests/evaluation-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/evaluation-settings.test.ts), `PMUI11`

### 4) `context` — 파일 2 → 2 / 케이스 4 → 3 (-1) / 13.4s → 9.0s
- **[tests/context-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/context-browser.spec.ts)** (3 → 2)
  - **유지**: `CTXUI01`(3.5s, 대표 수동 요약 저장), `CTXUI04`(3.1s, 입력창 정리·1회성 우선순위·초안 보존)
  - **삭제**: `CTXUI02`(4.3s) — 요약/노트 동시 수정 CAS 충돌 반복 / 보호: `DECISION`, [tests/context-checkpoint-storage.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/context-checkpoint-storage.test.ts), [tests/context-integration.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/context-integration.test.ts)
- **[tests/story-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-browser.spec.ts)** (1 → 1): `S04`(2.4s, 대표 작가 노트/수정사항 저장·새로고침 — `CSUI05`와 `CTXUI02`를 지우는 대신 작가 노트 대표 흐름으로 유지) **유지**

### 5) `turn-activity` — 파일 3 → 1 / 케이스 4 → 1 (-3) / 11.9s → 4.5s
- **[tests/scene-diagnostics-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/scene-diagnostics-browser.spec.ts)** (1 → 1): `SCENEDIAG`(4.5s, 유일한 실제 루프백 토큰·로어 영수증→장면 상세) **유지**
- **[tests/turn-activity-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/turn-activity-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제 (2)**: `TURNUI06`(1.7s) — 목업 리더 실패 번역 재시도 5중 중복 / 보호: `AUXREC`, `SCENEDIAG`; `DISPLAY`(3.0s) — 목업 단계 문구·표시 모드 전환 / 보호: [tests/run-projections.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/run-projections.test.ts), [tests/response-progress.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/response-progress.test.ts)
- **[tests/task-trace-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/task-trace-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `TRACE01`(2.7s) — 100% 목업 JSON의 포맷 문구(`모델 6회`, `$0.295+`) 단언 / 보호: [tests/task-trace.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/task-trace.test.ts)
- *문서 포인터 갱신*: [docs/dev/CODE-MAP.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/CODE-MAP.md) L55, [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L271 (`turn-activity-browser.spec.ts` → `scene-diagnostics-browser.spec.ts`)

### 6) `navigation` — 파일 5 → 4 / 케이스 19 → 7 (-12) / 57.6s → 25.3s
- **[tests/organization-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/organization-browser.spec.ts)** (5 → 3)
  - **유지**: `ORG01`(2.3s, 폴더 삭제 시 채팅 보존 경계), `ORG02`(3.9s, 드래그 정렬 영속성), `PIN01`(2.4s, 대표 채팅 고정·해제)
  - **삭제 (2)**: `ORG05`(2.9s) — 메뉴 아이콘·제목 409 충돌 반복 / 보호: [tests/chat-title-api.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-title-api.test.ts); `ORG08`(1.6s) — 첫 행으로 서재/검색 열기 중복 / 보호: `PWUI01`, `SHORTCUT06`
- **[tests/sidebar-navigation-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/sidebar-navigation-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제 (2)**: `SIDENAV01` 412px(4.1s)·2560px(3.8s) — 같은 내비게이션을 2뷰포트로 반복하는 버튼 수/포커스 점검 / 보호: 타 스펙 전반의 사이드바 탐색
- **[tests/activity-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/activity-browser.spec.ts)** (5 → 1)
  - **유지**: `ACTUI06`(4.0s, 대표 활동함 페이징·일괄 확인 영속성)
  - **삭제 (4)**: `ACTUI04`(3.9s) — 경과 시간 문구(`[3-9]초`) 테스트 / 보호: 없음; `ACTUI17`(2.3s) — 채팅 복사 중복 / 보호: `P09`, [tests/chat-fork.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-fork.test.ts); `ACTUI18`(2.3s) — 최근 메뉴 문구·이름변경/삭제 중복 / 보호: `DEL03`, [tests/chat-title-api.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-title-api.test.ts); `ACTUI19`(1.4s) — 100% 목업 섹션 숨김/확인 / 보호: `ACTUI06`, [tests/activity-feed.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/activity-feed.test.ts)
- **[tests/side-panel-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/side-panel-browser.spec.ts)** (2 → 1)
  - **유지**: `SIDEPANEL01`(4.1s, 우측 패널 탭 전환 시 미저장 초안 보존)
  - **삭제**: `SIDEPANEL04`(3.0s) — 패널 리사이즈 시 스크롤 앵커 픽셀(`<= 2px`) 고정 / 보호: 없음(기하)
- **[tests/shortcuts-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/shortcuts-browser.spec.ts)** (5 → 2)
  - **유지**: `SHORTCUT06`(3.9s, 대표 커맨드 팔레트 키보드 흐름), `SHORTCUT08`(4.8s, 단축키 재지정 저장·초기화)
  - **삭제 (3)**: `SHORTCUT01`(3.1s) — `06`/`08`과 겹치는 기본 바인딩 열기 / 보호: `SHORTCUT06`/`08`; `SHORTCUT02`(2.2s) — IME 입력 보호 중복 / 보호: `chat-composer-browser`, [tests/shortcut-bindings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/shortcut-bindings.test.ts); `SHORTCUT03`(1.8s) — `Ctrl+S` 배선 / 보호: [tests/shortcut-bindings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/shortcut-bindings.test.ts)

### 7) `loading-and-sync` — 파일 5 → 4 / 케이스 11 → 6 (-5) / 40.7s → 22.6s
- **[tests/loading-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/loading-browser.spec.ts)** (6 → 3)
  - **유지**: `LOADUI01`(13.7s, 구간 페이징·딥링크·새로고침 위치 — 5절에서 시딩 단축 대상), `LOADUI04`(3.2s, 오프라인 재연결·SSE 델타), `LOADUI09`(1.6s, 늦은 빈 채팅 목록 응답 경합)
  - **삭제 (3)**: `LOADUI02`(3.6s) — `UI18 two-tab conflicts`와 완전 중복 / 보호: `UI18 two-tab`; `LOADUI10`(2.6s) — 상단 스크롤 픽셀 기하(`< 3px`) 고정 / 보호: 없음; `LOADUI08`(9.3s) — 8회 직렬 run으로 작업 기록 지연 로딩·분기 확인(다른 스펙과 중복) / 보호: `LOADUI01`, `P09`, `SCENEDIAG`
- **[tests/workspace-loading-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/workspace-loading-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `WORKLOAD`(1.1s) — 공유 `LoadingState` 503 재시도 중복 / 보호: `READERREC initial reader loading`
- **[tests/lazy-panels-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/lazy-panels-browser.spec.ts)** (1 → 1): `LAZY03`(1.9s, Vite 청크 로드 실패 격리·초안 보존) **유지**
- **[tests/live-events-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/live-events-browser.spec.ts)** (1 → 1): `LIVE01`(0.9s, 탭당 단일 SSE 연결 불변식) **유지**
- **[tests/browser-storage-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/browser-storage-browser.spec.ts)** (2 → 1)
  - **유지**: `STORE02`(1.1s, 채팅 삭제 시 브라우저 키 정리 경계)
  - **삭제**: `STORE01`(1.5s) — 기동 시 미등록 키 정리 / 보호: [tests/storage-keys.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/storage-keys.test.ts)

### 8) `library` — 파일 5 → 4 / 케이스 20 → 6 (-14) / 57.6s → 26.8s
- **[tests/library-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/library-browser.spec.ts)** (8 → 2)
  - **유지**: `LIBUI01`(6.2s, 폴더 이동·분류 시 리비전/채팅 보존), `LIBUI08`(2.8s, 수동 정렬·카드 드래그, `feature-map` `cases`)
  - **삭제 (6)**: `LIBUI03`(3.1s) — 프롬프트 폴더/이탈 중복 / 보호: `LIBUI01`, `LEAVE`; `EDITORRECOVERY2`(1.4s) — 공유 불확실 생성 멱등 / 보호: [tests/resource-create-retry.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/resource-create-retry.test.ts); `PROMPTOPEN`(2.1s) — 공유 늦은 읽기 취소 / 보호: [tests/resource-editor-session.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/resource-editor-session.test.ts); `LIBCLONE03`(1.6s) — 복제 후속 배치 분리 / 보호: [tests/resource-clone.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/resource-clone.test.ts); `LIBUI04`(2.3s) — 역할 선택으로 채팅 생성 중복 / 보호: `NSUI01`, [tests/library-organization.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/library-organization.test.ts); `LIBUI06`(2.1s) — 폴더 개요·개수·삭제 중복 / 보호: `LIBUI01`, `ORG01`
- **[tests/library-images-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/library-images-browser.spec.ts)** (3 → 1)
  - **유지**: `LIMG01`(2.7s, 대표 이미지 업로드·해제·재사용·1회 되돌리기)
  - **삭제 (2)**: `LIMG03`(1.5s) — 공유 업로드 취소/503 실패 반복 / 보호: `LIMG01`; `LIBCOVER`(1.9s) — 폴더 커버 장식 이미지 / 보호: [tests/library-organization.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/library-organization.test.ts)
- **[tests/library-usability-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/library-usability-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제 (2)**: `LUSE01`(1.7s) — 목록 보기·봇 생성→채팅 중복 / 보호: `LIBUI01`, `NSUI01`; `LUSE05`(2.2s) — 모듈 배경 CSS 스타일 적용 / 보호: [tests/risu-native-render.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-render.test.ts), `RSURFACE`
- **[tests/new-story-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/new-story-browser.spec.ts)** (6 → 2)
  - **유지**: `NSUI01`(4.6s, 대표 새 채팅·페르소나·첫 인사 무생성 진입), `NSUI10`(6.9s, 같은 채팅 내 첫 인사 교체·초안 보존)
  - **삭제 (4)**: `NSQ01`(2.7s) — 빠른 새 채팅이 `NSUI01`과 중복 / 보호: `NSUI01`; `NSQ03`(2.7s)·`NSQ05`(2.1s) — 공유 로드 취소/503·불확실 접수 반복 / 보호: `READERREC`, `run-retry`; `NSUI02`(3.5s) — raw JSON 초안 + `pointer-events: none` + 제거된 `package-fields` / 보호: `ui-recovery-browser`, `NSUI01`
- **[tests/bot-chat-import-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/bot-chat-import-browser.spec.ts)** (1 → 1): `BOTIMPORT01`(3.6s, 트랜스크립트/레거시 백업 가져오기·멱등성) **유지**

### 9) `deletion` — 파일 3 → 3 / 케이스 8 → 7 (-1) / 26.5s → 23.2s
- **[tests/deletion-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/deletion-browser.spec.ts)** (4 → 4): `DEL01`(3.4s), `DEL02`(5.5s), `DEL03`(1.7s), `DEL05`(3.0s) **전부 유지** (삭제 경계는 핵심 보존 기준)
- **[tests/scene-deletion-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/scene-deletion-browser.spec.ts)** (3 → 2)
  - **유지**: `SCENEDEL01`(3.1s, 단건 삭제/취소), `SCENEDEL02`(2.9s, 범위 삭제)
  - **삭제**: `SCENEDEL04`(3.3s) — 공유 응답 유실 후 새로고침 재확인 반복 / 보호: [tests/scene-deletion.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/scene-deletion.test.ts)
- **[tests/orphan-memory-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/orphan-memory-browser.spec.ts)** (1 → 1): `ORPHAN`(3.6s, 원본 DB 보존·수동 검토) **유지**

### 10) `resource-editors` — 파일 8 → 6 / 케이스 24 → 14 (-10) / 67.3s → 44.3s
- **[tests/editor-changes-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/editor-changes-browser.spec.ts)** (4 → 2)
  - **유지**: `EDIT01`(2.6s, 대표 변경 검토·이동), `EDIT03`(2.9s, 이전 저장 비교·복원·되돌리기)
  - **삭제 (2)**: `EDIT10`(1.8s) — 하단 저장 버튼이 헤더 저장과 같은 함수 호출 / 보호: `EDIT01`, `LEAVE`; `EDIT12`(2.7s) — 단건 되돌리기 / 보호: [tests/change-review.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/change-review.test.ts)
- **[tests/editor-frame-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/editor-frame-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제 (2)**: `EFRAME04`(1.7s) — 드롭 업로드·CSS `outlineStyle` 중복 / 보호: `LIMG01`; `EFRAME13`(2.4s) — 제거된 `'고급 설정'` count 0 + 탭 7개 순회 + raw JSON 차단 중복 / 보호: `ui-recovery-browser`, [tests/studio-sections.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/studio-sections.test.ts)
- **[tests/editor-leave-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/editor-leave-browser.spec.ts)** (4 → 3)
  - **유지**: `DECISION`(2.2s, 충돌 검토·IDB 실패), `LEAVE prompt-list 412px`(2.5s, 대표 이탈 저장 가드), `LEAVE multiple prompt roles`(3.0s, 다중 역할 초안 보호)
  - **삭제**: `LEAVE global-navigation 2560px`(2.7s) — 같은 `LEAVE` 흐름의 2번째 뷰포트 반복 / 보호: `LEAVE prompt-list 412px`
- **[tests/ui-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/ui-recovery-browser.spec.ts)** (3 → 3): `native toggle editor`(4.6s), `CHARX download`(4.8s), `RISUP download`(2.6s) **유지** *(5절에서 내부 `editorFits` 픽셀 체크와 무조건 스크린샷 12회 정리 권장)*
- **[tests/native-lore-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-lore-browser.spec.ts)** (2 → 1)
  - **유지**: `NATIVELORE01`(5.0s, 대표 로어북 폴더·삭제)
  - **삭제**: `NATIVELORE02`(1.9s) — 카드 로어 `keys` 배열·폴더 참조 매핑 / 보호: [tests/risu-native-lore.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-lore.test.ts), [tests/risu-native-lore-folders.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-lore-folders.test.ts)
- **[tests/native-editor-actions-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-editor-actions-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `NATIVEACTIONS`(2.0s) — 에셋 제거 확인·초안 유지 중복 / 보호: `LIMG01`
- **[tests/code-field-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/code-field-browser.spec.ts)** (4 → 3)
  - **유지**: `CODEFIELD02`(2.4s, CBS 정확 저장·CRLF 보존), `CODEFIELD03`(1.4s, 항목별 Undo 격리), `CODEFIELD04`(1.6s, CDP 한글 IME 조합 보호)
  - **삭제**: `CODEFIELD01`(3.7s) — `.cm-cbs-*` 클래스·진단 문구 고정 + 무조건 `output/editor-studio-4` 스크린샷 / 보호: [tests/cbs-analysis.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/cbs-analysis.test.ts), `CODEFIELD02`
- **[tests/cbs-references-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/cbs-references-browser.spec.ts)** (4 → 2)
  - **유지**: `CBSREF01`(3.1s, 변수 교차참조 이동·기본값 추가), `PREVIEW01`(5.5s, 첫 메시지 라이브 미리보기·Lua 오류 생존)
  - **삭제 (2)**: `CBSREF02`(2.0s) — 자동완성 팝업 중복 / 보호: `CBSREF01`, [tests/cbs-references.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/cbs-references.test.ts); `PREVIEW02`(2.0s) — `PREVIEW01`의 모바일 뷰포트 반복 / 보호: `PREVIEW01`
- *문서/`feature-map` 갱신*: [tests/feature-map.json](file:///C:/Users/wodus/ai-workspace/uimori/tests/feature-map.json) `cases`(`CODEFIELD02-04`, `CBSREF01`/`PREVIEW01`), [docs/dev/DEVELOPMENT.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/DEVELOPMENT.md) L158(`CODEFIELD01-04` → `CODEFIELD02-04`)

### 11) `risu` — 파일 6(+비공개 1) → 5(+비공개 1) / 케이스 21 → 8 (-13) / 54.5s → 23.3s
- **[tests/risu-import-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-import-browser.spec.ts)** (2 → 2): `RISUKINDUI02`(6.1s, CHARX), `RISUFORMATUI01`(2.3s, v3 PNG) **유지**
- **[tests/risu-preset-import-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-preset-import-browser.spec.ts)** (2 → 1)
  - **유지**: `RISUPRESETUI02`(3.5s, 실제 프리셋 가져오기→편집기)
  - **삭제**: `RISUPRESETUI03`(1.7s) — 목업 `/presentation` 표시/편집 분리(프리셋 가져오기와 무관) / 보호: [tests/risu-native-render.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-render.test.ts)
- **[tests/native-transfer-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-transfer-browser.spec.ts)** (2 → 1)
  - **유지**: `NATIVEUI03`(2.5s, `.risum` 단독 모듈 가져오기·내보내기 왕복)
  - **삭제**: `NATIVEUI01`(2.2s) — JSON 카드→새 채팅 중복 / 보호: `RISUKINDUI02`, `RISULUACOMPAT`
- **[tests/risu-lua-compat-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-lua-compat-browser.spec.ts)** (3 → 1)
  - **유지**: `RISULUACOMPAT 390px`(5.7s, 저작 폼→Lua→503 유실 멱등→새로고침)
  - **삭제 (2)**: `identical scenes retain separate uncertain actions`(4.5s), `terminal action receipt permits new explicit attempt`(5.8s) — 둘 다 전체 카드 UI 가져오기를 반복하며 같은 클라이언트 영수증 키 상태머신 분기 검증 / 보호: `RISULUACOMPAT 390px`, [tests/risu-native-runtime.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-runtime.test.ts), [tests/risu-native-host.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-host.test.ts)
- **[tests/risu-message-surface-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-message-surface-browser.spec.ts)** (3 → 2 + 이동 1 = 3)
  - **유지**: `RSURFACE 390px authored forms`(1.4s, DOM clobbering/XSS 보안 경계), `RSURFACE 390px reading/widgets/selection`(1.2s, 15개 시나리오) + 아래 파일에서 이동한 `RSURFACE authored CSS cannot apply html/body`(0.7s, CSS 격리 보안 경계)
  - **삭제**: `RSURFACE CLEANUP`(0.3s) — 단건 선택 격리 중복 / 보호: 15개 시나리오 러너
- **[tests/risu-native-frame-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-frame-browser.spec.ts)** (9 → 0, **파일 삭제**, `authored CSS` 0.7s만 이동)
  - **삭제 (8, 16.6s)**: `successful controls`(1.2s, `authored forms` 중복), `ruby/safe tags`(0.6s, `UI01`·[tests/reading-markdown.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-markdown.test.ts) 중복), `viewport projections`(3.2s, 사설 Vite 리사이즈 목업), 그리고 프리셋/정규식/로어/위치 사설 Vite 컴포넌트 테스트 5건(2.7s, 1.4s, 2.8s, 2.1s, 2.8s = 11.8s) / 보호: `ui-recovery-browser`, `NATIVELORE01`, [tests/native-risu-regex-editor.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-risu-regex-editor.test.ts), [tests/native-risu-toggle-editor.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-risu-toggle-editor.test.ts), [tests/studio-sections.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/studio-sections.test.ts)
- **[tests/risu-native-samples-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/risu-native-samples-browser.spec.ts)**: 비공개 로컬 opt-in **그대로 유지**
- *문서 포인터 갱신*: [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L249(`risu-native-frame-browser.spec.ts` 제거)

### 12) `prompts` — 파일 6 → 3 / 케이스 11 → 6 (-5) / 48.0s → 30.3s
- **[tests/prompt-workspace-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-workspace-browser.spec.ts)** (4 → 3)
  - **유지**: `PWS01`(`@smoke`, 2.9s), `PWS02`(`@smoke`, 5.8s), `PWS07`(`@smoke`, 2.7s)
  - **삭제**: `PWS03`(3.9s) — 자동 저장 실패·충돌 반복 / 보호: [tests/prompt-workspace-store.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-workspace-store.test.ts), `DECISION`
- **[tests/prompt-default-list-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-default-list-browser.spec.ts)** (1 → 0, **파일 삭제**): `PDEF01`(2.5s) — 기본 배지 토글·리비전 오류 / 보호: `PWS02`, `DEL02`, [tests/prompt-defaults.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-defaults.test.ts)
- **[tests/prompt-library-refinements-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-library-refinements-browser.spec.ts)** (1 → 0, **파일 삭제**): `PLR03`(3.8s) — 네이티브 프롬프트 생성·잘못된 정규식 초안 중복 / 보호: `ui-recovery-browser`, `BPTUI01`, `LEAVE`, [tests/native-risu-regex-editor.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/native-risu-regex-editor.test.ts)
- **[tests/prompt-order-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-order-browser.spec.ts)** (1 → 0, **파일 삭제**): `PORDER01`(3.7s) — 공유 `LibraryFolders` 정렬·폴더 이동 중복 / 보호: `LIBUI08`, `LIBUI01`
- **[tests/prompt-templates-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/prompt-templates-browser.spec.ts)** (1 → 1): `BPTUI01`(3.7s, 대표 내장 템플릿 생성 — 내부 2뷰포트 루프를 1뷰포트로 줄이기 권장) **유지**
- **[tests/global-models-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/global-models-browser.spec.ts)** (3 → 2)
  - **유지**: `GMUI01`(9.4s, 전역 모델 예약 동결·복원 계약, [docs/dev/DEVELOPMENT.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/DEVELOPMENT.md) L190), `GMUI02`(5.8s, 채팅 고정 모델/프롬프트·삭제 가드)
  - **삭제**: `JDGUI01`(3.7s) — 호환 판단 프로바이더 폼 저장 / 보호: [tests/judgment-provider-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/judgment-provider-settings.test.ts)
- *문서 포인터 갱신*: [docs/dev/CODE-MAP.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/CODE-MAP.md) L20(`prompt-default-list-browser.spec.ts` 제거)

### 13) `providers` — 파일 3 → 3 / 케이스 14 → 7 (-7) / 69.9s → 39.0s
- **[tests/provider-management-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/provider-management-browser.spec.ts)** (11 → 5; 현재 스위트 최장 54.8s → 29.0s)
  - **유지**: `PMUI01`(5.6s, 연결 등록·API 키 비노출·수동 모델), `PMUI02`(5.1s, 복제 검토·CAS 충돌, `DEVELOPMENT.md` L47), `PMUI08`(5.3s, Vertex 서비스계정 JSON 업로드·비밀키 비노출), `PMUI11`(6.0s, 프로바이더 옵션 왕복), `PMUI10`(7.1s, Codex 구독 로그인·세션 경계)
  - **삭제 (6)**: `PMUI07`(4.9s, 빠른 설정·초안 전환이 `PMUI01`/`SCUI02`와 중복), `PMUI14`(3.2s, 불확실 연결 테스트 멱등 — 보호: [tests/provider-connection-test.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/provider-connection-test.test.ts)), `PMLEAVE`(4.3s, 공유 이탈 저장 가드 — 보호: `SCUI02`/`LEAVE`), `SAVEACK`(4.3s, 다중 초안 503 저장 — 보호: `SETTINGSFLOW`), `PMUI model presets group/drag`(5.6s, 그룹 접기·드래그 정렬 — 보호: [tests/provider-management.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/provider-management.test.ts)), `PMUI Vertex location comparison`(3.6s, 9개 리전 100% 목업 테이블 — 보호: [tests/helper-vertex-location-tools.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-vertex-location-tools.test.ts), [tests/vertex-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/vertex-settings.test.ts))
  - *중요*: `model presets group/drag`를 지우면 [scripts/comment-allowlist.json](file:///C:/Users/wodus/ai-workspace/uimori/scripts/comment-allowlist.json) L58–61의 Playwright 드래그 주석 항목도 같이 지워야 `check-comments.mjs`가 통과해요.
- **[tests/jev-provider-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/jev-provider-browser.spec.ts)** (2 → 1)
  - **유지**: `JEVUI01`(4.6s, 서버 키 저장·삭제·비노출 자격 증명 경계)
  - **삭제**: `JEVUI03`(5.1s) — 100% 목업 `/jev/test` 재시도·문구 점검 / 보호: [tests/jev-provider.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/jev-provider.test.ts)
- **[tests/model-pricing-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/model-pricing-browser.spec.ts)** (1 → 1): `PRICEUI412`(5.3s, Flex/0원/미확인 단가 저장·복원, `PROVIDERS-AND-CODEX.md`) **유지**

### 14) `settings` — 파일 7 → 3 / 케이스 12 → 6 (-6) / 46.1s → 21.9s
- **[tests/settings-compact-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-compact-browser.spec.ts)** (4 → 2)
  - **유지**: `SCUI05`(3.3s, 전역 로어 기본값 저장·신규 채팅만 복사 경계), `SCUI02`(5.1s, 설정 뒤로가기/리사이즈/닫기 초안 보존)
  - **삭제 (2)**: `SCUI04`(8.1s) — 11개 탭을 순회하며 정적 제목·컨트롤·라이선스 문구 확인 / 보호: 각 기능 스펙, [tests/server.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/server.test.ts); `SCUILEAVE`(4.1s) — 공유 이탈 저장+503 반복 / 보호: `SETTINGSFLOW`, `LEAVE`
- **[tests/settings-dialog-consistency-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-dialog-consistency-browser.spec.ts)** (1 → 0, **파일 삭제**): `SDC01`(3.9s) — 테마 삭제 모달 포커스 트랩/Escape/배경클릭/503 반복 / 보호: `SCUI02`, `APPEARANCE`, `DEL01`
- **[tests/settings-polish-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-polish-browser.spec.ts)** (1 → 0, **파일 삭제**): `SPUI03`(3.5s) — 100% 목업 `/api/usage` JSON 포맷 문구 단언 / 보호: `PWUI04`(실제 루프백), [tests/usage-display.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/usage-display.test.ts), [tests/usage-report.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/usage-report.test.ts)
- **[tests/settings-save-decisions-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-save-decisions-browser.spec.ts)** (2 → 2): `SETTINGSFLOW`(2.2s, 부분 저장 후 실패 폼만 재시도), `DECISION`(2.0s, 옵션 409 충돌 검토·503 재시도) **유지**
- **[tests/settings-search-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-search-browser.spec.ts)** (1 → 0, **파일 삭제**): `SCUISEARCHCHAT`(2.0s) — 설정 검색 필터·`scrollWidth` / 보호: 초안 보존은 `SCUI02`
- **[tests/settings-sync-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/settings-sync-browser.spec.ts)** (2 → 2): `SETSYNC01`(4.3s), `SETSYNC02`(5.0s) **유지** (`APP-INVARIANTS.md` 핵심 불변식)
- **[tests/input-affordances-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/input-affordances-browser.spec.ts)** (1 → 0, **파일 삭제**): `INPUTUI02`(2.5s) — 드래그 vs 배경 클릭 light-dismiss 미세 동작 / 보호: 미저장 닫기 확인은 `SCUI02`
- *문서 포인터 갱신*: [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L336(`SPUI in tests/settings-polish-browser.spec.ts` → `PWUI04 in tests/personal-features-browser.spec.ts` / `tests/usage-display.test.ts`)

### 15) `appearance` — 파일 5 → 3 / 케이스 18 → 6 (-12) / 58.0s → 34.4s
- **[tests/themes-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/themes-browser.spec.ts)** (5 → 3)
  - **유지**: `THEMES 412 custom editor/export/import`(7.0s), `THEMES slot/CSS switches & #root hidden recovery`(4.8s, `Ctrl+.`·`?theme-safe=1` 복구 탈출구), `THEMES rejects leading executable markup`(1.3s, `<script>` 실행 차단 보안 경계)
  - **삭제 (2)**: `THEMES imported leading style`(1.6s) — CSS 적용 단언 / 보호: [tests/themes.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/themes.test.ts); `THEMES bot/chat inheritance & cross-tab`(3.8s) — 교차 탭 동기화·범위 상속 중복 / 보호: `SETSYNC02`, `BACKGROUND`, [tests/themes.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/themes.test.ts)
- **[tests/appearance-customization-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/appearance-customization-browser.spec.ts)** (2 → 2): `APPEARANCE 412 custom palette`(7.3s), `APPEARANCE uploaded font`(7.4s) **유지** (팔레트/글꼴 대표 흐름)
- **[tests/narrative-themes-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/narrative-themes-browser.spec.ts)** (3 → 1)
  - **유지**: `BACKGROUND upload, scopes, overlays, clear and reload`(6.5s, 배경 업로드·범위·오버레이 영속성)
  - **삭제 (2)**: `NARRATIVE cinematic 412 dark`(3.9s), `NARRATIVE classic-frame 1440 dark`(6.7s) — 2레이아웃×2뷰포트 루프로 CSS 속성(`border-radius`, `mask-image`, `object-fit`)·픽셀·휠 기하·중복 복사/편집 확인 / 보호: `BACKGROUND`, `THEMES`, `UI18`
- **[tests/theme-body-scroll-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/theme-body-scroll-browser.spec.ts)** (7 → 0, **파일 삭제**): 사설 `startFixtureVite` 중첩 스크롤 픽셀 기하(`<= 1px`, `scrollTop === 430`) 7건 / 보호: 없음(기하)
- **[tests/liquid-gallery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/liquid-gallery-browser.spec.ts)** (1 → 0, **파일 삭제**)
  - **삭제**: `GALLERY`(3.6s) — 3회 직렬 run으로 사용자 테마+`Ctrl+.` 토글 반복 / 보호: `THEMES slot/CSS switches`, `BACKGROUND`
  - *(참고: 파일 하단의 `UIMORI_BENCHMARK=1` 전용 `PERF` 벤치마크가 필요하면 `*.spec.ts` 밖인 `tests/liquid-gallery-benchmark.manual.ts`로 빼거나, `npm run benchmark:story`·`scripts/benchmark-presentation.mjs`로 대체하고 정리하면 `feature-map`에 0케이스 파일이 남지 않아요.)*
- *문서 포인터 갱신*: [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L328, [docs/dev/DEVELOPMENT.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/DEVELOPMENT.md) L208–216

### 16) `story-ui` — 파일 3 → 3 / 케이스 9 → 5 (-4) / 28.7s → 13.8s
- **[tests/story-ui-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-browser.spec.ts)** (5 → 3)
  - **유지**: `bound image lists without fetching external URLs`(3.1s, 외부 URL 차단 보안), `switches original and translated UI`(2.1s, 입력 초안 보존), `block CSS stays inside & loads nothing remote`(2.1s, CSS 샌드박스·원격 차단 보안)
  - **삭제 (2)**: `completed streamed UI remains visible`(2.6s) — 목업 `/preview` 렌더 확인 / 보호: `STORYUI generated source`, [tests/story-ui-reading.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-reading.test.ts); `shows a placeholder and cause of failed block`(5.0s) — 자리표시자·오류 진단 문구(`변환 오류`, `muted`) 고정 / 보호: [tests/story-ui-reading.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-reading.test.ts), [tests/story-ui.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui.test.ts)
- **[tests/story-ui-settings-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-settings-browser.spec.ts)** (3 → 1)
  - **유지**: `STORYUI generated source renders & submits short continuation`(2.8s, 대표 실제 앱 E2E)
  - **삭제 (2)**: `STORYUI settings persist`(2.4s) — 스위치+셀렉트 1쌍 저장 / 보호: `SETTINGSFLOW`, [tests/chat-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/chat-settings.test.ts); `STORYUI status tab pinned block`(4.9s) — 3회 직렬 run으로 스크롤에 따른 `현황` 탭 배경색·`HP 10`/`HP 4` 확인 / 보호: [tests/story-ui-pins.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-pins.test.ts)
- **[tests/story-ui-theme-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/story-ui-theme-browser.spec.ts)** (1 → 1): `bot Story UI theme`(3.7s, 대표 이야기 UI 커스텀 테마·CSS 격리) **유지**

### 17) `illustration` — 파일 2 → 2 / 케이스 8 → 5 (-3) / 28.8s → 21.4s
- **[tests/illustration-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-browser.spec.ts)** (7 → 4)
  - **유지**: `ILUI01`(3.3s, 대표 요청·표시·재시도·삭제), `ILUI-DIRECTION manual/redraw`(3.1s, 연출/다시그리기 초안 보존·재생성), `ILUI04`(5.5s, 스토리보드 영속 + 삽화 중 다음 채팅 비차단 동시성 경계), `ILLUSTRATION-PROFILES`(4.2s, 봇 기본 외형 저장·신규 채팅 상속)
  - **삭제 (3)**: `character profiles 360px`(2.5s) — 채팅 인물 외형·충돌 검토 중복 / 보호: `ILLUSTRATION-PROFILES`, `DECISION`, [tests/illustration-profiles.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-profiles.test.ts); `ILUI-DIRECTION blocked illustration`(1.6s) — 목업 `ILLUSTRATION_CODEX_CONTENT_BLOCKED`로 같은 다시그리기 대화상자 열기 / 보호: `ILUI-DIRECTION`, [tests/illustration-retry.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-retry.test.ts); `ILUI02`(3.3s) — 전역 삽화 설정 CAS/503 재로드 반복 / 보호: `DECISION`, `PMUI02`, [tests/illustration-api.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-api.test.ts)
- **[tests/illustration-presets-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-presets-browser.spec.ts)** (1 → 1): `IPUI01`(5.4s, 프리셋 CRUD·범위·민감정보 제거 내보내기/가져오기) **유지**

### 18) `translation` — 파일 3 → 3 / 케이스 7 → 5 (-2) / 17.3s → 14.0s
- **[tests/input-translation-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/input-translation-browser.spec.ts)** (5 → 3)
  - **유지**: `ITRAN 412`(3.0s, 대표 번역·되돌리기·새로고침·전송·요청복사), `ITRAN typing cannot be overwritten`(1.3s, 지연 번역 경합), `ITRAN send intent invalidates`(1.3s, 전송 직후 다음 초안 보호)
  - **삭제 (2)**: `ITRAN refused/rejected`(1.7s) — 422/400 실패 초안 유지 반복 / 보호: `ITRAN 412`, `run-retry`, [tests/input-translation.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/input-translation.test.ts); `ICOPY`(1.5s) — 목업 `/presentation` 요청 복사 중복 / 보호: `ITRAN 412`
- **[tests/translation-guides-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/translation-guides-browser.spec.ts)** (1 → 1): `TGUIDE 412`(3.8s, 대표 번역 지침·IDB 복구·원문 JSON) **유지**
- **[tests/auxiliary-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/auxiliary-recovery-browser.spec.ts)** (1 → 1): `AUXREC`(4.7s, **5중 중복 번역 실패 재시도의 유일한 대표 케이스**) **유지**

### 19) `outline` — 파일 1 → 1 / 케이스 6 → 2 (-4) / 20.1s → 7.8s
- **[tests/outline-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/outline-browser.spec.ts)** (6 → 2)
  - **유지**: `OUTUI05`(2.0s, 플롯→도우미 인계·자동 실행 금지·초안 보존), `OUTUI08`(5.8s, 대표 플롯 집필·포커스 이어쓰기·수정/이동·삭제 확인)
  - **삭제 (4)**: `OUTUI02`(4.1s) — `OUTUI08`과 집필/이어쓰기 중첩 / 보호: `OUTUI08`, [tests/outline.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/outline.test.ts); `OUTUI07`(2.2s) — 공유 충돌 초안 보존 반복 / 보호: `DECISION`, [tests/outline.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/outline.test.ts); `OUTUI03`(2.4s)·`OUTUI04`(3.5s) — 공유 유실 응답 멱등 확인 반복 / 보호: `READERREC`, `run-retry`, [tests/outline.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/outline.test.ts)

### 20) `helper` — 파일 11 → 10 / 케이스 33 → 19 (-14) / 117.7s → 79.2s
*(Wave 1에서 이미 정리된 4개 파일은 중복 3건만 추가 정리하고, 손대지 않았던 나머지 7개 파일에서 11건을 걷어냈어요.)*
- **[tests/helper-flow-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-flow-browser.spec.ts)** (4 → 3)
  - **유지**: `HELPSTEER`(3.6s), `HELPUI07`(6.9s, `chat-unification`), `HELPUI05`(5.6s, `chat-unification`)
  - **삭제**: `HELPACTIVITY`(3.2s) — 100% 목업 단계 문구·횟수(`2회`)·오류 문자열 확인 / 보호: [tests/helper-activity.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-activity.test.ts), [tests/helper-activity-groups.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-activity-groups.test.ts)
- **[tests/helper-safety-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-safety-browser.spec.ts)** (3 → 3): `HPLAN01`(1.3s), `HCONFIRM01`(4.2s), `HROLLBACK03`(3.4s) **전부 유지** (읽기 전용/삭제·유료 승인/롤백 안전 경계)
- **[tests/helper-editor-bridge-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-editor-bridge-browser.spec.ts)** (3 → 3): `EHELP01`(4.9s), `EHELP09`(3.1s), `HELPASK01`(2.1s) **전부 유지**
- **[tests/helper-composer-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-composer-browser.spec.ts)** (4 → 2)
  - **유지**: `HELPMESSAGE`(10.0s, 과거 메시지 편집·충돌·쌍/이후 삭제 경계), `HELPUI04`(3.2s, 선택 원문 동결, `chat-unification`)
  - **삭제 (2)**: `HELPSENDKEY`(2.8s) — 공유 컴포저 IME 조합 가드 중복 / 보호: `chat-composer-browser`; `HELPMODEL`(2.0s) — 모델 선택 409/유실 재읽기 중복 / 보호: `MP01`, [tests/helper-workspace.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-workspace.test.ts)
- **[tests/helper-attachments-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-attachments-browser.spec.ts)** (2 → 1)
  - **유지**: `HATT01`(4.6s, 대표 이미지+텍스트 첨부·저장 메타데이터·다운로드)
  - **삭제**: `HATT02`(4.6s) — 붙여넣기/드롭 초안·미지원 모델 거절 중복 / 보호: `HATT01`, `HSESSION01`, [tests/helper-attachment-draft.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-attachment-draft.test.ts), [tests/helper-attachments.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-attachments.test.ts)
- **[tests/helper-live-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-live-browser.spec.ts)** (1 → 1): `HELPLIVE03`(3.1s, 서재 도우미 SSE 끊김→커서 폴링 폴백) **유지**
- **[tests/helper-message-prose-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-message-prose-browser.spec.ts)** (1 → 0, **파일 삭제**): `HCODE01`(2.8s) — 사설 `startFixtureVite` 코드 블록 복사 버튼 위젯 테스트 / 보호: 없음(단순 복사 버튼)
- **[tests/helper-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-recovery-browser.spec.ts)** (2 → 1)
  - **유지**: `HELPREC01`(4.4s, 실제 IDB 읽기/쓰기 오류 초안 복구)
  - **삭제**: `HELPHANDOFF01`(2.5s) — 지연 인계와 수동 세션 전환 경합 중복 / 보호: `HELPUI07`, [tests/helper-recovery.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-recovery.test.ts)
- **[tests/helper-sessions-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-sessions-browser.spec.ts)** (2 → 1)
  - **유지**: `HSESSION01`(2.8s, 대표 세션 생성/전환/이름변경/삭제 격리, `chat-unification`)
  - **삭제**: `HSESSION03`(1.7s) — 지연 세션 생성 경합 중복 / 보호: `HELPUI07`, [tests/helper-workspace.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-workspace.test.ts)
- **[tests/helper-task-results-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-task-results-browser.spec.ts)** (5 → 2)
  - **유지**: `HCHANGE03`(5.2s, 변경 카드→장면 문단/로어 이동·미저장 초안 유지), `HUSAGE02 HUSAGE03` 통합(4.1s — `HUSAGE03`에서 API `POST .../compact` 대신 팝오버 `지금 대화 정리하기` 버튼 클릭으로 시작하면 1케이스로 수동 정리+요약 편집/충돌/초기화를 모두 커버하고 `HELPER-TOOLS.md`의 두 ID 포인터도 그대로 유지돼요!)
  - **삭제 (3)**: `appearance result opens characters`(2.9s) — 단일 결과 링크 열기 / 보호: `HCHANGE03`, [tests/helper-tool-contracts.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-tool-contracts.test.ts); `HCHANGE01`(2.1s) — 100% 목업 `/results` diff `<del>`/`<ins>` 문구 단언 / 보호: [tests/helper-task-results-ui.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-task-results-ui.test.ts), [tests/helper-changes.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-changes.test.ts); `HUSAGE02`(1.9s, `HUSAGE03`에 통합)
- **[tests/helper-workspace-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-workspace-browser.spec.ts)** (6 → 2)
  - **유지**: `HSPACE12`(2.9s, 미확인 활동 읽음 상태 영속), `HSPACE06`(3.9s, 대표 도우미 사이드바·프로젝트 생성/이동/이름변경/삭제·대화 복사·초안 보존)
  - **삭제 (4)**: `HSPACE11`(4.5s) — 프로젝트 드래그/키보드 정렬이 `HSPACE06`·`ORG02`와 중복 / 보호: `HSPACE06`, [tests/helper-navigation.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-navigation.test.ts), [tests/helper-navigation-ui.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-navigation-ui.test.ts); `HSPACE03`(2.3s) — 실패 진단 버튼의 고정 초안 문구 프리필 / 보호: 없음(문구); `HSPACE07`(2.7s) — 공유 `sessionStorage` 409/abort 멱등 재시도 반복 / 보호: `HELPSTEER`, `HELPUI05`, [tests/helper-pending-request.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/helper-pending-request.test.ts); `HSPACE02`(2.6s) — 도우미 확대 시 미저장 편집기 유지·전송 중복 / 보호: `EHELP09`, `HELPUI07`
- *문서 포인터 갱신*: [docs/dev/APP-INVARIANTS.md](file:///C:/Users/wodus/ai-workspace/uimori/docs/dev/APP-INVARIANTS.md) L115(`HCHANGE01` → `tests/helper-task-results-ui.test.ts`)

### 21) `personal-workspace` — 파일 4 → 3 / 케이스 14 → 10 (-4) / 54.1s → 40.8s
- **[tests/personal-workspace-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/personal-workspace-browser.spec.ts)** (5 → 3)
  - **유지**: `PERSONAL chat backup`(3.2s, 손상 백업 거절·독립 복원), `PERSONAL two-tab IDB recovery`(5.3s, 타 탭 저장 시 내 탭 미저장 IDB 초안 보존), `PERSONAL binary .uimori archive`(2.4s, `.uimori` 백업 다운로드→가져오기 왕복)
  - **삭제 (2)**: `PERSONAL ordinary save/raw JSON/IDB`(4.9s) — 일반 편집·raw JSON·IDB 복구 중복 / 보호: `ui-recovery-browser`, `TGUIDE`, `PERSONAL two-tab IDB`; `PERSONAL direct API key LAN`(2.7s) — API 키 저장·비노출 중복 / 보호: `PMUI01`, [tests/provider-connection-settings.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/provider-connection-settings.test.ts)
- **[tests/personal-features-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/personal-features-browser.spec.ts)** (5 → 5): `PWUI01`(4.7s, 원고 검색), `PWUI02`(7.6s, 서버 자동 백업·SQLite 다운로드), `PWUI03`(5.3s, 교차 기기 읽기 위치·책갈피), `PWUI04`(3.1s, 실제 루프백 사용량·CSV), `PWUI05`(2.8s, 무캐시 SW·PWA 설치) **전부 유지** *(5절에서 `PWUI01`/`02` 내부 픽셀·다중뷰포트 스크린샷 루프 축소 권장)*
- **[tests/bookmark-confirmations-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/bookmark-confirmations-browser.spec.ts)** (2 → 0, **파일 삭제**)
  - **삭제 (2)**: `BMCONF01`(3.4s)·`BMCONF03`(2.2s) — 공유 모달 Escape/배경클릭/포커스/409 삭제 확인 반복 / 보호: `PWUI03`, `SCUI02`, `DEL01`, [tests/reading-state.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/reading-state.test.ts)
- **[tests/push-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/push-browser.spec.ts)** (2 → 2): `PWUI06`(3.8s, 푸시 동의·구독 해제 실패 시 서버 해제 유지), `PWUI07`(2.6s, SW 알림 이동 시 편집기 초안 보호) **유지**

### 22) `i18n` — 파일 1 → 1 / 케이스 4 → 3 (-1) / 5.4s → 4.5s
- **[tests/i18n-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/i18n-browser.spec.ts)** (4 → 3)
  - **유지**: `I18N07`(0.9s, 재시작된 SW가 IDB 로케일 읽기 — 브라우저 필수), `I18N08`(1.6s, 언어 전환 중 미저장 편집·선택범위 보존), `I18N01`(2.1s, 대표 언어 선택 영속성)
  - **삭제**: `I18N06`(0.9s) — 매니페스트 href 전환·읽기 언어 독립 확인 / 보호: [tests/pwa.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/pwa.test.ts), [tests/i18n.test.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/i18n.test.ts)

### 23) `self-host` — 파일 1 → 1 / 케이스 3 → 3 (0) / 별도 러너
- **[tests/self-host-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/self-host-browser.spec.ts)**: `SHUI01`, `SHUI02`, `SHUI03` **전부 유지** (자격 증명·HTTPS 세션·Origin/CSRF·세션 폐기 경계)

---

## 2. 목표 케이스 수와 예상 실행 시간 감소

| 도메인 (`verify -- all`) | 스펙 파일 | 런타임 케이스 | 실측 `sumDur` (전 → 후) |
| --- | ---: | ---: | ---: |
| `reader` | 10 → 7 | 42 → 18 (-24) | 108.5s → 50.9s |
| `chat-generation` | 10 → 10 | 32 → 15 (-17) | 104.7s → 53.0s |
| `chat-settings` | 6 → 5 | 12 → 6 (-6) | 38.7s → 19.1s |
| `context` | 2 → 2 | 4 → 3 (-1) | 13.4s → 9.0s |
| `turn-activity` | 3 → 1 | 4 → 1 (-3) | 11.9s → 4.5s |
| `navigation` | 5 → 4 | 19 → 7 (-12) | 57.6s → 25.3s |
| `loading-and-sync` | 5 → 4 | 11 → 6 (-5) | 40.7s → 22.6s |
| `library` | 5 → 4 | 20 → 6 (-14) | 57.6s → 26.8s |
| `deletion` | 3 → 3 | 8 → 7 (-1) | 26.5s → 23.2s |
| `resource-editors` | 8 → 6 | 24 → 14 (-10) | 67.3s → 44.3s |
| `risu` *(비공개 1 제외)* | 6 → 5 | 21 → 8 (-13) | 54.5s → 23.3s |
| `prompts` | 6 → 3 | 11 → 6 (-5) | 48.0s → 30.3s |
| `providers` | 3 → 3 | 14 → 7 (-7) | 69.9s → 39.0s |
| `settings` | 7 → 3 | 12 → 6 (-6) | 46.1s → 21.9s |
| `appearance` | 5 → 3 | 18 → 6 (-12) | 58.0s → 34.4s |
| `story-ui` | 3 → 3 | 9 → 5 (-4) | 28.7s → 13.8s |
| `illustration` | 2 → 2 | 8 → 5 (-3) | 28.8s → 21.4s |
| `translation` | 3 → 3 | 7 → 5 (-2) | 17.3s → 14.0s |
| `outline` | 1 → 1 | 6 → 2 (-4) | 20.1s → 7.8s |
| `helper` | 11 → 10 | 33 → 19 (-14) | 117.7s → 79.2s |
| `personal-workspace` | 4 → 3 | 14 → 10 (-4) | 54.1s → 40.8s |
| `i18n` | 1 → 1 | 4 → 3 (-1) | 5.4s → 4.5s |
| **합계 (`verify -- all`)** | **109 → 86 (-23)** | **333 → 165 (-168, -50.5%)** | **1,075.6s → 609.3s (-43.4%)** |

- **실측 기준선 (`0b41f164`, `workers=8`)**: Playwright 벽시계 **175.8초** (서버 기동·정리 포함 총 179.5초), 실효 병렬화 배수 `1,075.6 / 175.8 = 6.12배`.
- **다이어트 후 예상 벽시계 시간 (추정)**:
  - 케이스 삭제만 적용: `609.3 / 6.12 ≈ 100초` + 하네스 고정 오버헤드 감안 → **약 100~110초 (약 65~75초 단축, -37~43% 추정)**.
  - 케이스가 50.5% 줄었는데 시간이 ~40%만 줄어드는 이유: 지운 케이스는 평균 2.8초짜리 가벼운 검증이 많고 남긴 케이스는 백업·복원·2탭 충돌·Risu 왕복 등 평균 3.7초짜리 핵심 흐름이기 때문이에요. 다만 사설 `startFixtureVite` 파일이 **7개 중 5개 삭제**되므로 부하 시 CPU/메모리 경합과 흔들림(flake)은 시간 감소율 이상으로 줄어들어요.
  - 5절의 내부 정리(무조건 스크린샷 게이팅 + `LOADUI01` 시딩 교체 + `provider-management` 분할)까지 함께 적용하면 **약 85~95초(추정)**까지 내려갈 여지가 있어요.

---

## 3. 유닛 분할 (8개 유닛, 순서·`--allow` 글롭·검증)

모든 유닛은 `npm run check:unit-diff -- --base <직전 커밋> --allow <글롭>... --allow-test-removal`로 검사하고, 문서 포인터·`feature-map.json`·주석 허용 목록을 **같은 유닛 커밋 안에서 함께 갱신**해 매 커밋마다 `check-documentation.mjs`와 프리셋(`browser-smoke`, `chat-unification`, `READERREC`)이 깨지지 않게 설계했어요. *(참고: 삭제한 스펙 전용 `tests/fixtures/*` 파일까지 함께 정리할 경우 해당 유닛에 `--allow 'tests/fixtures/<파일>'`를 추가하면 돼요.)*

| 순서 | 대상 도메인 | 변화 (파일 / 케이스 / `sumDur`) | `--allow` 글롭 목록 | 유닛 검증 명령 |
| :---: | --- | --- | --- | --- |
| **1** | `turn-activity`, `context`, `outline`, `i18n` | -2 / -9 / -24.9s | `tests/turn-activity-browser.spec.ts`, `tests/task-trace-browser.spec.ts`, `tests/context-browser.spec.ts`, `tests/outline-browser.spec.ts`, `tests/i18n-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/CODE-MAP.md`, `docs/dev/APP-INVARIANTS.md` | `node scripts/check-documentation.mjs && npm run verify -- turn-activity context outline i18n` |
| **2** | `settings`, `chat-settings`, `providers` | -5 / -19 / -74.8s | `tests/settings-*-browser.spec.ts`, `tests/input-affordances-browser.spec.ts`, `tests/chat-settings-browser.spec.ts`, `tests/chat-option-recovery-browser.spec.ts`, `tests/model-picker-browser.spec.ts`, `tests/evaluation-browser.spec.ts`, `tests/provider-management-browser.spec.ts`, `tests/jev-provider-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/APP-INVARIANTS.md`, `scripts/comment-allowlist.json` | `node scripts/check-documentation.mjs && node scripts/check-comments.mjs && npm run verify -- settings chat-settings providers` |
| **3** | `appearance`, `story-ui`, `illustration` | -2 / -19 / -45.8s | `tests/themes-browser.spec.ts`, `tests/narrative-themes-browser.spec.ts`, `tests/theme-body-scroll-browser.spec.ts`, `tests/liquid-gallery-browser.spec.ts`, `tests/story-ui-browser.spec.ts`, `tests/story-ui-settings-browser.spec.ts`, `tests/illustration-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/APP-INVARIANTS.md`, `docs/dev/DEVELOPMENT.md` | `node scripts/check-documentation.mjs && npm run verify -- appearance story-ui illustration` |
| **4** | `library`, `prompts`, `deletion`, `personal-workspace` | -5 / -24 / -65.1s | `tests/library-*-browser.spec.ts`, `tests/new-story-browser.spec.ts`, `tests/prompt-*-browser.spec.ts`, `tests/global-models-browser.spec.ts`, `tests/scene-deletion-browser.spec.ts`, `tests/personal-workspace-browser.spec.ts`, `tests/bookmark-confirmations-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/CODE-MAP.md` | `node scripts/check-documentation.mjs && npm run verify -- library prompts deletion personal-workspace && npm run verify -- browser-smoke` |
| **5** | `resource-editors`, `risu` | -3 / -23 / -54.2s | `tests/editor-*-browser.spec.ts`, `tests/native-*-browser.spec.ts`, `tests/code-field-browser.spec.ts`, `tests/cbs-references-browser.spec.ts`, `tests/risu-*-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/DEVELOPMENT.md`, `docs/dev/APP-INVARIANTS.md` | `node scripts/check-documentation.mjs && npm run verify -- resource-editors risu` |
| **6** | `reader`, `translation`, `loading-and-sync` | -4 / -31 / -79.0s | `tests/ui-browser.spec.ts`, `tests/reading-*-browser.spec.ts`, `tests/reader-*-browser.spec.ts`, `tests/source-edit-focus-browser.spec.ts`, `tests/input-translation-browser.spec.ts`, `tests/loading-browser.spec.ts`, `tests/workspace-loading-browser.spec.ts`, `tests/browser-storage-browser.spec.ts`, `tests/reader-sync.test.ts`, `tests/feature-map.json`, `docs/dev/APP-INVARIANTS.md` | `node scripts/check-documentation.mjs && npm test -- tests/reader-sync.test.ts && npm run verify -- reader translation loading-and-sync && npm run verify -- all --grep READERREC` |
| **7** | `chat-generation`, `navigation` *(+ 큐 가드 Vitest 이관)* | -1 / -29 / -84.0s | `tests/product-browser.spec.ts`, `tests/browser.spec.ts`, `tests/composer-next-request-browser.spec.ts`, `tests/request-images-browser.spec.ts`, `tests/response-actions-browser.spec.ts`, `tests/response-stream-browser.spec.ts`, `tests/organization-browser.spec.ts`, `tests/sidebar-navigation-browser.spec.ts`, `tests/activity-browser.spec.ts`, `tests/side-panel-browser.spec.ts`, `tests/shortcuts-browser.spec.ts`, `tests/composer-draft.test.ts`, `tests/feature-map.json` | `node scripts/check-documentation.mjs && npm test -- tests/composer-draft.test.ts && npm run verify -- chat-generation navigation && npm run verify -- browser-smoke` |
| **8** | `helper` | -1 / -14 / -38.5s | `tests/helper-*-browser.spec.ts`, `tests/feature-map.json`, `docs/dev/APP-INVARIANTS.md` | `node scripts/check-documentation.mjs && npm run verify -- helper && npm run verify -- chat-unification` |

- **웨이브 종료 게이트**:
  ```powershell
  node scripts/check-documentation.mjs && node scripts/check-comments.mjs && npm run verify -- browser-smoke && npm run verify -- chat-unification && npm run verify -- all --grep READERREC && npm run verify -- all
  ```

---

## 4. 지웠을 때 실제로 놓칠 수 있는 결함 종류 (위험)

1. **스크롤 앵커·레이아웃 기하 회귀**: `theme-body-scroll`, `reading-markdown`, `reader-navigation`, `NARRATIVE`, `SIDEPANEL04`, `STREAMFOLLOW`, `LOADUI10`, `RSEL22`를 지우면 내러티브 중첩 스크롤 튐, 리사이즈/본문 증가 시 읽기 위치 밀림, 모바일 터치 선택 바 겹침 같은 1~30px 기하 버그가 자동 스위트에서 걸러지지 않아요. (`npm run verify -- gallery` 시각 리뷰와 실사용으로 감수하는 트레이드오프)
2. **공유 저장/충돌/멱등 메커니즘의 개별 폼 배선 누락**: `SCUILEAVE`, `OPTIONREVIEW2`, `MP02`, `PMLEAVE`, `SAVEACK`, `OUTUI03/04`, `SCENEDEL04`, `HSPACE07`, `LIMG03` 등을 대표 1~2곳만 남기면, 공유 메커니즘 자체는 살아있어도 특정 폼 하나가 `expectedRevision`이나 idempotency 키 전달을 실수로 빠뜨릴 때 브라우저에서 바로 못 잡을 수 있어요. (서버 API 계약은 Vitest가 잡지만 프론트 폼 바인딩은 남는 위험)
3. **모달 닫힘·포커스 복귀·키보드 세부 접근성**: `SDC01`, `BMCONF01/03`, `INPUTUI02`, `SIDENAV01`, `SHORTCUT01/03`을 걷어내면 특정 모달의 `Escape`/배경 클릭/드래그 오작동이나 닫은 뒤 트리거 포커스 복귀가 깨질 수 있어요.
4. **반응형 폭 전용 UI 깨짐**: `PREVIEW02`, `LEAVE 2560px`, `SIDENAV01 412/2560`, `NARRATIVE 412/1440` 같은 뷰포트 중복을 지우면 특정 화면 폭에서만 가로 스크롤이 생기거나 모바일/데스크톱 분기가 어긋나는 결함이 통과할 수 있어요.
5. **표시·진단 UI의 JSX 바인딩 회귀**: `SPUI03`, `TRACE01`, `TURNUI06/DISPLAY`, `HELPACTIVITY`, `HCHANGE01`, `ACTUI04/19`를 지우면 데이터 계산 로직은 Vitest가 지켜도, React 컴포넌트가 특정 상태(예: `미확인`/`부분 추정`/`삭제됨` 배지, `<del>`/`<ins>` 스크린리더 라벨)를 빠뜨려 렌더링하는 회귀를 놓칠 수 있어요.
6. **클라이언트 예약 요청 가드(`QUEUE02/05/07/09/10`) 미이관 시 유료 오발송 위험**: Unit 7에서 순수 가드 함수를 Vitest로 옮기지 않고 브라우저 5건만 지우면, 설정 변경·실패·다른 탭 진행 중에 예약된 요청이 의도치 않게 자동 전송될 위험이 생겨요. *(그래서 Unit 7에 Vitest 이관을 명시해 두었어요.)*

---

## 5. 범위 밖 과감한 구조 개선 제안

이번에 전체 스펙을 읽으면서 보인, 단순 케이스 삭제보다 더 큰 체감 효과를 낼 수 있는 스위트 구조 개선점들이에요. (Wave 2 말미나 Wave 3에 얹으면 좋아요.)

1. **무조건 `.screenshot()` 103회(40개 파일)를 `visualReview` 뒤로 숨기기 + 하드코딩 `output/*.png` 제거**
   - 현재 40개 브라우저 스펙에서 `visualReview` 가드 없이 `page.screenshot()`을 **103회** 호출하고 있어요([tests/ui-recovery-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/ui-recovery-browser.spec.ts) 12회, [tests/personal-features-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/personal-features-browser.spec.ts) 11회, [tests/illustration-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/illustration-browser.spec.ts) 9회, [tests/narrative-themes-browser.spec.ts](file:///C:/Users/wodus/ai-workspace/uimori/tests/narrative-themes-browser.spec.ts) 6회 등). 게다가 `editor-changes`, `story-ui-settings`, `story-ui-theme`, `code-field`는 `info.outputPath()`도 아닌 루트 `output/`에 직접 PNG를 덮어써요. `visualReview`로 감싸기만 해도 매 실행마다 불필요한 풀페이지 페인트·디스크 I/O가 사라져요.
2. **직렬 `POST /runs` 시딩을 `POST /api/chats/import-transcript`로 치환**
   - 생성 파이프라인이 목적이 아닌데도 시딩용으로 `/runs`를 직렬 폴링하는 스펙들이 가장 무거워요. 대표적으로 `LOADUI01`(13.7s, 12회 직렬 run)과 `PWUI03`(5.3s, 8장면)을 `import-transcript` 1회 호출로 바꾸면 `LOADUI01` 하나만으로도 8~10초(추정) 줄일 수 있어요.
3. **다이어트 후 남는 최장 직렬 폴(Long Pole) 해체**
   - 165건으로 줄인 뒤 상위 직렬 파일은 `provider-management-browser.spec.ts`(29.0s), `personal-features-browser.spec.ts`(23.5s), `ui-browser.spec.ts`(21.2s), `loading-browser.spec.ts`(18.5s)예요.
   - `provider-management`를 2개 파일(핵심 CRUD/옵션 vs Vertex/Codex 자격 증명)로 쪼개고, `UI01`(12.2s) 내부의 2뷰포트×3스크롤 루프·`PWUI02`(7.6s) 내부의 2뷰포트×3닫기+정중앙 픽셀 루프·`BPTUI01` 내부 2뷰포트 루프를 1뷰포트로 걷어내면 8워커 꼬리 시간이 크게 내려가요.
4. **스펙 파일 수 통폐합(86개 → ~35~45개) + Wave 3 연동**
   - 다이어트 후에도 1~2케이스짜리 소형 스펙 파일이 40개 넘게 남아요. 파일마다 Playwright 워커 초기화·모듈 로딩 비용이 드는데, 15초 이상 파일만 분리하고 같은 도메인의 1~2케이스짜리 파일들을 도메인당 1~3개 파일로 합치면 파일 관리·`feature-map.json` 유지·Wave 3 변경 분류기 매핑이 훨씬 단순해져요.
5. **남은 사설 `startFixtureVite` 2개(`story-ui-browser`, `risu-message-surface`) 정리**
   - 이번 웨이브에서 사설 Vite 파일 7개 중 5개가 없어지고 둘만 남는데, 특히 `story-ui-browser.spec.ts`는 `@a2ui/react`·`zod` 번들링 때문에 `beforeAll` 비용이 커요. 이미 `dist`를 빌드한 뒤 브라우저 검증을 돌리므로, 이 둘을 실제 빌드 번들이나 단일 공용 fixture 페이지로 통합하면 워커당 Vite 프로세스 기동·메모리 스파이크를 완전히 없앨 수 있어요.
6. **`chat-unification` 프리셋과 `test()` 내부 4중 상태머신 구조 정리 (Wave 3 검토)**
   - [tests/feature-map.json](file:///C:/Users/wodus/ai-workspace/uimori/tests/feature-map.json)의 `chat-unification` 프리셋은 과거 통합 작업용 임시 묶음인데, 실제로는 `loading-browser.spec.ts`가 `grep`에 하나도 안 걸리는 등 낡아 있어요. Wave 3에서 `verify` 인터페이스를 다듬을 때 `browser-smoke` 중심으로 프리셋을 단순화할지 함께 결정하면 깔끔할 거예요.