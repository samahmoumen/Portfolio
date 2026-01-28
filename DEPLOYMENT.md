

## **DEPLOYMENT.md**

## Pré-requis

* Une VM Ubuntu/Debian avec accès SSH
* Docker et Docker Compose installés
* Accès à Internet pour pull des images (ou clone du repo)
* `.env.exemple` présent dans le repo (à copier en `.env` sur la VM)
* Optionnel : nom de domaine et certificat SSL pour HTTPS

---

## Étapes de déploiement

### 1️⃣ Se connecter à la VM

```bash
ssh tython@135.125.4.184 -p 2702
```

---

### 2️⃣ Créer un dossier pour le projet

```bash
mkdir -p ~/portfolio
cd ~/portfolio
```

---

### 3️⃣ Cloner ou mettre à jour le dépôt

```bash
if [ -d .git ]; then
    git pull
else
    git clone https://github.com/samahmoumen/Portfolio.git .
fi
```

---

### 4️⃣ Configurer les variables d’environnement

```bash
cp .env.exemple .env
nano .env      # puis modifier les valeurs si besoin (PORT, API_URL, DB credentials…)
```


---

### 5️⃣ Lancer l’application avec Docker Compose

```bash
docker compose -f docker-compose.prod.yml up -d
```

* `-d` → mode détaché
* Vérifier que les containers tournent :

```bash
docker ps
docker inspect --format='{{json .State.Health}}' portfolio
docker logs -f portfolio
```

---

### 6️⃣ Accéder à l’application

* Frontend exposé sur le port défini dans `.env` (`PORT`), par exemple :

```
http://135.125.4.184:2702
```



---

### 7️⃣ Mettre à jour l’application

Lorsqu’une nouvelle version est disponible :

```bash
cd ~/portfolio
git pull
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
docker system prune -f
```

---

### 8️⃣ Bonnes pratiques

* Ajouter `restart: unless-stopped` dans `docker-compose.prod.yml` pour redémarrage automatique après reboot
* Configurer firewall :

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

* Backup base de données si utilisée (Postgres) :

```bash
docker exec -t db pg_dumpall -c -U user > dump_$(date +%F).sql
```

* Observabilité minimale :

    * Logs Docker avec rotation (`max-size`, `max-file`)
    * Healthcheck défini dans `docker-compose.prod.yml`
    * Optionnel : Prometheus + Grafana ou Netdata pour monitoring léger

* Sécurité minimale :

    * `.env` séparé de GitHub
    * Ports exposés uniquement nécessaires
    * Reverse proxy Nginx avec headers sécurité et rate limiting
    * HTTPS via Let’s Encrypt (bonus)

---

