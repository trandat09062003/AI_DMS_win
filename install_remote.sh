#!/bin/bash
# Script to install AnyDesk on Ubuntu

echo "[INFO] Dang tai va cau hinh khoa bao mat AnyDesk..."
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg

echo "[INFO] Them kho luu tru AnyDesk..."
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

echo "[INFO] Cap nhat he thong va cai dat AnyDesk..."
sudo apt update
sudo apt install -y anydesk

echo "[SUCCESS] AnyDesk da duoc cai dat thanh cong!"
echo "[INFO] Ban co the tim 'anydesk' trong ung dung hoac chay lenh: anydesk"
