# V2 Tasks:
# 1.Adding an automatic system for Id and Date info.
# 2.Removing the'deleted'message.
# 3.Missing data error handling
import sys
import os
from datetime import datetime

def help_message():
    print("\nCommands: open, add, list, delete, find, update")

def initialize_system():
    if not os.path.exists(".minirecipe"):
        os.mkdir(".minirecipe")
        print("System started. .minirecipe folder created.")
    else:
        print("Already initialized")

def add_recipe():
    if not os.path.exists(".minirecipe"):
        print("Not initialized, run: python minirecipe.py open")
        return

    title = input("Title (Recipe Name): ")
    ingredients = input("Ingredients: ")
    description = input("Description: ")

    # Error Handling: Check if any field is empty
    if not title or not ingredients or not description:
        print("Enter in the correct format(Title|Ingredients|Description).")
        return

    # Automatic ID Calculation
    recipe_id = 1
    if os.path.exists(".minirecipe/recipes.dat"):
        temp_file = open(".minirecipe/recipes.dat",
"r", encoding="utf-8")
        recipe_id = len(temp_file.readlines()) + 1
        temp_file.close()

    # Automatic Date
    current_date = datetime.now().strftime("%Y-%m-%d")

    # Format: Id|Title|Ingredients|Description|Date
    data = f"{recipe_id}|{title}|{ingredients}|{description}|{current_date}\n"

    file = open(".minirecipe/recipes.dat",
"a", encoding="utf-8")
    file.write(data)
    file.close()
    print(f"Added recipe #{recipe_id}")

def list_recipes():
    if os.path.exists(".minirecipe/recipes.dat"):
        file = open(".minirecipe/recipes.dat",
"r", encoding="utf-8")
        content = file.read()
        file.close()
        
        if content.strip() == "":
            print("No recipe found.")
        else:
            print("\n--- All Recipes ---")
            print(content)
    else:
        print("No recipe found.")

def find_recipe():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("File not found.")
        return
        
    search_term = input("Search for keyword (title or ingredient): ")
    file = open(".minirecipe/recipes.dat",
"r", encoding="utf-8")
    lines = file.readlines()
    file.close()
    
    found = False
    for line in lines:
        if search_term in line:
            details = line.strip().split("|")
            print("\n--- Recipe Found ---")
            print(f"ID: {details[0]}")
            print(f"Title: {details[1]}")
            print(f"Ingredients: {details[2]}")
            print(f"Description: {details[3]}")
            print(f"Date: {details[4]}")
            found = True
    
    if not found:
        print("No recipe found")

def delete_recipe():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("File not found.")
        return

    target = input("Enter the ID or Name of the recipe to delete: ")
    file = open(".minirecipe/recipes.dat",
"r", encoding="utf-8")
    lines = file.readlines()
    file.close()

    # Complete Deletion: Rewrite file without the target line
    new_lines = []
    found = False
    for line in lines:
        if target not in line:
            new_lines.append(line)
        else:
            found = True

    if found:
        file = open(".minirecipe/recipes.dat",
"w", encoding="utf-8")
        file.writelines(new_lines)
        file.close()
        print(f"'{target}' has been completely deleted.")
    else:
        print("Selected recipe does not exists.")

def update_recipe():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("File not found.")
        return

    old_name = input("Enter the name of the recipe to update: ")
    file = open(".minirecipe/recipes.dat",
"r", encoding="utf-8")
    content = file.read()
    file.close()

    if old_name in content:
        new_title = input("New Title: ")
        new_ingredients = input("New Ingredients: ")
        new_description = input("New Description: ")
        
        # Simple update: replace the old title/part with new info
        updated_content = content.replace(old_name, new_title)
        
        file = open(".minirecipe/recipes.dat",
"w", encoding="utf-8")
        file.write(updated_content)
        file.close()
        print("Recipe updated successfully.")
    else:
        print("Please select a recipe first")

def main():
    print("\n--- Project: Mini-Recipe V1 ---")
    cmd = input("Enter command (open, add, list, find, delete, update): ")

    if cmd == "open":
        initialize_system()
    elif cmd == "add":
        add_recipe()
    elif cmd == "list":
        list_recipes()
    elif cmd == "find":
        find_recipe()
    elif cmd == "delete":
        delete_recipe()
    elif cmd == "update":
        update_recipe()
    else:
        print("Invalid Command, please enter a valid one")

if __name__ == "__main__":
    main()
