# Kopia Docker Backup Stack

PostgreSQL ve MinIO verilerinizi otomatik olarak yedekleyen, SSH/SFTP üzerinden uzak sunucuya gönderen Docker Compose stack'i.

## 🎯 Özellikler

- ✅ **Otomatik PostgreSQL Yedekleme**: Her gün saat 01:00'da pg_dump ile yedek
- ✅ **Kopia Backup Server**: Web arayüzü ile yönetim
- ✅ **SSH/SFTP Desteği**: Uzak sunucuya güvenli yedekleme
- ✅ **Docker Volume Yedekleme**: PostgreSQL ve MinIO volume'ları
- ✅ **Otomatik Temizleme**: Eski yedekleri otomatik siler
- ✅ **Cronjob Tabanlı**: Alpine crond ile zamanlanmış görevler

## 📋 Gereksinimler

- Docker & Docker Compose
- Portainer (opsiyonel, önerilir)
- SSH erişimi olan uzak sunucu (yedekler için)

## 🚀 Hızlı Başlangıç

### 1. Repository'yi Klonlayın

```bash
git clone https://github.com/kullanici-adi/kopia-docker.git
cd kopia-docker
```

### 2. Environment Variables Ayarlayın

```bash
cp .env.example .env
nano .env
```

Aşağıdaki değerleri düzenleyin:

```bash
# Kopia şifresi
KOPIA_PASSWORD=güçlü_bir_şifre

# PostgreSQL bağlantı bilgileri
POSTGRES_HOST=172.18.0.4  # veya container adı
POSTGRES_DB=veritabanı_adı
POSTGRES_USER=kullanıcı_adı
POSTGRES_PASSWORD=postgresql_şifresi

# Docker volume yolları
POSTGRES_VOLUME_PATH=/var/lib/docker/volumes/postgres_data/_data
MINIO_VOLUME_PATH=/var/lib/docker/volumes/minio_data/_data
```

### 3. SSH Key Hazırlayın

```bash
# SSH key dizini oluştur
mkdir -p ssh-keys

# Mevcut key'i kopyala veya yeni oluştur
cp ~/.ssh/id_rsa ssh-keys/
chmod 600 ssh-keys/id_rsa

# Public key'i uzak sunucuya ekle
ssh-copy-id kullanici@uzak-sunucu
```

### 4. Stack'i Başlatın

#### Docker Compose ile:
```bash
docker-compose up -d
```

#### Portainer ile:
1. **Stacks** → **Add stack**
2. **Repository** seçeneğini seçin
3. Repository URL'sini girin
4. Environment variables'ları ekleyin
5. **Deploy the stack**

## 🔧 Yapılandırma

### Kopia Web Arayüzü

`http://sunucu-ip:51515` adresinden erişin:

- **Kullanıcı adı**: `admin`
- **Şifre**: `.env` dosyasındaki `KOPIA_PASSWORD`

### SFTP Repository Ayarları

1. Kopia web arayüzünde **Repository** → **Create New**
2. **SFTP** seçin
3. Bilgileri girin:
   - **Host**: Uzak sunucu IP
   - **Port**: 22
   - **Username**: SSH kullanıcı adı
   - **Path**: `/backup/kopia`
   - **SSH Key Path**: `/root/.ssh/id_rsa`

### Snapshot Politikaları

1. **Snapshots** → **New Snapshot**
2. Yedeklenecek dizinleri seçin:
   - `/data/postgres-dumps` - pg_dump yedekleri
   - `/data/postgres-volume` - PostgreSQL volume
   - `/data/minio` - MinIO verileri
3. Zamanlama ayarlayın (örn: günlük 02:00)

## 📊 Yedekleme Stratejisi

### PostgreSQL
- **pg_dump yedekleri**: Her gün 01:00 (cronjob)
- **Volume yedekleri**: Kopia ile zamanlanmış
- **Saklama süresi**: 7 gün (ayarlanabilir)

### MinIO
- **Volume yedekleri**: Kopia ile zamanlanmış

## 🔍 İzleme ve Loglar

### Backup Logları
```bash
docker logs postgres-backup
docker exec -it postgres-backup cat /var/log/backup.log
```

### Kopia Logları
```bash
docker logs kopia
```

### Manuel Yedekleme
```bash
docker exec -it postgres-backup /usr/local/bin/backup-postgres.sh
```

## 📁 Dizin Yapısı

```
kopia-docker/
├── docker-compose.yml      # Ana yapılandırma
├── .env.example            # Örnek environment variables
├── .gitignore             # Git ignore kuralları
├── README.md              # Bu dosya
├── scripts/
│   └── backup-postgres.sh # PostgreSQL backup script'i
└── ssh-keys/              # SSH private key'ler (git'e eklenmez)
    └── id_rsa
```

## ⚙️ Environment Variables

| Variable | Açıklama | Varsayılan |
|----------|----------|------------|
| `KOPIA_PASSWORD` | Kopia admin şifresi | - |
| `KOPIA_PORT` | Kopia web arayüzü portu | 51515 |
| `POSTGRES_HOST` | PostgreSQL sunucu adresi | - |
| `POSTGRES_PORT` | PostgreSQL portu | 5432 |
| `POSTGRES_DB` | Veritabanı adı | - |
| `POSTGRES_USER` | PostgreSQL kullanıcı adı | - |
| `POSTGRES_PASSWORD` | PostgreSQL şifresi | - |
| `BACKUP_RETENTION_DAYS` | Yedek saklama süresi (gün) | 7 |
| `POSTGRES_VOLUME_PATH` | PostgreSQL volume yolu | - |
| `MINIO_VOLUME_PATH` | MinIO volume yolu | - |
| `SSH_KEYS_PATH` | SSH key dizini | ./ssh-keys |
| `TZ` | Zaman dilimi | Europe/Istanbul |

## 🔒 Güvenlik

- ✅ `.env` dosyası git'e eklenmez
- ✅ SSH key'ler git'e eklenmez
- ✅ Şifreler environment variables'da
- ✅ Read-only volume mount'lar
- ✅ SSH key authentication

## 🛠️ Sorun Giderme

### PostgreSQL Bağlantı Hatası

```bash
# Container'ı kontrol et
docker exec -it postgres-backup pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER

# Environment variables'ı kontrol et
docker exec -it postgres-backup env | grep PG
```

### SSH Bağlantı Hatası

```bash
# SSH key'i test et
docker exec -it kopia ssh -i /root/.ssh/id_rsa kullanici@uzak-sunucu "echo 'Başarılı!'"

# SSH key izinlerini kontrol et
ls -la ssh-keys/
```

### Yedekleme Başarısız

```bash
# Detaylı logları görüntüle
docker logs postgres-backup --tail 100

# Manuel yedekleme dene
docker exec -it postgres-backup /usr/local/bin/backup-postgres.sh
```

## 📚 Daha Fazla Bilgi

- [Kopia Dokümantasyonu](https://kopia.io/docs/)
- [PostgreSQL pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
- [Docker Compose](https://docs.docker.com/compose/)

## 📝 Lisans

MIT

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır!

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın
