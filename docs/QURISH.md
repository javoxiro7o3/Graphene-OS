# Qurish va imzolash

Bu hujjat rasmiy [GrapheneOS qurish qo'llanmasi](https://grapheneos.org/build) asosida yozilgan
(2026-yil noyabr). Har yangi reliz oldidan rasmiy qo'llanmani qayta tekshiring — buyruqlar o'zgarishi mumkin.
`scripts/build.sh` quyidagi qadamlarni avtomatlashtiradi.

## 1. Qurish serveri

- OS: Debian 12, Ubuntu 24.04 LTS / 24.10 yoki Arch Linux (x86_64)
- RAM: **32 GiB+**
- Disk: manba uchun 136 GiB (tarix bilan) + qurilish uchun 100 GiB+ → amalda **250 GiB+ SSD**
- Paketlar (Debian): `apt install repo yarnpkg zip rsync`, shuningdek git, python3, gnupg,
  openssh, openssl, unzip, diffutils, fontconfig + istalgan TTF shrift, Node.js 24 LTS

## 2. Manbani yuklab olish

Har doim **barqaror teg** ishlating (development branch emas). Teglar ro'yxati:
<https://grapheneos.org/releases>. Har xil qurilmalar uchun teg farq qilishi mumkin.

```bash
mkdir grapheneos-TAG_NAME && cd grapheneos-TAG_NAME
repo init -u https://github.com/GrapheneOS/platform_manifest.git -b refs/tags/TAG_NAME
curl https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
cd .repo/manifests
git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers
git verify-tag $(git describe)     # imzo tasdiqlanmasa — TO'XTANG
cd ../..
repo sync -j8
```

Skript bilan: `scripts/build.sh init TAG_NAME`

## 3. Pixel vendor fayllari

```bash
source build/envsetup.sh
yarn --cwd vendor/adevtool/ install     # Debian'da: yarnpkg
adevtool generate-all -d PIXEL_CODENAME
```

Skript bilan: `scripts/build.sh vendor husky`

## 4. Korxona qatlamini qo'shish

```bash
scripts/build.sh apps husky
```

Bu `vendor/korxona/` ni manba daraxtiga nusxalaydi va qurilma makefile'iga
`$(call inherit-product-if-exists, vendor/korxona/korxona.mk)` qatorini qo'shadi.
Batafsil: [ILOVALAR.md](ILOVALAR.md).

## 5. Yangilanish serveri URL'i (majburiy!)

`packages/apps/Updater/res/values/config.xml` dagi URL'ni **o'z serverimiz** manziliga almashtiring.
Rasmiy GrapheneOS URL'ini qoldirish — ularning serveriga keraksiz yuk (DoS) bo'ladi va
qurilmalar yangilanishni cheksiz qayta yuklaydi. Bu o'zgarishni alohida patch sifatida saqlaymiz.

## 6. Qurish

```bash
source build/envsetup.sh
lunch husky-cur-user          # dasturlash uchun: husky-cur-userdebug
export OFFICIAL_BUILD=true    # Updater ilovasini qo'shadi
rm -r out
m target-files-package
```

Qo'shimcha nishonlar kerak bo'lgan qurilmalar (`scripts/build.sh build` avtomatik tanlaydi):
- Pixel 6, 6 Pro, 6a: `m vendorbootimage target-files-package`
- Pixel 7, 7 Pro, 7a, Tablet, Fold, 8, 8 Pro, 8a, 9, 9 Pro, 9 Pro XL, 9 Pro Fold:
  `m vendorbootimage vendorkernelbootimage target-files-package`

Tezkor dasturlash uchun (faqat sinov qurilmasi, bootloader ochiq): `m`.

## 7. Imzolash kalitlari (har bir qurilma modeli uchun BIR MARTA)

```bash
scripts/build.sh keys husky
```

Yaratiladi: `releasekey platform shared media networkstack bluetooth sdk_sandbox
gmscompat_lib nfc`, `avb.pem` (verified boot), `avb_pkmd.bin` (qurilmaga yoziladigan ochiq kalit),
`id_ed25519` (factory image imzosi). Keyin shifrlash: `script/encrypt-keys keys/husky`.

⚠️ Kalitlarni keyin almashtirib bo'lmaydi — barcha qurilmalarni qayta flash qilish (to'liq
o'chirish) kerak bo'ladi. Saqlash qoidalari: [XAVFSIZLIK.md](XAVFSIZLIK.md).

## 8. Imzolangan reliz

```bash
scripts/build.sh release husky BUILD_NUMBER
```

Ichida: `m otatools-package` → `script/finalize.sh` → `script/generate-release.sh husky BUILD_NUMBER`.
Natija: `releases/BUILD_NUMBER/release-husky-BUILD_NUMBER` (factory image + to'liq OTA + kanal metadata).

Delta yangilanish: `script/generate-delta.sh husky ESKI_RAQAM YANGI_RAQAM`.

## 9. OTA tarqatish

Yangilanish serveri — oddiy statik veb-server. Reliz fayllari va kanal metadata'sini
(`husky-testing`, `husky-beta`, `husky-stable`) yuklaymiz. Tartib:
**testing** (ichki) → **beta** (pilot guruh) → **stable** (hamma).
Sinov qurilmasida testing kanaliga o'tish: `adb shell setprop sys.update.channel testing`.
