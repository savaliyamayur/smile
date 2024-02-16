from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello_smile():
    return jsonify({"message": "Hello Smile"})

if __name__ == '__main__':
    app.run(debug=True)

