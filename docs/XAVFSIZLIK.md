# Kalitlar va reliz xavfsizligi

Imzolash kalitlari — butun tizim xavfsizligining asosi. Kim kalitlarga ega bo'lsa, barcha
korxona qurilmalariga o'z "yangilanishini" o'rnata oladi.

## Qoidalar

1. **Kalitlar hech qachon git'ga tushmaydi** (`.gitignore` da `keys/`, `*.pk8`, `*.pem` va h.k.).
2. Kalitlar parol bilan shifrlangan holda saqlanadi: `script/encrypt-keys keys/DEVICE`.
   Bir qurilmaning barcha kalitlari uchun parol bir xil bo'lishi kerak (GrapheneOS skriptlari talabi).
3. Imzolash — **alohida, internetdan ajratilgan mashinada**. Qurish serveri faqat imzosiz
   `target-files` ni tayyorlaydi.
4. Imzolash vaqtida swap o'chirilgan (yoki vaqtinchalik kalit bilan shifrlangan) bo'lsin.
5. Kamida 2 ta shifrlangan oflayn zaxira, turli jismoniy joylarda. Kalitlar yo'qolsa —
   barcha qurilmalarni qayta flash qilish (ma'lumotlar o'chadi) kerak bo'ladi.
6. Kalitlarga kirish huquqi — 2 kishidan ko'p emas, har bir imzolash jurnalga yoziladi.
7. Har bir qurilma modeli uchun alohida kalitlar.

## Qurilmani himoyalash

- Ishlab chiqarishda faqat `user` qurilish (userdebug emas).
- O'z `avb_pkmd.bin` kalitimizni qurilmaga yozib, **bootloaderni qulflash** — shunda faqat
  biz imzolagan OS ishga tushadi (verified boot).
- OEM unlocking'ni o'chirish.
- Qurilma butunligini Auditor (attestation) orqali vaqti-vaqti bilan tekshirish.

## Manba zanjiri

- Har doim GrapheneOS teg imzosini tekshirish (`git verify-tag`) — `scripts/build.sh init` buni qiladi.
- Ilova APK'larini faqat ichki, tekshirilgan manbadan olish; har bir APK imzosini
  `apksigner verify --print-certs` bilan tekshirish.
