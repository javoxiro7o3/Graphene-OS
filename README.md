# Korxona OS — GrapheneOS asosidagi xavfsiz korporativ OS

Korxonamiz uchun xavfsiz mobil operatsion tizim. U [GrapheneOS](https://github.com/GrapheneOS)
manbasidan quriladi va ichiga korxonaning o'z ilovalari joylanadi.

> **Nom haqida:** Biz GrapheneOS'ni o'zgartirib, o'z kalitlarimiz bilan imzolaganimizdan keyin
> bu endi rasmiy GrapheneOS bo'lmaydi. Mahsulotni o'z nomimiz bilan atashimiz kerak.
> "GrapheneOS" nomi va logotipini ishlatishdan oldin huquqiy tomonini tekshiring.

## Asosiy g'oya

```
GrapheneOS manbasi (rasmiy, imzosi tekshirilgan teg)
        +  vendor/korxona/           ← bizning qatlam: ilovalar, ruxsatlar, sozlamalar
        +  o'z imzolash kalitlarimiz   ← verified boot + bootloader qulflangan holda
        +  o'z yangilanish serverimiz   ← OTA yangilanishlar
        =  Korxona OS
```

GrapheneOS kodini iloji boricha **o'zgartirmaymiz**. Barcha o'zgarishlar `vendor/korxona/`
ichida turadi. Shunda har oy chiqadigan GrapheneOS xavfsizlik yangilanishiga o'tish oson bo'ladi.

## Hujjatlar

| Hujjat | Mazmuni |
|---|---|
| [docs/REJA.md](docs/REJA.md) | Yondashuvni tanlash, bosqichma-bosqich reja, resurslar |
| [docs/QURISH.md](docs/QURISH.md) | OS'ni qurish va imzolash (rasmiy qo'llanma asosida) |
| [docs/ILOVALAR.md](docs/ILOVALAR.md) | Korxona ilovalarini OS ichiga qo'shish |
| [docs/XAVFSIZLIK.md](docs/XAVFSIZLIK.md) | Kalitlarni saqlash va reliz xavfsizligi |

## Tezkor boshlash

```bash
scripts/build.sh init 2025110800      # o'rniga eng so'nggi barqaror tegni qo'ying
scripts/build.sh vendor husky         # husky = Pixel 8 Pro
scripts/build.sh apps husky
scripts/build.sh build husky
```

Talablar: x86_64 Linux (Debian 12 / Ubuntu 24.04 / Arch), **32 GB+ RAM**,
**~250 GB+ bo'sh disk**. Batafsil: [docs/QURISH.md](docs/QURISH.md).

## Repo tuzilmasi

```
docs/                       rejalar va qo'llanmalar
scripts/build.sh            qurish/imzolash yordamchisi
scripts/generate_apps.py    apps.json → Android.bp + PRODUCT_PACKAGES
vendor/korxona/
  apps.json                 OS ichiga kiradigan ilovalar ro'yxati
  apps.example.json         namuna
  korxona.mk                qurilma makefile'iga ulanadigan mahsulot fayli
  prebuilt/apps/            APK fayllar (git'ga kiritilmaydi)
```
