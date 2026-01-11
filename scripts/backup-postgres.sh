#!/bin/sh
# PostgreSQL Otomatik Yedekleme Script'i
# Cronjob tarafından her gün saat 01:00'da çalıştırılır

set -e

BACKUP_DIR="/backups"

# Backup dizinini oluştur (yoksa)
mkdir -p "${BACKUP_DIR}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/postgres_backup_${TIMESTAMP}.sql.gz"

echo "[$(date)] PostgreSQL yedekleme başlatılıyor..."
echo "[$(date)] Bağlantı: ${PGUSER}@${PGHOST}:${PGPORT}/${PGDATABASE}"

# pg_dump ile yedek al (custom format, maksimum sıkıştırma)
if pg_dump -Fc -Z9 > "${BACKUP_FILE}" 2>&1; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "[$(date)] ✓ Yedekleme başarılı: ${BACKUP_FILE} (${BACKUP_SIZE})"
    
    # Eski yedekleri temizle
    RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}
    DELETED_COUNT=$(find "${BACKUP_DIR}" -name 'postgres_backup_*.sql.gz' -mtime +${RETENTION_DAYS} -delete -print | wc -l)
    
    if [ "$DELETED_COUNT" -gt 0 ]; then
        echo "[$(date)] ${DELETED_COUNT} eski yedek silindi (${RETENTION_DAYS} günden eski)"
    fi
    
    # Toplam yedek sayısını göster
    TOTAL_BACKUPS=$(find "${BACKUP_DIR}" -name 'postgres_backup_*.sql.gz' | wc -l)
    echo "[$(date)] Toplam yedek sayısı: ${TOTAL_BACKUPS}"
    
    exit 0
else
    echo "[$(date)] ✗ HATA: Yedekleme başarısız oldu!"
    exit 1
fi
