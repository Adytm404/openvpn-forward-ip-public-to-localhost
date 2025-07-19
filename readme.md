# 📡 OpenVPN Server + Port Forwarding via iptables

## 🌐 Syarat Minimal Server
- VPS dengan **dedicated IP publik**
- **Jangan** gunakan VPS NAT tanpa IP publik

---

## 🛠️ Cara Install OpenVPN di Linux

### 1. Login ke VPS sebagai root 
```bash
ssh root@IP_VPS_KAMU
```

### 2. Download OpenVPN Installer
```bash
wget https://git.io/vpn -O openvpn-install.sh
```

### 3. Jalankan Installer
```bash
bash openvpn-install.sh
```

> Saat proses install:
> - Pilih protokol (misal: **UDP**)
> - Pilih port (misal: **1194**)
> - Masukkan nama client (misal: **homeserver**)

Setelah selesai:
- File konfigurasi `.ovpn` akan dibuat (contoh: `homeserver.ovpn`)
- NAT IP akan dibuat otomatis, seperti:
  - `10.8.0.1` → Server OpenVPN
  - `10.8.0.2` → Client pertama (homeserver)
  - `10.8.0.3` → Client kedua
  - dst.

---

## 🔁 Port Forwarding Menggunakan `iptables`

### Port TCP 80 (HTTP)
```bash
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j DNAT --to 10.8.0.2:80
iptables -A FORWARD -p tcp -d 10.8.0.2 --dport 80 -j ACCEPT
```

### Port TCP 443 (HTTPS)
```bash
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j DNAT --to 10.8.0.2:443
iptables -A FORWARD -p tcp -d 10.8.0.2 --dport 443 -j ACCEPT
```

### Port UDP 53 (DNS)
```bash
iptables -A PREROUTING -t nat -i eth0 -p udp --dport 53 -j DNAT --to 10.8.0.2:53
iptables -A FORWARD -p udp -d 10.8.0.2 --dport 53 -j ACCEPT
```

> 🔧 Ganti `eth0` dengan nama interface kamu (cek dengan `ip addr`)

---

## 🏠 Koneksi Homeserver ke OpenVPN Server

### 1. Salin file `.ovpn` dari VPS ke homeserver
```bash
scp root@111.112.113.114:/root/homeserver.ovpn ./
```

### 2. Koneksi ke OpenVPN dari homeserver
```bash
openvpn --config homeserver.ovpn
```

### 3. Agar auto-connect saat boot
Tambahkan ke cron:
```bash
crontab -e
```

Lalu isi:
```bash
@reboot /usr/sbin/openvpn --config /root/homeserver.ovpn
```

---

## ⚙️ Menambahkan dan Mengecek Port Forward via Script

Gunakan script `open_port_forward.sh` untuk mempermudah:

### 📥 1. Unduh / Buat Script
Simpan script di file `open_port_forward.sh` (lihat di bagian script sebelumnya)

### 🔓 2. Ubah Permission agar bisa dieksekusi
```bash
chmod +x open_port_forward.sh
```

### ▶️ 3. Jalankan script
```bash
sudo ./open_port_forward.sh
```

### 🧭 Menu Script:
1. Tambah port forward baru
2. Lihat daftar port yang sudah di-forward
3. Keluar

> Script ini mendukung protokol TCP/UDP dan bisa memasukkan beberapa port sekaligus.

---

## 📌 Tips Tambahan
- Aktifkan IP forwarding di server:
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

Atau permanenkan via `/etc/sysctl.conf`:
```
net.ipv4.ip_forward = 1
```

---

## 🔒 Pastikan Keamanan
Jangan lupa menambahkan firewall atau pembatasan IP jika port yang dibuka bersifat sensitif.
