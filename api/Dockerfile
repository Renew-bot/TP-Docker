# ÉTAPE 1 : BUILD (Installation des dépendances)

FROM python:3.11-slim AS builder

WORKDIR /app

# Copier uniquement requirements.txt d'abord (optimisation du cache)
COPY requirements.txt .

# Installer les dépendances dans un dossier local
RUN pip install --no-cache-dir --user -r requirements.txt

# ÉTAPE 2 : PRODUCTION (Image légère)

FROM python:3.11-slim

WORKDIR /app

# Créer un utilisateur non-root
RUN useradd -m -u 1000 appuser

# Copier les dépendances depuis l'étape précédente
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copier le code de l'application
COPY --chown=appuser:appuser app.py .

# Passer à l'utilisateur non-root
USER appuser

# Ajouter les binaires Python au PATH
ENV PATH=/home/appuser/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH
ENV PYTHONPATH=/home/appuser/.local/lib/python3.11/site-packages:$PYTHONPATH

# Exposer le port
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/status')"

# Lancer l'application avec Gunicorn
CMD ["/home/appuser/.local/bin/gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
