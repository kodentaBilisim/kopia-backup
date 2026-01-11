FROM postgres:16-alpine

WORKDIR /app

# Backup script'ini kopyala
COPY backup-postgres.sh /usr/local/bin/backup-postgres.sh

# Executable yap
RUN chmod +x /usr/local/bin/backup-postgres.sh

# Entrypoint
ENTRYPOINT ["/bin/sh"]
