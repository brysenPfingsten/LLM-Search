from flask import Flask, request, jsonify
from langchain_community.llms import Ollama

app = Flask(__name__)

# Initialize your Ollama model
model = Ollama(model='scheduler_racket')

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    prompt = data['prompt']
    # Generate a response using the Ollama model
    response_text = model(prompt)
    # Return the response as JSON
    return jsonify({'response': response_text})

if __name__ == '__main__':
    app.run(host='localhost', port=5000)