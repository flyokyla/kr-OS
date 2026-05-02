# Deploy kr-OS

Сайт публикуется по `https://<SERVER_IP>:8443` через хостовый nginx,
проксирующий на docker-контейнер на `127.0.0.1:8088`.
Сертификат самоподписанный (браузер покажет предупреждение — это норма).

## 1. Подтянуть код на сервере
```bash
cd /home/<...>/kr-OS   # или где у тебя клон
git pull
```

## 2. Поднять контейнер
```bash
docker compose up -d --build
docker ps | grep kr-os
curl -I http://127.0.0.1:8088/   # должно быть 200 OK
```

## 3. Самоподписанный сертификат (один раз)
Подставь свой публичный IP вместо `SERVER_IP`:
```bash
sudo mkdir -p /etc/nginx/ssl/kros
SERVER_IP=$(curl -s https://api.ipify.org)
echo "IP: $SERVER_IP"

sudo openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
  -keyout /etc/nginx/ssl/kros/privkey.pem \
  -out    /etc/nginx/ssl/kros/fullchain.pem \
  -subj   "/CN=$SERVER_IP" \
  -addext "subjectAltName=IP:$SERVER_IP"

sudo chmod 600 /etc/nginx/ssl/kros/privkey.pem
```

## 4. nginx server-блок
```bash
sudo cp deploy/nginx-kros.conf /etc/nginx/sites-available/kros
sudo ln -s /etc/nginx/sites-available/kros /etc/nginx/sites-enabled/kros

sudo nginx -t          # ОБЯЗАТЕЛЬНО — проверка перед reload
sudo systemctl reload nginx
```

Если `nginx -t` ругнётся — НЕ делай reload, сначала исправь. Текущие сайты
продолжают работать на старом конфиге, пока reload не выполнен.

## 5. Открыть порт в firewall (если ufw активен)
```bash
sudo ufw status
# если active:
sudo ufw allow 8443/tcp
```
У провайдера (если есть внешний firewall типа Hetzner/Selectel/AWS SG) —
тоже открыть TCP 8443 на входящие.

## 6. Проверка
```bash
curl -kI https://127.0.0.1:8443/      # с сервера
# в браузере: https://<SERVER_IP>:8443/
```

## Откат (если что-то пошло не так)
```bash
sudo rm /etc/nginx/sites-enabled/kros
sudo nginx -t && sudo systemctl reload nginx
docker compose down
```
Существующие сайты не пострадают — мы не редактировали их конфиги.

## Обновление сайта потом
```bash
git pull
docker compose up -d --build
```
