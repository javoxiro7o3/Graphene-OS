# Korxona ilovalarini OS ichiga qo'shish

## Qanday ishlaydi

1. APK faylni `vendor/korxona/prebuilt/apps/` ga qo'yasiz (git'ga kirmaydi — xavfsiz joydan olinadi).
2. `vendor/korxona/apps.json` ga yozuv qo'shasiz.
3. `scripts/build.sh apps DEVICE` → `scripts/generate_apps.py` quyidagilarni yaratadi:
   - `Android.bp` — har bir ilova uchun `android_app_import` moduli
   - `korxona_apps.mk` — `PRODUCT_PACKAGES` ro'yxati
   - `permissions/privapp-permissions-korxona.xml` — imtiyozli ilovalar uchun
4. Ilovalar `/product/app` (yoki imtiyozli bo'lsa `/product/priv-app`) ga o'rnatiladi va
   foydalanuvchi ularni o'chira olmaydi.

## apps.json formati

```json
[
  { "name": "KorxonaMessenger", "apk": "KorxonaMessenger.apk", "privileged": false },
  {
    "name": "KorxonaMDM",
    "apk": "KorxonaMDM.apk",
    "privileged": true,
    "package": "uz.korxona.mdm",
    "privapp_permissions": ["android.permission.MANAGE_USERS"]
  }
]
```

| Maydon | Ma'nosi |
|---|---|
| `name` | Qurish moduli nomi (lotin harf, raqam, `_`) |
| `apk` | `prebuilt/apps/` ichidagi fayl nomi |
| `privileged` | Tizim darajasidagi ruxsatlar kerakmi |
| `package` | Ilova paket nomi (faqat imtiyozli uchun) |
| `privapp_permissions` | Berilishi kerak bo'lgan imtiyozli ruxsatlar |

Namuna: `vendor/korxona/apps.example.json`.

## Muhim qoidalar

- **Imzo:** ilovalar o'z kaliti bilan imzolangan holda (`presigned`) qo'shiladi. Shunda ilovani
  OS'ni qayta qurmasdan, o'sha kalit bilan imzolangan yangi versiya bilan yangilash mumkin.
  Ilova imzolash kalitini ham OS kalitlari kabi qattiq saqlang.
- **Imtiyozli ruxsatni minimal bering.** Har bir `privileged: true` — hujum yuzasi. Ko'p vazifalar
  (qurilmani boshqarish, siyosatlar) uchun oddiy Android Enterprise *Device Owner* API yetarli.
- Imtiyozli ilova so'ragan, lekin `privapp_permissions` da yo'q ruxsat bo'lsa, `user` qurilishda
  qurilma ishga tushmasligi mumkin — har bir ruxsatni sinov qurilmasida tekshiring.
- **Google xizmatlari:** GrapheneOS'da standart holda Google Play xizmatlari yo'q. Ilovalarimiz
  ularsiz ishlashi (yoki sandboxed Google Play bilan sinalgan bo'lishi) kerak.
- Ilovani manba kodidan qurmoqchi bo'lsak — keyinchalik `android_app` moduli bilan qo'shamiz.
