import random
import math
from collections import defaultdict
import os
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_random_exponential
from dotenv import load_dotenv

MODEL = "gpt-3.5-turbo"

clues = """Joshua is at one of the ends.
        The boy wearing the Black shirt is somewhere to the left of the youngest boy.
        Joshua likes Horror movies.
        The 14-year-old boy is at the third position.
        The boy wearing the Red shirt is somewhere between the 13-year-old boy and the one who likes Action movies, in that order.
        Daniel likes Thriller movies.
        The boy who is going to eat Cookies is at one of the ends.
        The boy wearing the Black shirt is exactly to the left of the one who likes Thriller movies.
        The boy who is going to eat Crackers is exactly to the right of the boy who likes Comedy movies.
        The boy wearing the Red shirt is somewhere between the boy who is going to eat Popcorn and Nicholas, in that order.
        At one of the ends is the boy who likes Thriller movies.
        Nicholas is somewhere between Joshua and Daniel, in that order.
        At the first position is the boy wearing the Green shirt."""

class LLM:
    def __init__(self, model, clues):
        self.model = model
        self.clues = clues
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"),
                organization=os.getenv("OPENAI_ORG_KEY"))
        
    @retry(wait=wait_random_exponential(min=10, max=30),
       stop=stop_after_attempt(25))
    def generate(self, messages, model):
        print(f"calling GPT... model={model}")
        return self.client.chat.completions.create(model=model, messages=messages)

    def ask(self, messages, model):
        response = self.generate(messages, model)
        return response.choices[0].message.content
    
    def firstAttempt(self):
        messages = [
        {
            "role": "system",
            "content": f"""You are an agent whose job is to solve zebra puzzles. For the following puzzle, there are four boys
            each with a shirt color, name, favorite movie genre, snack, and age. 
            Here are the possible options for each category:
            Shirt color: Black, blue, red, green
            Names: Ryan, Nicholas, Daniel, Joshua
            Movie: Comedy, Action, Horror, Thriller
            Snack: Cookies, popcorn, chips, crackers
            Age: 11, 12, 13, 14
            Attempt to solve the whole puzzle at once.
            Do not list out your thoughts. Only output a list of boys with their deduced attributes.
            """
        },
        {
            "role": "user",
            "content": self.clues
        }
        ]
        response = self.ask(messages, self.model)
        return response
    
    def critique(self, answer):
        messages = [
        {
        "role" : "system",
        "content" : f""" You are going to be given an attempted answer to a zebra puzzle and the clues that were
        used to deduce that answer. Your job is to offer critques on the answer about where the 
        answer is logically inconsistent with its clues. Here are the categories and possible values
        for the puzzle:
        Shirt color: Black, blue, red, green
        Names: Ryan, Nicholas, Daniel, Joshua
        Movie: Comedy, Action, Horror, Thriller
        Snack: Cookies, popcorn, chips, crackers
        Age: 11, 12, 13, 14
        Keep your critiques simple. Just point out what attributes are misplaced and what clue they violated
        and how this could be improved."""
        },
        {
        "role" : "user",
        "content" : answer + "\nClues:\n" + self.clues
        }]
        response = self.ask(messages, self.model)
        return response
    
    def score(self, answer, critiques):
        messages = [
            {
                "role" : "system",
                "content" : """Your job is to help me grade an attempted answer to a zebra puzzle.
                I am going to provide you with an answer, a list of critiques, and the clues that led there.
                Take all of this information and use it to output a number from 0 to 100 with 0 being the worst and 100 the best.
                Be sure to evaluate if the critiques are valid.
                Think of the score as a percentage of how many items are correctly placed.
                ONLY OUTPUT A NUMBER AS YOUR RESPONSE. NO COMMENTARY
                Here are the possible options for each category:
                Shirt color: Black, blue, red, green
                Names: Ryan, Nicholas, Daniel, Joshua
                Movie: Comedy, Action, Horror, Thriller
                Snack: Cookies, popcorn, chips, crackers
                Age: 11, 12, 13, 14"""
            },
            {
                "role" : "user",
                "content" : f"Attempted Answer: \n{answer}\nCritiques: \n{critiques}\nClues: \n{self.clues}" 
            }
        ]
        response = self.ask(messages, self.model)
        return int(response) / 100
    
    def refine(self, answer, critiques):
        messages = [
        {
            "role" : "system",
            "content" : f"""Your job is to help me refine my answer to a zebra puzzle. I am going to provide
            you with an attempted solution, a list of critiques, and the clues that led there. Take
            all of that information and output a new and better answer without any commentary.
            Here are the possible options for each category:
            Shirt color: Black, blue, red, green
            Names: Ryan, Nicholas, Daniel, Joshua
            Movie: Comedy, Action, Horror, Thriller
            Snack: Cookies, popcorn, chips, crackers
            Age: 11, 12, 13, 14"""
        },
        {
            "role" : "user",
            "content" : f"Attempted Answer: \n{answer}\nCritiques: \n{critiques}\nClues: \n{self.clues}" 
        }
            ]
        response = self.ask(messages, self.model)
        return response
    
class Node:
    def __init__(self, answer, parent=None):
        self.answer = answer
        self.critiques = ""
        self.parent = parent
        self.children = []
        self.visits = 0
        self.score = 0
        self.llm = LLM(MODEL, clues)
    
    def isFullyExpanded(self):
        return len(self.children) == 2

    def bestChild(self, exploration_param=1.4):
        # Return the child with the highest value, using the UCB1 algorithm
        choices_weights = [
            (child.score / child.visits) + exploration_param * math.sqrt((2 * math.log(self.visits) / child.visits))
            for child in self.children
        ]
        return self.children[choices_weights.index(max(choices_weights))]
    
    def expand(self):
        for _ in range(2):
            refinedAnswer = self.llm.refine(self.answer, self.critiques)
            childNode = Node(refinedAnswer, self)
            self.children.append(childNode)
        return self.children
    
    def isTerminal(self):
        return self.score == 1
    
class MCTS:
    def __init__(self, root):
        self.root = root
        self.llm = LLM(MODEL, clues)

    def select(self, node):
        while not node.isTerminal():
            if not node.isFullyExpanded():
                return node
            else:
                node = node.bestChild()
        return node
    
    def expandAndEvaluate(self, node):
        newNodes = node.expand()
        for newNode in newNodes:
            newNode.critiques = self.llm.critique(newNode.answer)
            newNode.score = self.llm.score(newNode.answer, newNode.critiques)
            newNode.visits = 1
        return newNodes
    
    def backpropagate(self, node, result):
        while node != None:
            node.visits += 1
            node.score += result
            node = node.parent

    def search(self, iterations):
        for _ in range(iterations):
            node = self.select(self.root)
            newNodes = self.expandAndEvaluate(node)
            for newNode in newNodes:
                result = newNode.score
                self.backpropagate(newNode, result)
            print(self.root.bestChild(0).answer,"\n\n")
        return self.root.bestChild(0)

if __name__ == "__main__":
    rootNode = Node(LLM(MODEL, clues).firstAttempt())
    mcts = MCTS(Node("""1. Green shirt, Ryan, Comedy, Chips, 11
                        2. Blue shirt, Joshua, Horror, Popcorn, 14
                        3. Red shirt, Nicholas, Action, Cookies, 13
                        4. Black shirt, Daniel, Thriller, Crackers, 12"""))
    bestNode = mcts.search(5)
    print("Best answer: \n", bestNode.answer,"\n\nScore: ",bestNode.score,"\nVisits: ",bestNode.visits)