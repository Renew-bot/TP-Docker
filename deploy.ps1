# Usage: .\deploy.ps1 -Action build|deploy|full|stop|clean

param(
    [string]$Action = "help"
)


# VARIABLES DE CONFIGURATION

$PROJECT_NAME = "app-conteneurisee"
$DOCKER_REGISTRY = "docker.io"
$DOCKER_USER = "votreuser"
$VERSION = "1.0.0"

$API_IMAGE = "$DOCKER_USER/$PROJECT_NAME-api:$VERSION"
$FRONTEND_IMAGE = "$DOCKER_USER/$PROJECT_NAME-frontend:$VERSION"

# Couleurs pour les logs
$colors = @{
    "INFO" = "Cyan"
    "SUCCESS" = "Green"
    "WARNING" = "Yellow"
    "ERROR" = "Red"
}

# FONCTIONS UTILITAIRES

function Log-Info {
    param([string]$message)
    Write-Host "[INFO] $message" -ForegroundColor $colors["INFO"]
}

function Log-Success {
    param([string]$message)
    Write-Host "[SUCCESS] $message" -ForegroundColor $colors["SUCCESS"]
}

function Log-Warning {
    param([string]$message)
    Write-Host "[WARNING] $message" -ForegroundColor $colors["WARNING"]
}

function Log-Error {
    param([string]$message)
    Write-Host "[ERROR] $message" -ForegroundColor $colors["ERROR"]
}

# FONCTION : Vérification des prérequis

function Check-Prerequisites {
    Log-Info "Vérification des prérequis..."
    
    # Vérifier Docker
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Log-Error "Docker n'est pas installé"
        exit 1
    }
    
    # Vérifier Docker Compose
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Log-Error "Docker Compose n'est pas disponible"
        exit 1
    }
    
    # Vérifier le fichier .env
    if (-not (Test-Path .env)) {
        Log-Error "Le fichier .env est manquant"
        exit 1
    }
    
    Log-Success "Tous les prérequis sont satisfaits"
}

# FONCTION : Build des images

function Build-Images {
    Log-Info "Construction des images Docker..."
    
    # Build de l'API
    Log-Info "Build de l'API..."
    docker build -t app-api:latest ./api
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Erreur lors du build de l'API"
        exit 1
    }
    docker tag app-api:latest $API_IMAGE
    Log-Success "Image API construite"
    
    # Build du frontend
    Log-Info "Build du frontend..."
    docker build -t app-frontend:latest ./frontend
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Erreur lors du build du frontend"
        exit 1
    }
    docker tag app-frontend:latest $FRONTEND_IMAGE
    Log-Success "Image frontend construite"
    
    # Afficher les images
    Log-Info "Images construites :"
    docker images | Select-String "app-api|app-frontend"
}

# FONCTION : Vérification de la config Compose

function Validate-Compose {
    Log-Info "Validation de docker-compose.yml..."
    docker compose config > $null
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Configuration Docker Compose invalide"
        exit 1
    }
    Log-Success "Configuration Docker Compose valide"
}

# FONCTION : Déploiement de la stack

function Deploy-Stack {
    Log-Info "Déploiement de la stack avec Docker Compose..."
    
    # Arrêter les anciens conteneurs
    Log-Info "Arrêt des anciens conteneurs..."
    docker compose down
    
    # Démarrer la stack
    Log-Info "Démarrage de la stack..."
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Erreur lors du démarrage de la stack"
        exit 1
    }
    
    # Attendre que les services soient prêts
    Log-Info "Attente que les services soient prêts..."
    Start-Sleep -Seconds 5
    
    # Vérifier le statut des services
    Log-Info "Statut des services :"
    docker compose ps
    
    # Afficher les logs des services
    Log-Info "Logs des services (dernières lignes) :"
    docker compose logs --tail=10
    
    Log-Success "Stack déployée avec succès !"
    Log-Info "L'application est accessible sur http://localhost"
}

# FONCTION : Arrêt de la stack

function Stop-Stack {
    Log-Info "Arrêt de la stack..."
    docker compose down
    Log-Success "Stack arrêtée"
}

# FONCTION : Nettoyage complet

function Clean-All {
    Log-Warning "Nettoyage complet (suppression des volumes)..."
    $response = Read-Host "Êtes-vous sûr ? Cette action supprimera toutes les données. (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        docker compose down -v
        docker rmi -f app-api:latest app-frontend:latest 2>$null
        Log-Success "Nettoyage terminé"
    } else {
        Log-Info "Nettoyage annulé"
    }
}

# FONCTION : Afficher l'aide

function Show-Help {
    Write-Host "Usage: .\deploy.ps1 -Action <COMMAND>"
    Write-Host ""
    Write-Host "Commandes disponibles :"
    Write-Host "  build      - Construire les images Docker"
    Write-Host "  validate   - Valider la configuration Docker Compose"
    Write-Host "  deploy     - Déployer la stack avec Docker Compose"
    Write-Host "  full       - Exécuter toutes les étapes (build + validate + deploy)"
    Write-Host "  stop       - Arrêter la stack"
    Write-Host "  clean      - Nettoyer complètement (conteneurs + volumes + images)"
    Write-Host "  help       - Afficher cette aide"
    Write-Host ""
    Write-Host "Exemple : .\deploy.ps1 -Action full"
}

# FONCTION PRINCIPALE

switch ($Action.ToLower()) {
    "build" {
        Check-Prerequisites
        Build-Images
    }
    "validate" {
        Check-Prerequisites
        Validate-Compose
    }
    "deploy" {
        Check-Prerequisites
        Validate-Compose
        Deploy-Stack
    }
    "full" {
        Check-Prerequisites
        Build-Images
        Validate-Compose
        Deploy-Stack
    }
    "stop" {
        Stop-Stack
    }
    "clean" {
        Clean-All
    }
    "help" {
        Show-Help
    }
    default {
        Log-Error "Commande inconnue : $Action"
        Show-Help
        exit 1
    }
}
