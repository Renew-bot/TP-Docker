// URL de l'API (sera accessible via le réseau Docker)
const API_URL = '/api';

// Fonction pour vérifier le statut de l'API
async function checkStatus() {
    const resultElement = document.getElementById('status-result');
    resultElement.textContent = 'Vérification en cours...';
    resultElement.className = '';
    
    try {
        const response = await fetch(`${API_URL}/status`);
        const data = await response.json();
        
        if (response.ok) {
            resultElement.textContent = `✅ ${data.message}`;
            resultElement.className = 'status-ok';
        } else {
            throw new Error('Erreur de statut');
        }
    } catch (error) {
        resultElement.textContent = `❌ Erreur : ${error.message}`;
        resultElement.className = 'status-error';
    }
}

// Fonction pour charger les éléments
async function loadItems() {
    const container = document.getElementById('items-container');
    container.innerHTML = '<p class="loading">Chargement des éléments...</p>';
    
    try {
        const response = await fetch(`${API_URL}/items`);
        
        if (!response.ok) {
            throw new Error(`Erreur HTTP: ${response.status}`);
        }
        
        const items = await response.json();
        
        if (items.length === 0) {
            container.innerHTML = '<p>Aucun élément à afficher.</p>';
            return;
        }
        
        // Afficher les éléments
        container.innerHTML = items.map(item => `
            <div class="item-card">
                <h3>📦 ${item.name}</h3>
                <p>${item.description}</p>
                <small style="color: #999;">ID: ${item.id}</small>
                <div class="item-actions">
                    <button class="delete-btn" onclick="deleteItem(${item.id})">🗑️ Supprimer</button>
                </div>
            </div>
        `).join('');
        
    } catch (error) {
        container.innerHTML = `
            <div class="error-message">
                <strong>Erreur de chargement</strong><br>
                ${error.message}
            </div>
        `;
    }
}

// Charger automatiquement les éléments au démarrage
window.addEventListener('DOMContentLoaded', () => {
    loadItems();
});

// Fonction pour ajouter un nouvel élément
async function addItem(event) {
    event.preventDefault();
    
    const name = document.getElementById('item-name').value;
    const description = document.getElementById('item-description').value;
    const resultElement = document.getElementById('add-result');
    
    try {
        const response = await fetch(`${API_URL}/items`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name: name,
                description: description
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            resultElement.textContent = `✅ ${data.message}`;
            resultElement.className = 'success';
            
            // Réinitialiser le formulaire
            document.getElementById('add-item-form').reset();
            
            // Recharger la liste après 500ms
            setTimeout(loadItems, 500);
        } else {
            throw new Error(data.error || 'Erreur lors de la création');
        }
    } catch (error) {
        resultElement.textContent = `❌ Erreur : ${error.message}`;
        resultElement.className = 'error';
    }
    
    // Masquer le message après 4 secondes
    setTimeout(() => {
        resultElement.className = '';
    }, 4000);
}

// Fonction pour supprimer un élément
async function deleteItem(itemId) {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer cet élément ?`)) {
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/items/${itemId}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (response.ok) {
            // Recharger la liste
            loadItems();
        } else {
            alert(`Erreur : ${data.error}`);
        }
    } catch (error) {
        alert(`Erreur de suppression : ${error.message}`);
    }
}
