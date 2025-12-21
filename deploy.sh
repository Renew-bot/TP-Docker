# Usage: ./deploy.sh [build|deploy|full|stop|clean]

set -e  # Arrêter le script en cas d'erreur

# VARIABLES DE CONFIGURATION

PROJECT_NAME="app-conteneurisee"
DOCKER_REGISTRY="docker.io"
DOCKER_USER="votreuser"
VERSION="1.0.0"

API_IMAGE="${DOCKER_USER}/${PROJECT_NAME}-api:${VERSION}"
FRONTEND_IMAGE="${DOCKER_USER}/${PROJECT_NAME}-frontend:${VERSION}"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# FONCTIONS UTILITAIRES

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# FONCTION : Vérification des prérequis

check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    # Vérifier le fichier .env
    if [ ! -f .env ]; then
        log_error "Le fichier .env est manquant"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# FONCTION : Build des images

build_images() {
    log_info "Construction des images Docker..."
    
    # Build de l'API
    log_info "Build de l'API..."
    docker build -t app-api:latest ./api
    docker tag app-api:latest ${API_IMAGE}
    log_success "Image API construite"
    
    # Build du frontend
    log_info "Build du frontend..."
    docker build -t app-frontend:latest ./frontend
    docker tag app-frontend:latest ${FRONTEND_IMAGE}
    log_success "Image frontend construite"
    
    # Afficher les images
    log_info "Images construites :"
    docker images | grep -E "app-api|app-frontend"
}

# FONCTION : Vérification de la config Compose

validate_compose() {
    log_info "Validation de docker-compose.yml..."
    docker compose config > /dev/null
    log_success "Configuration Docker Compose valide"
}

# FONCTION : Déploiement de la stack

deploy_stack() {
    log_info "Déploiement de la stack avec Docker Compose..."
    
    # Arrêter les anciens conteneurs
    log_info "Arrêt des anciens conteneurs..."
    docker compose down
    
    # Démarrer la stack
    log_info "Démarrage de la stack..."
    docker compose up -d
    
    # Attendre que les services soient prêts
    log_info "Attente que les services soient prêts..."
    sleep 5
    
    # Vérifier le statut des services
    log_info "Statut des services :"
    docker compose ps
    
    # Afficher les logs des services
    log_info "Logs des services (dernières lignes) :"
    docker compose logs --tail=10
    
    log_success "Stack déployée avec succès !"
    log_info "L'application est accessible sur http://localhost"
}

# FONCTION : Arrêt de la stack

stop_stack() {
    log_info "Arrêt de la stack..."
    docker compose down
    log_success "Stack arrêtée"
}

# FONCTION : Nettoyage complet

clean_all() {
    log_warning "Nettoyage complet (suppression des volumes)..."
    read -p "Êtes-vous sûr ? Cette action supprimera toutes les données. (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down -v
        docker rmi -f app-api:latest app-frontend:latest 2>/dev/null || true
        log_success "Nettoyage terminé"
    else
        log_info "Nettoyage annulé"
    fi
}

# FONCTION : Afficher l'aide

show_help() {
    echo "Usage: ./deploy.sh [COMMAND]"
    echo ""
    echo "Commandes disponibles :"
    echo "  build      - Construire les images Docker"
    echo "  validate   - Valider la configuration Docker Compose"
    echo "  deploy     - Déployer la stack avec Docker Compose"
    echo "  full       - Exécuter toutes les étapes (build + validate + deploy)"
    echo "  stop       - Arrêter la stack"
    echo "  clean      - Nettoyer complètement (conteneurs + volumes + images)"
    echo "  help       - Afficher cette aide"
    echo ""
    echo "Exemple : ./deploy.sh full"
}

# FONCTION PRINCIPALE

main() {
    case "$1" in
        build)
            check_prerequisites
            build_images
            ;;
        validate)
            check_prerequisites
            validate_compose
            ;;
        deploy)
            check_prerequisites
            validate_compose
            deploy_stack
            ;;
        full)
            check_prerequisites
            build_images
            validate_compose
            deploy_stack
            ;;
        stop)
            stop_stack
            ;;
        clean)
            clean_all
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Commande inconnue : $1"
            show_help
            exit 1
            ;;
    esac
}

# POINT D'ENTRÉE

if [ $# -eq 0 ]; then
    log_error "Aucune commande spécifiée"
    show_help
    exit 1
fi

main "$1"
