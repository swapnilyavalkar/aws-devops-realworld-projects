from flask import Flask
import psycopg2

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Flask with PostgreSQL in Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
