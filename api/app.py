from flask import Flask, jsonify, request
import psycopg2
import os

app = Flask(__name__)

# Récupération des variables d'environnement
DB_HOST = os.getenv('DB_HOST', 'db')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'appdb')
DB_USER = os.getenv('DB_USER', 'appuser')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'apppassword')
API_PORT = int(os.getenv('API_PORT', '5000'))

# Fonction pour se connecter à la base de données
def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    return conn

# Route /status
@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "OK", "message": "API is running"}), 200

# Route /items
@app.route('/items', methods=['GET'])
def get_items():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, name, description FROM items;')
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        items = []
        for row in rows:
            items.append({
                "id": row[0],
                "name": row[1],
                "description": row[2]
            })
        
        return jsonify(items), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route POST /items - Créer un nouvel item
@app.route('/items', methods=['POST'])
def create_item():
    try:
        data = request.get_json()
        
        # Vérifier que les champs obligatoires sont présents
        if not data or 'name' not in data:
            return jsonify({"error": "Le champ 'name' est obligatoire"}), 400
        
        name = data.get('name')
        description = data.get('description', '')
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO items (name, description) VALUES (%s, %s) RETURNING id, name, description;',
            (name, description)
        )
        result = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            "id": result[0],
            "name": result[1],
            "description": result[2],
            "message": "Item créé avec succès"
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route DELETE /items/<id> - Supprimer un item
@app.route('/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Vérifier que l'item existe
        cur.execute('SELECT id FROM items WHERE id = %s;', (item_id,))
        if not cur.fetchone():
            cur.close()
            conn.close()
            return jsonify({"error": "Item non trouvé"}), 404
        
        # Supprimer l'item
        cur.execute('DELETE FROM items WHERE id = %s;', (item_id,))
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"message": f"Item {item_id} supprimé avec succès"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=API_PORT)
