# LLM-Search
## Setup and Installation
To begin experimenting with the working example, you will have to install the following:
1. Ollama
2. Racket
3. Python
4. Other Dependencies
### Ollama
You can download Ollama for your operating system (here)[https://ollama.com/download]. Once you have Ollama installed, you will have to download the llama3 model by entering `ollama pull llama3` in your command line. After that you must create a new model using the scheduler_racket file. To do this enter `ollama create scheduler_racket -f ./scheduler_racket`.
### Racket
Downloadable (here)[https://download.racket-lang.org]
### Python
The API script worked for me on version 3.11.7. I have not tested other versions.
### Other Dependencies
