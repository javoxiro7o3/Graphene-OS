# Reja: GrapheneOS asosida Korxona OS

## 1. Avval muhim qaror: fork qilamizmi yoki yo'qmi?

Maqsadga (xavfsiz OS + o'z ilovalarimiz) ikki yo'l bilan erishish mumkin:

| | **A. O'z OS'imiz (fork)** | **B. Rasmiy GrapheneOS + boshqaruv (MDM)** |
|---|---|---|
| Ilovalar | OS ichiga tizim ilovasi sifatida o'rnatiladi, o'chirib bo'lmaydi | Oddiy ilova sifatida o'rnatiladi (MDM / ish profili orqali) |
| Tizim darajasidagi ruxsatlar | Mumkin (privileged ilova) | Faqat Android Enterprise imkoniyatlari doirasida |
| Brending, sozlamalar | To'liq nazorat | Yo'q |
| Xavfsizlik yangilanishlari | **Har oy o'zimiz qayta quramiz, imzolaymiz, tarqatamiz** | GrapheneOS'dan avtomatik keladi |
| Infratuzilma | Qurish serveri, kalitlar xavfsizligi, OTA server | Faqat MDM server |
| Xodim/vaqt | Doimiy 1–2 Android tizim muhandisi | Kam |
| Xavf | Yangilanish kechiksa — qurilmalar zaif qoladi | Past |

**Tavsiya:** ikkalasini bosqichma-bosqich qilish.
1. Avval **B yo'li** bilan pilot: ilovalarimiz GrapheneOS'da (Google xizmatlarisiz yoki
   sandboxed Google Play bilan) to'g'ri ishlashini tekshiramiz. Bu bir necha haftada natija beradi.
2. Parallel ravishda **A yo'li** uchun qurish quvurini (pipeline) tayyorlaymiz.
3. Agar ilovalarimizga haqiqatan tizim darajasidagi ruxsat yoki o'chirib bo'lmaslik kerak
   bo'lsa — A yo'liga to'liq o'tamiz.

> Eng katta xavf — forkni yaratish emas, uni **har oy yangilab turish**. GrapheneOS
> deyarli har oy xavfsizlik yangilanishi chiqaradi; biz ham shu tezlikda reliz qila olishimiz shart.

## 2. Bosqichlar

### 0-bosqich — Tayyorgarlik (1–2 hafta)
- [ ] Qurilma modelini tanlash (pastdagi ro'yxatdan). Tavsiya: **Pixel 8 / 9 / 10 seriyasi** —
      xotira tegi (MTE) kabi kuchli apparat xavfsizligi bor va uzoqroq qo'llab-quvvatlanadi.
- [ ] Bitta model bilan boshlash (har bir model = alohida qurilish + alohida kalitlar).
- [ ] Qurish serveri: x86_64 Linux, 32 GB+ RAM (64 GB tavsiya), 250 GB+ SSD, ko'p yadroli CPU.
- [ ] Ilovalar ro'yxati: qaysi ilovalar, APK yoki manba kodi, qaysi ruxsatlar kerak.
- [ ] Mahsulot nomini tanlash.

### 1-bosqich — Pilot (B yo'li) (2–4 hafta)
- [ ] 3–5 ta Pixel'ga rasmiy GrapheneOS o'rnatish.
- [ ] Korxona ilovalarini o'rnatib sinash (Google xizmatlarisiz va sandboxed Play bilan).
- [ ] Muammolar ro'yxati: qaysi ilova nima uchun tizim darajasidagi ruxsatni talab qiladi.

### 2-bosqich — Birinchi qurilish (A yo'li) (2–4 hafta)
- [ ] `scripts/build.sh init/vendor/build` — o'zgartirishsiz GrapheneOS'ni qurish (userdebug).
- [ ] Sinov qurilmasiga flash qilish (bootloader ochiq holda).
- [ ] `vendor/korxona/apps.json` orqali birinchi ilovani qo'shish.

### 3-bosqich — Ishlab chiqarishga tayyor reliz (3–6 hafta)
- [ ] Imzolash kalitlarini yaratish va xavfsiz saqlash ([XAVFSIZLIK.md](XAVFSIZLIK.md)).
- [ ] `user` qurilish, o'z kalitlarimiz bilan imzolash.
- [ ] O'z AVB kalitimizni qurilmaga yozib, **bootloaderni qulflash** (verified boot).
- [ ] O'z OTA serverimiz + Updater ilovasida URL'ni almashtirish.
- [ ] Auditor ilovasi bilan qurilma butunligini (attestation) tekshirish jarayoni.

### 4-bosqich — Doimiy ishlash (har oy)
- [ ] Yangi GrapheneOS tegi chiqishi bilan: sync → qurish → testing kanali → beta → stable.
- [ ] Maqsad: GrapheneOS relizidan keyin **7 kundan kechikmay** yangilanish.
- [ ] Iloji bo'lsa CI'da avtomatlashtirish (alohida, internetdan ajratilgan imzolash mashinasi bilan).

## 3. Qo'llab-quvvatlanadigan qurilmalar (qurish nishonlari)

GrapheneOS qurish qo'llanmasidagi ro'yxat (2026-yil noyabr holatiga):

| Kod nomi | Qurilma | Kod nomi | Qurilma |
|---|---|---|---|
| stallion | Pixel 10a | akita | Pixel 8a |
| rango | Pixel 10 Pro Fold | husky | Pixel 8 Pro |
| mustang | Pixel 10 Pro XL | shiba | Pixel 8 |
| blazer | Pixel 10 Pro | felix | Pixel Fold |
| frankel | Pixel 10 | tangorpro | Pixel Tablet |
| tegu | Pixel 9a | lynx | Pixel 7a |
| comet | Pixel 9 Pro Fold | cheetah | Pixel 7 Pro |
| komodo | Pixel 9 Pro XL | panther | Pixel 7 |
| caiman | Pixel 9 Pro | bluejay | Pixel 6a |
| tokay | Pixel 9 | raven / oriole | Pixel 6 Pro / Pixel 6 |

Yangi qurilmalar xarid qilishdan oldin ularning qo'llab-quvvatlash muddatini tekshiring.

## 4. Hal qilinishi kerak bo'lgan savollar
1. Qaysi Pixel model(lar)?
2. Ilovalarimiz ro'yxati, ular APK sifatida bormi yoki manba kodidanmi quriladi?
3. Ilovalarga Google Play xizmatlari kerakmi?
4. Qurilmalarni masofadan boshqarish (MDM) kerakmi — o'zimiz yozamizmi yoki tayyor yechim?
5. OTA server qayerda joylashadi (ichki tarmoq / bulut)?
