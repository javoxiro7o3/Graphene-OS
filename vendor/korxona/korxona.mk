# Korxona OS — mahsulot (product) sozlamalari.
# Bu fayl qurilma makefile'iga quyidagi qator bilan ulanadi
# (scripts/build.sh buni avtomatik bajaradi):
#   $(call inherit-product-if-exists, vendor/korxona/korxona.mk)

# Korxona ilovalari ro'yxati — scripts/generate_apps.py apps.json asosida yaratadi
-include vendor/korxona/korxona_apps.mk
