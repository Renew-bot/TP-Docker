Voici une version condensée :

---

## Application Docker 3-tiers

**Stack** : Frontend (Nginx) → API (Flask) → Base de données (PostgreSQL)

### Lancement

```bash
docker compose up -d
```

### Endpoints

- `GET /api/status` — état de l'API
- `GET/POST /api/items` — lister/créer des items
- `DELETE /api/items/<id>` — supprimer

### Points clés

- Reverse proxy Nginx pour éviter les erreurs CORS
- Healthchecks et `depends_on` pour l'ordre de démarrage
- Conteneurs non-root, images légères (alpine/slim)
- Données persistantes via volumes

### Accès

- Site : http://localhost
- API : http://localhost/api/status