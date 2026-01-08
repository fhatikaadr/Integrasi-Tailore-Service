# 🐳 Docker Deployment Guide - Tailoré Integration Service

Panduan lengkap untuk deploy aplikasi ke STB menggunakan Docker.

---

## 📋 Prerequisites

- Docker Desktop (untuk Windows/Mac) atau Docker Engine (untuk Linux)
- Docker Hub account (gratis di https://hub.docker.com)
- Git
- Akses ke server aaPanel (STB)

---

## 🖥️ PART 1: Setup di VSCode (Lokal)

### 1. File yang Sudah Dibuat

✅ `Dockerfile` - Multi-stage build untuk optimasi size  
✅ `.env.example` - Template environment variables  
✅ `.dockerignore` - File yang tidak masuk ke Docker image  
✅ `pull-and-run.sh` - Script otomatis deployment

### 2. Setup Environment

Copy `.env.example` ke `.env` dan sesuaikan jika perlu:

```bash
cp .env.example .env
```

**Isi .env:**
```env
PORT=5000
CATALOG_URL=https://ooga.queenifyofficial.site/api
ORDER_URL=https://cimol.queenifyofficial.site/api
NODE_ENV=production
```

### 3. Push ke GitHub

```bash
git add .
git commit -m "Add Docker deployment files"
git push
```

---

## 💻 PART 2: Build & Push Image (CMD Windows)

### 1. Login ke Docker Hub

```cmd
docker login
```

Masukkan username dan password Docker Hub kamu.

### 2. Setup Docker Buildx (Multi-platform)

```cmd
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
```

Ini untuk build image yang bisa jalan di berbagai platform (Windows, Linux, ARM).

### 3. Build dan Push Image

Ganti `fhatikaadr` dengan username Docker Hub kamu:

```cmd
cd C:\Users\tika\Downloads\Integrasi-Tailore-Service

docker buildx build --platform linux/amd64,linux/arm64 ^
  -t fhatikaadr/tailore-integration-service:latest ^
  --push .
```

**Penjelasan:**
- `--platform linux/amd64,linux/arm64` = Build untuk Intel/AMD dan ARM processor
- `-t fhatikaadr/tailore-integration-service:latest` = Tag image
- `--push` = Langsung push ke Docker Hub setelah build
- `.` = Build dari directory saat ini

### 4. Verifikasi di Docker Hub

Buka https://hub.docker.com dan cek repository kamu. Harusnya ada image baru dengan nama `tailore-integration-service`.

---

## 🚀 PART 3: Deploy di Server aaPanel

### 1. Connect ke Server

Login ke server via SSH atau terminal aaPanel.

### 2. Masuk ke Directory

```bash
cd /www/wwwroot
```

### 3. Clone Repository

Ganti URL dengan URL repository kamu:

```bash
git clone https://github.com/fhatikaadr/Integrasi-Tailore-Service.git
```

### 4. Masuk ke Directory Project

```bash
cd Integrasi-Tailore-Service
```

### 5. Setup Environment

```bash
cp .env.example .env
nano .env
```

Edit jika perlu, lalu save (Ctrl+X, Y, Enter).

### 6. Buat Script Executable

```bash
chmod +x pull-and-run.sh
```

### 7. Jalankan Deployment

```bash
./pull-and-run.sh
```

Script ini akan otomatis:
- ✅ Cek Docker terinstall
- ✅ Cek Docker service running
- ✅ Setup environment
- ✅ Stop & remove container lama
- ✅ Pull image terbaru dari Docker Hub
- ✅ Run container baru
- ✅ Test status aplikasi

### 8. Output yang Diharapkan

```
========================================
Tailore Integration Service Deployment
========================================

[1/7] Checking Docker installation...
✓ Docker is installed

[2/7] Checking Docker service...
✓ Docker is running

[3/7] Setting up environment...
✓ .env already exists

[4/7] Removing old container...
✓ Old container removed

[5/7] Pulling latest image from Docker Hub...
✓ Image pulled successfully

[6/7] Starting new container...
✓ Container started successfully

[7/7] Testing application status...
✓ Container is running
✓ Application is responding (HTTP 200)

========================================
Deployment Summary
========================================
Container Name: tailore-service
Image: fhatikaadr/tailore-integration-service:latest
Port: 5000
Status: Running
URL: http://localhost:5000

✓ Deployment completed successfully!
```

---

## 🔧 PART 4: Setup Port di aaPanel

### 1. Buka aaPanel Dashboard

### 2. Masuk ke Website Settings

Website → Nama domain kamu → Settings

### 3. Add Reverse Proxy

- **Proxy Name**: Tailore Service
- **Target URL**: http://127.0.0.1:5000
- **Enable**: Yes

### 4. Atau Add Port Mapping

Security → Firewall → Add Rule:
- **Port**: 5000
- **Protocol**: TCP
- **Source**: Any (atau specific IP untuk security)

---

## 📱 Docker Commands Berguna

### Cek Status Container

```bash
docker ps
```

### Lihat Logs

```bash
docker logs tailore-service
docker logs -f tailore-service  # Follow mode (real-time)
```

### Stop Container

```bash
docker stop tailore-service
```

### Start Container

```bash
docker start tailore-service
```

### Restart Container

```bash
docker restart tailore-service
```

### Hapus Container

```bash
docker stop tailore-service
docker rm tailore-service
```

### Masuk ke Container (Debug)

```bash
docker exec -it tailore-service sh
```

### Update ke Versi Terbaru

Cukup jalankan lagi script:

```bash
./pull-and-run.sh
```

---

## 🔄 Update Workflow

Setiap kali ada perubahan code:

**1. Di VSCode:**
```bash
git add .
git commit -m "Update feature"
git push
```

**2. Di CMD (Build ulang):**
```cmd
docker buildx build --platform linux/amd64,linux/arm64 ^
  -t fhatikaadr/tailore-integration-service:latest ^
  --push .
```

**3. Di Server aaPanel:**
```bash
cd /www/wwwroot/Integrasi-Tailore-Service
git pull
./pull-and-run.sh
```

---

## 🐛 Troubleshooting

### Container tidak mau start

```bash
docker logs tailore-service
```

### Port sudah dipakai

```bash
# Cek port yang dipakai
netstat -tulpn | grep :5000

# Atau ganti port di .env
nano .env
# Ubah PORT=5000 ke PORT=5001
```

### Image tidak bisa di-pull

```bash
# Cek koneksi Docker Hub
docker pull hello-world

# Login ulang
docker logout
docker login
```

### Permission denied saat run script

```bash
chmod +x pull-and-run.sh
```

### Docker tidak terinstall di server

```bash
# Install Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 📊 Monitoring

### Check Memory Usage

```bash
docker stats tailore-service
```

### Check Container Health

```bash
docker inspect --format='{{.State.Health.Status}}' tailore-service
```

### Auto-restart Policy

Container sudah dikonfigurasi dengan `--restart unless-stopped`, jadi akan otomatis restart kalau:
- Server reboot
- Container crash
- Docker service restart

---

## 🔐 Security Tips

1. **Jangan commit .env ke Git** (sudah di .gitignore)
2. **Gunakan environment variables** untuk data sensitif
3. **Limit port access** di firewall
4. **Regular update** Docker image dengan security patches
5. **Use non-root user** di container (sudah dikonfigurasi di Dockerfile)

---

## 📞 Support

Jika ada masalah:

1. Cek logs: `docker logs tailore-service`
2. Cek status: `docker ps -a`
3. Restart container: `docker restart tailore-service`
4. Rebuild image dan push ulang
5. Re-run deployment script

---

## ✅ Checklist Deployment

**VSCode (Lokal):**
- [ ] Dockerfile created
- [ ] .env.example created
- [ ] pull-and-run.sh created
- [ ] .dockerignore created
- [ ] Git push semua file

**CMD (Build):**
- [ ] Docker login
- [ ] Docker buildx setup
- [ ] Build & push image
- [ ] Verify di Docker Hub

**aaPanel (Deploy):**
- [ ] Clone repository
- [ ] Setup .env
- [ ] chmod +x script
- [ ] Run pull-and-run.sh
- [ ] Verify container running
- [ ] Setup port di aaPanel
- [ ] Test dari browser

---

**Last Updated**: January 8, 2026  
**Docker Image**: fhatikaadr/tailore-integration-service:latest
