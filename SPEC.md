# 📱 살까 (Sal-kka?) — Product Requirement Document (PRD)

> **Tagline:** *"지르기 전에 3초만. 내 통장을 지키는 쇼핑 쿨다운 앱"*
> (*Just 3 seconds before buying. The shopping cooldown app that protects your bank account.*)

---

## 1. Core Concept & Value Proposition

* **App Name:** 살까 (Sal-kka)
* **Goal:** A native mobile app that interrupts impulse shopping habits by converting prices into real-life labor/item equivalents and enforcing a 72-hour cooling-off period.
* **Target Users:** Korean 20s–30s (Gen Z & Millennials) using mobile shopping platforms (Coupang, Musinsa, Kream, Naver Smart Store, Zigzag).
* **Core Philosophy:** No complex budget tracking. Just a single friction point inserted between the *urge to buy* and the *checkout button*.

---

## 2. Key Features & User Flow

```
[1. 입력 (Input)] ──► [2. 팩폭 리포트 (Reality Check)] ──► [3. 참기 보관소 (Cooling Vault)] ──► [4. 정산 (Outcome Log)]
```

### 2.1. Step 1: Input Screen (입력 화면)

Keep entry friction as low as possible (under 10 seconds to submit):

* **월급 / 시급 입력 (Income):**
  * Enter monthly salary (e.g., `3,000,000원`) OR hourly rate.
  * *Default Option:* 2026 Korea Minimum Wage baseline (`10,030원/시급`).
* **상품 정보 (Item Info):**
  * **상품명/링크 (Name or Link):** e.g., *"무신사 패딩"* or URL paste.
  * **가격 (Price):** Auto-formatted in Korean units (`150,000원` → `15만원`).
  * **카테고리 (Category):** 배달음식 / 패션 / IT·가전 / 취미·게임 / 뷰티.

---

### 2.2. Step 2: "팩폭" (Reality Check) Results Screen

Instead of displaying raw numbers, display impact metrics:

```text
┌────────────────────────────────────────────────────────┐
│                   🚨 팩트 폭격 리포트 🚨                 │
│                                                        │
│  "무신사 패딩 (150,000원)을 사려면..."                   │
│                                                        │
│  ⏰ 내 노동 시간:   14시간 57분 일해야 함               │
│  🍗 치킨 지수:     치킨 7마리 안 먹는 셈                │
│  ☕ 스타벅스:      아메리카노 33잔 꼴                    │
│                                                        │
│  💬 "이 돈이면 당근마켓에 더 싸게 나와있지 않을까?"       │
│  [🥕 당근에서 중고 시세 검색해보기]                    │
│                                                        │
│  ────────────────────────────────────────────────────  │
│  [🔥 참아보기 (72시간 쿨다운 시작)]   [💸 그냥 지금 살래] │
└────────────────────────────────────────────────────────┘
```

---

### 2.3. Step 3: 참기 보관소 (Cooling Vault) & 72-Hour Timer

If the user taps **"참아보기" (Hold Off)**:

* Item goes into the **"살까 보관소" (Cooling Vault)**, persisted locally on-device (`shared_preferences` / local DB).
* A 72-hour timer begins counting down.
* A local push notification (`flutter_local_notifications`) is scheduled to fire when the timer ends, so the user doesn't need to keep the app open — *"⏰ [무신사 패딩] 고민 끝! 아직도 사고 싶어?"*
* **KakaoTalk Share (친구에게 물어보기):**
  * Uses the official Kakao Flutter SDK (`kakao_flutter_sdk_share`) to send a Kakao Card: *"나 이거 **[무신사 패딩]** 살까 말까? 투표해줘!"* with **[사라]** / **[참아라]** voting buttons.

---

### 2.4. Step 4: Outcome & Savings Dashboard (정산 및 아낀 돈)

When the timer ends (or when the user reviews their vault):

* **"참았다!" (Saved):**
  * Triggers celebratory confetti animation.
  * Adds total to **"내가 아낀 총 금액" (Total Money Saved)** counter.
* **"샀다" (Bought):**
  * Logs the purchase. Schedules a follow-up local notification 7 days later: *"잘 쓰고 있나요?"* (regret check).

---

## 3. Korean Market Specializations

| Feature | Implementation Details | Target Friction Point |
| --- | --- | --- |
| **치킨 지수 (Chicken Index)** | Baseline: 1 Chicken = 22,000원 | Translates abstract money into relatable Korean culture units. |
| **당근마켓 연동 (Danggeun Check)** | Opens Danggeun search via `url_launcher` (deep link if app installed, web fallback otherwise) | Encourages C2C second-hand checking before buying new. |
| **카카오톡 공유 (Kakao Share)** | `kakao_flutter_sdk_share` for direct friend polling via Kakao Talk Link | Uses Korean social dynamics to prevent impulse buys. |
| **쿠팡 파트너스 (Coupang Affiliate)** | If user insists on buying, opens affiliate link via in-app browser (`url_launcher` / `flutter_custom_tabs`) | Seamless monetization for the creator. |

---

## 4. Technical Architecture (MVP Stack)

* **Framework:** Flutter (Dart), targeting iOS + Android from a single codebase.
* **State management:** `provider` (or `riverpod`) — lightweight, no backend needed for MVP.
* **Local storage:** `shared_preferences` for simple key/value data, or `sqflite`/`Hive` if the vault history grows complex — no login or backend required, absolute privacy.
* **Animation:** Flutter's built-in animation APIs + `confetti` package for the celebration effect.
* **Notifications:** `flutter_local_notifications` for scheduled local pushes (cooldown ended, 7-day regret check).
* **Sharing:** `kakao_flutter_sdk_share` for KakaoTalk card sharing.
* **External links:** `url_launcher` for Danggeun search and Coupang affiliate redirects.
* **Build/Distribution:** Native build via Xcode (App Store) and Android Studio/Gradle (Google Play); `fastlane` optional for CI/CD.

---

## 5. UI Tone & Wording Guidelines

* Keep the tone lighthearted, relatable, and witty (B급 감성 / MZ 톤앤매너).
* **CTA Buttons:**
  * Primary: `72시간만 참아보기 ⏳`
  * Secondary: `지름신 강림... 그냥 살래 💸`
  * Share: `친구한테 살까 말까 물어보기 💬`
* **Success Message:** `🎉 대단해요! [150,000원]을 방어했습니다!`

---

## 6. Visual Design & Gamification

Visual direction is based on a Meditation app UI kit reference (soft lavender-purple primary, mint secondary, cream "day" backgrounds, deep indigo "night/focus" backgrounds, pill-shaped buttons, rounded illustrated cards).

* **입력 / 팩폭 리포트 (light, cream):** rounded soft-shadow cards, pill segmented income toggle, colorful category chips (topic-grid style), 3-card colorful stat grid for the reality-check metrics.
* **살까 보관소 (dark, "focus mode"):** deep indigo background with scattered stars, dark cards, circular countdown ring per item (progress = time elapsed / 72h) instead of plain digital text.
* **정산 (light, cheerful "home" style):** gradient hero card with total saved + level progress bar, streak counter, and a badge grid.
* **Gamification layer:**
  * *Levels* — title/emoji tier unlocked by cumulative amount saved (지름신 새내기 → 짠테크 입문자 → 절약 스킬러 → 냉철한 소비요정 → 살까 마스터), shown with a progress bar to the next tier.
  * *Streaks* — consecutive "참았다" resolutions in a row (resets on "샀다"), shown as a flame-icon stat.
  * *Badges* — milestone achievements (첫 승리, 3/7연속 참기, 10만원/50만원 세이버, 살까 마스터) shown unlocked (colorful) vs. locked (grayscale outline).
