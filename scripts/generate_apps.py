#!/usr/bin/env python3
"""vendor/korxona/apps.json asosida AOSP qurish fayllarini yaratadi.

Natija:
  vendor/korxona/Android.bp                     - android_app_import modullari
  vendor/korxona/korxona_apps.mk                - PRODUCT_PACKAGES ro'yxati
  vendor/korxona/permissions/privapp-permissions-korxona.xml
                                                - imtiyozli ilovalar ruxsatlari

Ilovalar o'z imzosi bilan (presigned) o'rnatiladi, shuning uchun keyinchalik
ularni OS'ni qayta qurmasdan, o'sha kalit bilan imzolangan yangi versiya orqali
yangilash mumkin.
"""

import json
import re
import sys
from pathlib import Path

VENDOR = Path(__file__).resolve().parent.parent / "vendor" / "korxona"
NAME_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")
PKG_RE = re.compile(r"^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$")
PERM_RE = re.compile(r"^[A-Za-z0-9_.]+$")


def fail(msg):
    print(f"XATO: {msg}", file=sys.stderr)
    sys.exit(1)


def load_apps(path):
    try:
        apps = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as e:
        fail(f"{path} o'qib bo'lmadi: {e}")
    if not isinstance(apps, list):
        fail("apps.json ro'yxat ([...]) bo'lishi kerak")

    seen = set()
    for i, app in enumerate(apps):
        where = f"apps.json[{i}]"
        if not isinstance(app, dict):
            fail(f"{where}: obyekt bo'lishi kerak")
        name = app.get("name", "")
        if not NAME_RE.match(name):
            fail(f"{where}: 'name' faqat harf/raqam/_ bo'lishi kerak: {name!r}")
        if name in seen:
            fail(f"{where}: '{name}' takrorlangan")
        seen.add(name)

        apk = app.get("apk", "")
        if not apk or "/" in apk or not apk.endswith(".apk"):
            fail(f"{where}: 'apk' prebuilt/apps/ ichidagi .apk fayl nomi bo'lishi kerak")
        if not (VENDOR / "prebuilt" / "apps" / apk).is_file():
            fail(f"{where}: vendor/korxona/prebuilt/apps/{apk} topilmadi")

        if app.get("privileged"):
            if not PKG_RE.match(app.get("package", "")):
                fail(f"{where}: imtiyozli ilova uchun to'g'ri 'package' kerak")
            perms = app.get("privapp_permissions", [])
            if not isinstance(perms, list) or not all(
                isinstance(p, str) and PERM_RE.match(p) for p in perms
            ):
                fail(f"{where}: 'privapp_permissions' satrlar ro'yxati bo'lishi kerak")
    return apps


def render_bp(apps):
    out = ["// AVTOMATIK YARATILGAN — scripts/generate_apps.py. Qo'lda tahrirlamang.\n"]
    for app in apps:
        priv = "true" if app.get("privileged") else "false"
        out.append(
            "android_app_import {\n"
            f'    name: "{app["name"]}",\n'
            f'    apk: "prebuilt/apps/{app["apk"]}",\n'
            "    presigned: true,\n"
            f"    privileged: {priv},\n"
            "    product_specific: true,\n"
            "    dex_preopt: {\n"
            "        enabled: false,\n"
            "    },\n"
            "}\n"
        )
    if any(a.get("privileged") for a in apps):
        out.append(
            "prebuilt_etc {\n"
            '    name: "privapp-permissions-korxona.xml",\n'
            '    src: "permissions/privapp-permissions-korxona.xml",\n'
            '    sub_dir: "permissions",\n'
            "    product_specific: true,\n"
            "}\n"
        )
    return "\n".join(out)


def render_mk(apps):
    names = [a["name"] for a in apps]
    if any(a.get("privileged") for a in apps):
        names.append("privapp-permissions-korxona.xml")
    lines = ["# AVTOMATIK YARATILGAN — scripts/generate_apps.py. Qo'lda tahrirlamang."]
    if names:
        lines.append("PRODUCT_PACKAGES += \\")
        lines += [f"    {n} \\" for n in names[:-1]] + [f"    {names[-1]}"]
    return "\n".join(lines) + "\n"


def render_privapp(apps):
    lines = ['<?xml version="1.0" encoding="utf-8"?>',
             "<!-- AVTOMATIK YARATILGAN — scripts/generate_apps.py -->",
             "<permissions>"]
    for app in apps:
        if not app.get("privileged"):
            continue
        lines.append(f'    <privapp-permissions package="{app["package"]}">')
        for perm in app.get("privapp_permissions", []):
            lines.append(f'        <permission name="{perm}"/>')
        lines.append("    </privapp-permissions>")
    lines.append("</permissions>")
    return "\n".join(lines) + "\n"


def main():
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else VENDOR / "apps.json"
    apps = load_apps(src)
    (VENDOR / "Android.bp").write_text(render_bp(apps), encoding="utf-8")
    (VENDOR / "korxona_apps.mk").write_text(render_mk(apps), encoding="utf-8")
    perm_dir = VENDOR / "permissions"
    perm_file = perm_dir / "privapp-permissions-korxona.xml"
    if any(a.get("privileged") for a in apps):
        perm_dir.mkdir(exist_ok=True)
        perm_file.write_text(render_privapp(apps), encoding="utf-8")
    elif perm_file.exists():
        perm_file.unlink()
    print(f"{len(apps)} ta ilova uchun qurish fayllari yaratildi.")


if __name__ == "__main__":
    main()
