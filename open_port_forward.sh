#!/bin/bash

# Pastikan dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
  echo "Script ini harus dijalankan sebagai root!"
  exit 1
fi

show_menu() {
  echo ""
  echo "====== MENU ======"
  echo "1. Tambah Port Forwarding Baru"
  echo "2. Lihat Daftar Port yang Sudah di-Forward"
  echo "3. Keluar"
  echo "=================="
}

add_port_forward() {
  read -p "Masukkan IP tujuan untuk forward (misal 10.8.0.2): " DEST_IP
  read -p "Masukkan port yang ingin dibuka (pisah dengan spasi, contoh: 80 443 8080): " -a PORTS
  read -p "Masukkan nama interface publik (default: eth0): " IFACE
  IFACE=${IFACE:-eth0}
  read -p "Pilih protokol (tcp/udp, default: tcp): " PROTO
  PROTO=${PROTO:-tcp}

  echo "Membuka dan mem-forward port: ${PORTS[@]} ke $DEST_IP lewat $IFACE ($PROTO)..."

  for PORT in "${PORTS[@]}"; do
    echo ">> Membuka port $PORT..."
    iptables -t nat -A PREROUTING -i $IFACE -p $PROTO --dport $PORT -j DNAT --to-destination $DEST_IP:$PORT
    iptables -A FORWARD -p $PROTO -d $DEST_IP --dport $PORT -j ACCEPT
  done

  echo "Selesai. Pastikan IP forwarding aktif: echo 1 > /proc/sys/net/ipv4/ip_forward"
}

show_forwarded_ports() {
  echo ""
  echo "=== Aturan Port Forwarding Saat Ini (iptables -t nat -L PREROUTING -n -v) ==="
  iptables -t nat -L PREROUTING -n -v | grep 'DNAT'
  echo ""
  echo "=== Aturan Forward yang Diizinkan (iptables -L FORWARD -n -v) ==="
  iptables -L FORWARD -n -v | grep 'dpt:'
}

while true; do
  show_menu
  read -p "Pilih menu [1-3]: " MENU

  case $MENU in
    1) add_port_forward ;;
    2) show_forwarded_ports ;;
    3) echo "Keluar."; exit 0 ;;
    *) echo "Pilihan tidak valid!" ;;
  esac
done
