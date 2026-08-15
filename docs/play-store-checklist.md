# Play Store submission checklist — 살까 (Sal-kka)

Everything below is drafted content you can copy straight into Play Console, plus notes on what to select in forms I can't fill out for you (they require your logged-in account).

## 1. Privacy policy

Host `docs/privacy-policy.html` somewhere public and put the URL into:
**Play Console → Policy → App content → Privacy policy**

Easiest hosting options:
- Push this repo to GitHub, enable **GitHub Pages** on the `/docs` folder of the main branch → URL will be `https://<username>.github.io/<repo>/privacy-policy.html`.
- Or paste the HTML into a free static host (Netlify drop, Cloudflare Pages, etc).

Contact email used throughout: **silvercircle8877@gmail.com** (used for both the privacy policy and Play Console developer contact — update the HTML file if you want a different one).

## 2. Store listing copy

**App name:** 살까

**Short description** (80 chars max):
```
사고 싶은 걸 참으면 얼마나 아낄 수 있는지, 노동 시간으로 바로 알려드려요
```
(76 characters)

**Full description** (4,000 chars max):
```
"이거 살까 말까?" 고민될 때, 살까가 답해드려요.

💰 가격을 노동 시간으로 변환
상품 가격을 내 시급/월급 기준으로 환산해서, 그 돈을 벌기 위해 몇 시간을 일해야 하는지 바로 보여드려요. 치킨 몇 마리, 스타벅스 몇 잔과 같다는 재미있는 비교도 함께 확인하세요.

⏳ 72시간 쿨다운
바로 사지 않고 72시간 동안 고민할 시간을 가져보세요. 시간이 지나도 정말 사고 싶다면, 그건 진짜 필요한 물건일 확률이 높아요.

🎮 게이미피케이션으로 절약 습관 만들기
참을 때마다 포인트가 쌓이고, 레벨이 오르고, 배지를 모을 수 있어요. 연속으로 참은 기록(스트릭)도 보여드려서, 꾸준히 절약하는 재미를 느낄 수 있어요.

📊 나의 소비 리포트
아낀 금액과 쓴 금액을 한눈에 비교하고, 카테고리별 지출 통계와 최근 지출 내역도 확인하세요.

🔒 로그인 없이도 사용 가능
회원가입 없이 바로 시작할 수 있어요. 로그인하면 여러 기기에서 같은 데이터를 동기화할 수 있습니다.

이런 분들께 추천해요:
- 충동구매를 줄이고 싶은 분
- 소비 습관을 게임처럼 재미있게 관리하고 싶은 분
- 돈을 시간의 가치로 다시 생각해보고 싶은 분

지금 살까와 함께, 후회 없는 소비를 시작해보세요.
```

**Category:** Finance (or Lifestyle as a secondary option)

**Contact email:** silvercircle8877@gmail.com

**Screenshots:** done — 6 clean shots at 960×1920 (3x supersampled from the app's tested 320×640 dp layout, so nothing reflowed) in `docs/store-assets/screenshots/`:
- `01_input.png` — home/mascot screen
- `02_dashboard.png` — levels, badges, streak stats
- `03_vault.png` — 72-hour cooldown vault
- `04_add_item.png` — add-purchase form
- `05_reality_check.png` — the "fact bomb" labor-hours report (probably your best hero shot)
- `06_profile.png` — profile with income settings, spending breakdown

**App icon for listing:** `assets/icon/icon.png` (1024×1024) — already generated, can be used directly as the 512×512 Play Store listing icon (Play will downscale it).

**Feature graphic** (1024×500, required): done — `docs/store-assets/feature_graphic.png`, same gradient + mascot branding as the app icon, with the app name and tagline.

## 3. Data safety form

**Play Console → Policy → App content → Data safety**

| Data type | Collected? | Shared with third parties? | Purpose | Optional? |
|---|---|---|---|---|
| Email address | Yes (only if user signs in) | No | Account management | Yes — app works without it |
| Financial info (income, purchase records) | Yes (only if user signs in) | No | App functionality (sync across devices) | Yes — app works without it |

Also declare:
- Data is encrypted in transit: **Yes** (HTTPS via Supabase)
- Users can request data deletion: **Yes** (via the contact email — you'll need to honor deletion requests manually since there's no in-app "delete my account" button yet; let me know if you want me to add one)
- Data collection is not required to use the app: **Yes**

## 4. Content rating questionnaire

**Play Console → Policy → App content → Content ratings**

This is a simple personal-finance/utility app with no violence, sexual content, gambling, user-generated content shared with others, or chat with strangers. Expect to answer "No" to nearly every content question, which should land the app at **Everyone / 전체 이용가**. You do need to declare it has account creation/login (yes) and that it handles personal user data (yes, covered by the data safety form above).

## 5. Still outstanding (needs your Play Console login — I can't do these)

- [ ] Create the app entry in Play Console, upload `build/app/outputs/bundle/release/app-release.aab`
- [ ] Fill in privacy policy URL, data safety form, content rating questionnaire (guidance above)
- [ ] Upload store listing text/screenshots/icon/feature graphic
- [ ] Set target audience & age (not for kids)
- [ ] Declare ads: **No ads** (app has none)
- [ ] Roll out to **Internal testing** track first before closed/open/production
- [ ] **Rotate the Supabase secret/service role key** that was pasted in an earlier chat message, before going to production
