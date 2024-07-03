# LLM-Search
## Setup and Installation
To begin experimenting with the working example, you will have to install the following:
1. Ollama
2. Racket
3. Python
4. Other Dependencies
### Ollama
You can download Ollama for your operating system [here](https://ollama.com/download). Once you have Ollama installed, you will have to download the llama3 model by entering `ollama pull llama3` in your command line. After that you must create a new model using the scheduler_racket file. To do this enter `ollama create scheduler_racket -f ./scheduler_racket`.
### Racket
Downloadable [here](https://download.racket-lang.org).
### Python
The API script worked for me on version 3.11.7. I have not tested other versions.
### Other Dependencies
Install python requirements using `pip install -r requirements.txt`.
Install `http-easy-lib` and `faster-minikanren` through the racket package manager.
## Motive and Research Goals
The goal of this research is to explore the world of large language models (LLMs) and search. Demis Hassabis, the CEO of DeepMind Technologies, has said that the fastest way to acheive AGI is through LLMs and search trees. Already, methods using Monte Carlo Tree Search have been shown to drastically improve the performance of small models on math and reasoning problems. Search allows LLMs to increase their accuracy by iteratively improving on previous answers and exploring the most promising paths towards a correct solution. While utilizing search necessarily increasing the amount of compute required, the power of these potential architectures could enable for novel medicinal treatments, mathematical proofs, and increased creativity and accuracy across many other domains.

However, this is all granting an LLM the ability to search. What if we gave search the power of an LLM? To do this, we would have to break the data down into a structured format—using an LLM—then pass that information into a searching algorithm that could exhaustively find solutions. This is exactly what is done in the working example provided in this repository. A series of texts are translated into a list structure by a tailored LLM. These lists represent possible schedules for each employee. From there, the schedulero relation is able to generate every possible (or some finite number) of schedules that was previously semantically represented. 

This idea can be extended to other problems such as the famous zebra puzzles (example [here](https://www.brainzilla.com/logic/zebra/ancient-civilizations/)) or crosswords. However, so could the previosly mentioned Monte Carlo Search Tree + LLM architecture. Taking crosswords for example, one could imagine using an LLM to generate possible words matching both the clue given for a word and its length. From there, a searching algorithm could check which combinations of words would fit into the crossword, minding all of the intersections. One could also imagine giving an LLM at once all of the clues, lengths of words, and itersection points and having the LLm give its best attempt at the puzzle. However, the LLM would likely fail on its first attempt. Here, a separate agent would evaluate the previous response, grade its accuracy, and recommend improvements. Iteratively repeating this pattern would gradually increase the accuracy of the answer until the LLM is stumped or it has found a solution.

These two different paths represent a critical step as humanity pursues AGI. Using Monte Carlo Tree Search promises increased accuracy, potential novel solutions, and a broad framework that can be applied to many fields at the expensive of extra compute and latency. Utilizing an LLM within a search presents as an interesting approach to solving structured problems that would have previously required a human to translate texts into a strucutred format at the expensive of having to tune both the LLM and the searching algorithm to each problem.
