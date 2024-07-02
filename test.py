import random
from langchain_community.llms import Ollama
import ast
from tqdm import tqdm

ollama = Ollama(model='scheduler')

texts = [
    "I'm available Monday through Wednesday, mornings to afternoons. I need Thursday off but can work any time on Friday.",
    "This week I can work any day except for Tuesday. Prefer early shifts if possible!",
    "I'm only available for late shifts this week, Tuesday to Thursday. Out of town the rest of the week.",
    "I can cover any opening shifts you need from Wednesday to Saturday. Need to leave by 3 PM though!",
    "Available all week except for Wednesday morning. Happy to help with the busier shifts!",
    "I can work Monday and Tuesday, no preference for the shift. Then I have a family commitment.",
    "Got a class this week, so I can only do evening shifts on Monday, Wednesday, and Friday.",
    "I'm open to work any day but would prefer not to close. Can stay later on weekends if needed!",
    "This week is tough for me. I can only manage to come in on Thursday and Friday mornings.",
    "I'm flexible with any shifts on Monday, Wednesday, and Friday. Can't work weekends this week.",
    "Happy to take on any shifts from Tuesday to Thursday. I'd like to have the weekend off, though.",
    "Available for opening shifts all week! I'd prefer to stick to mornings as much as possible.",
    "I can work late shifts any day except Wednesday and Sunday. Let me know what you need!",
    "Can't work on Monday and Tuesday due to appointments, but I'm free the rest of the week for any shifts.",
    "I'm mostly available this week but need to leave by 4 PM on weekdays. Weekends are fully open!",
    "I'll be available all week. Prefer busier shifts to keep things interesting, plus happy to open.",
    "Can work any shift on Monday, Wednesday, and Friday. Tuesday and Thursday I'm taking a course.",
    "This week I'm available for any shifts on Tuesday, Thursday, and Saturday. Need to rest on other days.",
    "I prefer to work the earlier part of the week, so Monday to Wednesday, available for any shift times.",
    "I'm mostly open this week! I'd like to avoid closing shifts if possible, but I can be flexible if needed."
]

texts2 = [
    "I'm available all day Monday, Wednesday, and Friday. Can't do weekends though.",
    "I can work Tuesday and Thursday mornings and afternoons, but I need to leave by 5 PM.",
    "I'm free to work any shift on Monday, Wednesday, and Saturday. Let me know if you need me.",
    "I can cover the opening shift every day this week except Thursday. Is that okay?",
    "I'm available Monday through Friday after 2 PM. Can't do mornings.",
    "I can work all day Tuesday and Thursday, and Saturday afternoon.",
    "I'm free to work evenings all week except Wednesday and Friday.",
    "I can do Monday and Tuesday mornings, and all day Thursday. Can't work the weekend.",
    "I have open availability on Monday, Wednesday, and Sunday. Thursday I can only do afternoons.",
    "I'm available to work any shift from Wednesday to Saturday. Monday and Tuesday are off for me.",
    "I can do mornings every day except Friday. Need to leave by noon though.",
    "I'm available all week except for Tuesday and Thursday afternoons.",
    "I can do Monday, Wednesday, and Friday mornings, and all day Saturday.",
    "I'm free every evening this week, but I can't do mornings at all.",
    "I can work any shift on Monday, Tuesday, and Thursday. Not available Friday and Sunday.",
    "I'm available all day Wednesday, Thursday, and Friday. Can't work Monday or Tuesday.",
    "I can do the opening shift every day this week except for Tuesday. Need the afternoon off.",
    "I can work Monday, Wednesday, and Saturday all day. Can't do Thursday.",
    "I'm free every day except for Friday. Need that day off.",
    "I can work mornings and afternoons Monday through Wednesday. Can't do evenings or weekends."
]

shifts = {
    'Monday_morning': [],
    'Monday_evening': [],
    'Tuesday_morning': [],
    'Tuesday_evening': [],
    'Wednesday_morning': [],
    'Wednesday_evening': [],
    'Thursday_morning': [],
    'Thursday_evening': [],
    'Friday_morning': [],
    'Friday_evening': [],
    'Saturday_morning': [],
    'Saturday_evening': [],
    'Sunday_morning': [],
    'Sunday_evening': []
}

expectedShifts1 = {
    'Monday_morning': [1, 2, 5, 6, 8, 10, 12, 15, 16, 17, 19, 20], 
    'Monday_evening': [1, 5, 6, 7, 10, 13, 16, 17, 19], 
    'Tuesday_morning': [1, 5, 6, 8, 11, 12, 15, 16, 18, 19, 20], 
    'Tuesday_evening': [1, 3, 5, 6, 11, 13, 16, 18, 19], 
    'Wednesday_morning': [1, 2, 4, 8, 10, 11, 12, 14, 15, 16, 17, 19, 20], 
    'Wednesday_evening': [1, 3, 5, 7, 10, 11, 14, 16, 17, 19], 
    'Thursday_morning': [2, 4, 5, 8, 9, 11, 12, 14, 15, 16, 18, 20], 
    'Thursday_evening': [3, 5, 11, 13, 14, 16, 18], 
    'Friday_morning': [1, 2, 4, 5, 8, 9, 10, 12, 14, 15, 16, 17, 20], 
    'Friday_evening': [1, 5, 7, 10, 13, 14, 16, 17], 
    'Saturday_morning': [2, 4, 5, 8, 12, 14, 15, 16, 18, 20], 
    'Saturday_evening': [5, 8, 13, 14, 15, 16, 18], 
    'Sunday_morning': [2, 5, 8, 12, 14, 15, 16, 20], 
    'Sunday_evening': [5, 8, 14, 15, 16]}

for i in tqdm(range(len(texts))):
    response = ollama(texts[i])
    response_dict = ast.literal_eval(response)
    for day, (morning, evening) in response_dict.items():
        if morning:
            shifts[f'{day}_morning'].append(i+1)
        if evening:
            shifts[f'{day}_evening'].append(i+1)

for shift, employees in shifts.items():
    try:
        print(shift + ": " + str(random.sample(employees,3)))
    except:
        print(shift + ": Not enough employees!")

print("\nAll Options: ")
for shift, employees in shifts.items():
        print(shift + ": " + str(employees))

print("\nExpected Shifts: ")
for shift, employees in expectedShifts1.items():
        print(shift + ": " + str(employees))
print("\n")

def calculate_similarity(list1, list2):
    set1, set2 = set(list1), set(list2)
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    return intersection / union if union != 0 else 0

similarity_scores = {}
total_similarity = 0
count = 0
for key in expectedShifts1.keys():
    similarity = calculate_similarity(expectedShifts1[key], shifts.get(key, []))
    similarity_scores[key] = similarity
    total_similarity += similarity
    count += 1

# Print the similarity scores
for key, score in similarity_scores.items():
    print(f"Similarity for {key}: {score:.2f}")


# Print average similarity
average_similarity = total_similarity / count if count != 0 else 0
print(f"Average similarity: {average_similarity:.2f}")



