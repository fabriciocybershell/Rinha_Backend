
from flask import Flask, jsonify, request
import psycopg2
import os

app = Flask(__name__)

DB_HOSTNAME = os.environ.get("DB_HOSTNAME", "localhost")
DB_NAME = os.environ.get("DB_NAME", "rinha")
DB_USER = os.environ.get("DB_USER", "rinha")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "rinha")

def get_db_connection():
    conn = psycopg2.connect(host=DB_HOSTNAME, database=DB_NAME, user=DB_USER, password=DB_PASSWORD)
    return conn

@app.route("/", methods=["GET"])
def hello_world():
    return jsonify(message="Hello from Guardiao's Backend!")

@app.route("/clientes/<int:id>/extrato", methods=["GET"])
def get_extrato(id):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT saldo FROM saldos WHERE cliente_id = %s", (id,))
        saldo = cur.fetchone()
        if saldo:
            return jsonify(saldo=saldo[0])
        else:
            return jsonify(message="Cliente não encontrado"), 404
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        if conn:
            cur.close()
            conn.close()

@app.route("/clientes/<int:id>/transacoes", methods=["POST"])
def create_transacao(id):
    data = request.get_json()
    valor = data.get("valor")
    tipo = data.get("tipo")
    descricao = data.get("descricao")

    if not all([valor, tipo, descricao]):
        return jsonify(message="Dados inválidos"), 422

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO transacoes (cliente_id, valor, tipo, descricao) VALUES (%s, %s, %s, %s)",
                    (id, valor, tipo, descricao))
        conn.commit()
        return jsonify(message="Transação criada com sucesso"), 201
    except Exception as e:
        conn.rollback()
        return jsonify(error=str(e)), 500
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

