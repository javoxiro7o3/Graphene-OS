#!/usr/bin/env bash
# Korxona OS (GrapheneOS asosida) qurish yordamchisi.
# Buyruqlar rasmiy qo'llanmadan olingan: https://grapheneos.org/build
#
# Foydalanish:
#   scripts/build.sh init    TAG          # manbani yuklab olish (masalan TAG=2025110800)
#   scripts/build.sh vendor  DEVICE       # Pixel vendor fayllarini adevtool bilan olish
#   scripts/build.sh apps    DEVICE       # korxona ilovalarini manba daraxtiga qo'shish
#   scripts/build.sh build   DEVICE       # target-files-package qurish
#   scripts/build.sh keys    DEVICE       # imzolash kalitlarini yaratish (BIR MARTA!)
#   scripts/build.sh release DEVICE BUILD_NUMBER   # imzolangan reliz yaratish
#
# Muhit o'zgaruvchilari:
#   SRC_DIR   manba daraxti joyi (standart: ~/korxona-os)
#   KEY_CN    sertifikat egasi nomi (standart: KorxonaOS)
#   VARIANT   user | userdebug (standart: user — ishlab chiqarish uchun faqat user)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${SRC_DIR:-$HOME/korxona-os}"
KEY_CN="${KEY_CN:-KorxonaOS}"
VARIANT="${VARIANT:-user}"

die() { echo "XATO: $*" >&2; exit 1; }
need_arg() { [[ -n "${1:-}" ]] || die "$2 ko'rsatilmagan. Yordam: $0 help"; }
in_src() { [[ -d "$SRC_DIR/.repo" ]] || die "$SRC_DIR da manba yo'q. Avval: $0 init TAG"; cd "$SRC_DIR"; }

envsetup() {
    set +u
    # shellcheck disable=SC1091
    source build/envsetup.sh
    set -u
}

cmd_init() {
    local tag="${1:-}"; need_arg "$tag" "TAG"
    mkdir -p "$SRC_DIR" && cd "$SRC_DIR"
    repo init -u https://github.com/GrapheneOS/platform_manifest.git -b "refs/tags/$tag"

    # Teg imzosini GrapheneOS kaliti bilan tekshirish
    mkdir -p ~/.ssh
    curl -fsSL https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
    (cd .repo/manifests &&
        git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers &&
        git verify-tag "$(git describe)") || die "Teg imzosi tasdiqlanmadi — davom etmang!"

    repo sync -j8
}

cmd_vendor() {
    local device="${1:-}"; need_arg "$device" "DEVICE"
    in_src
    envsetup
    if [[ ! -d vendor/adevtool/node_modules ]]; then
        if command -v yarnpkg >/dev/null; then yarnpkg --cwd vendor/adevtool/ install
        else yarn --cwd vendor/adevtool/ install; fi
    fi
    adevtool generate-all -d "$device"
}

# Qurilmaning mahsulot makefile'ini AndroidProducts.mk orqali topadi
find_product_mk() {
    local device="$1" f line
    while IFS= read -r f; do
        line="$(grep -oE "[A-Za-z0-9_./\$()-]*/(aosp_)?${device}\.mk" "$f" | head -n1 || true)"
        if [[ -n "$line" ]]; then
            line="${line//\$(LOCAL_DIR)/$(dirname "$f")}"
            [[ -f "$line" ]] && { echo "$line"; return 0; }
        fi
    done < <(find device -name AndroidProducts.mk 2>/dev/null)
    return 1
}

cmd_apps() {
    local device="${1:-}"; need_arg "$device" "DEVICE"
    python3 "$REPO_ROOT/scripts/generate_apps.py"
    in_src
    rm -rf vendor/korxona && mkdir -p vendor
    cp -a "$REPO_ROOT/vendor/korxona" vendor/korxona
    rm -f vendor/korxona/apps.example.json

    local mk hook='$(call inherit-product-if-exists, vendor/korxona/korxona.mk)'
    mk="$(find_product_mk "$device")" || die "$device uchun mahsulot makefile topilmadi. Qatorni qo'lda qo'shing: $hook"
    if ! grep -qF "vendor/korxona/korxona.mk" "$mk"; then
        printf '\n# Korxona OS\n%s\n' "$hook" >> "$mk"
        echo "Ulandi: $mk"
    else
        echo "Allaqachon ulangan: $mk"
    fi
}

cmd_build() {
    local device="${1:-}"; need_arg "$device" "DEVICE"
    in_src
    grep -q "releases.grapheneos.org" packages/apps/Updater/res/values/config.xml 2>/dev/null &&
        echo "OGOHLANTIRISH: Updater hali rasmiy GrapheneOS serveriga qaragan. O'z serveringiz URL'ini qo'ying (docs/QURISH.md)." >&2
    envsetup
    lunch "${device}-cur-${VARIANT}"
    export OFFICIAL_BUILD=true
    rm -rf out
    case "$device" in
        oriole|raven|bluejay)
            m vendorbootimage target-files-package ;;
        panther|cheetah|lynx|tangorpro|felix|shiba|husky|akita|tokay|caiman|komodo|comet)
            m vendorbootimage vendorkernelbootimage target-files-package ;;
        *)
            m target-files-package ;;
    esac
}

cmd_keys() {
    local device="${1:-}"; need_arg "$device" "DEVICE"
    in_src
    [[ -e "keys/$device" ]] && die "keys/$device allaqachon mavjud. Kalitlarni almashtirish barcha qurilmalarni qayta flash qilishni talab qiladi!"
    mkdir -p "keys/$device" && cd "keys/$device"
    local k
    for k in releasekey platform shared media networkstack bluetooth sdk_sandbox gmscompat_lib nfc; do
        ../../development/tools/make_key "$k" "/CN=$KEY_CN/"
    done
    openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.pem
    ../../external/avb/avbtool.py extract_public_key --key avb.pem --output avb_pkmd.bin
    cd ../..
    ssh-keygen -t ed25519 -f "keys/$device/id_ed25519"
    echo "Tayyor. keys/$device ni SHIFRLANGAN oflayn zaxiraga oling (docs/XAVFSIZLIK.md)."
}

cmd_release() {
    local device="${1:-}" build_number="${2:-}"
    need_arg "$device" "DEVICE"; need_arg "$build_number" "BUILD_NUMBER"
    in_src
    [[ -d "keys/$device" ]] || die "keys/$device yo'q. Avval: $0 keys $device"
    envsetup
    lunch "${device}-cur-${VARIANT}"
    m otatools-package
    script/finalize.sh
    script/generate-release.sh "$device" "$build_number"
    echo "Natija: releases/$build_number/release-$device-$build_number"
}

case "${1:-help}" in
    init)    shift; cmd_init "$@" ;;
    vendor)  shift; cmd_vendor "$@" ;;
    apps)    shift; cmd_apps "$@" ;;
    build)   shift; cmd_build "$@" ;;
    keys)    shift; cmd_keys "$@" ;;
    release) shift; cmd_release "$@" ;;
    *) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
