"""
PROJECT: mini-bookmark V3
AUTHOR: Hüdanur Şener (251478066)
DATE: 2026-04-20

V2 TASK LIST:
1. 'list' command completed: Displays all records in a formatted table.
2. 'delete' command implemented: Added logic to remove a record by ID.
3. URL Validation: Added a check to ensure links start with 'http'.
"""

import sys
import os

# Data storage paths [cite: 14]
DB_DIR = ".minibookmark"
DB_FILE = os.path.join(DB_DIR, "links.dat")


def init():
    """Initializes the project and creates necessary directory/file[cite: 15]."""
    if os.path.exists(DB_DIR):
        print("Already initialized.")
    else:
        os.makedirs(DB_DIR)
        open(DB_FILE, "w").close()
        print("Project initialized.")


def add(title, url):
    """Adds a new bookmark with URL validation[cite: 16]."""
    if not url.startswith("http"):
        print("Error: URL must start with 'http' or 'https'.")
        return

    if not os.path.exists(DB_DIR):
        print("Not initialized. Run: python minibookmark.py init")
        return

    try:
        with open(DB_FILE, "r") as f:
            lines = f.readlines()
            new_id = len(lines) + 1
    except FileNotFoundError:
        new_id = 1

    date_str = "2026-04-20"
    entry = f"{new_id}|{title}|{url}|{date_str}\n"

    with open(DB_FILE, "a") as f:
        f.write(entry)
    print(f"Added bookmark #{new_id}: {title}")


def list_bookmarks():
    """V2: Lists all saved bookmarks in a clean format."""
    if not os.path.exists(DB_FILE) or os.path.getsize(DB_FILE) == 0:
        print("No bookmarks found.")
        return

    # Table Header
    print(f"{'ID':<4} | {'TITLE':<20} | {'URL':<30} | {'DATE'}")
    print("-" * 75)
    with open(DB_FILE, "r") as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) == 4:
                print(f"{parts[0]:<4} | {parts[1]:<20} | {parts[2]:<30} | {parts[3]}")


def delete(bookmark_id):
    """V2: Removes a bookmark based on its ID."""
    if not os.path.exists(DB_FILE):
        print("Not initialized.")
        return

    lines = []
    found = False
    with open(DB_FILE, "r") as f:
        lines = f.readlines()

    with open(DB_FILE, "w") as f:
        for line in lines:
            # Check if the line starts with the target ID
            if not line.startswith(f"{bookmark_id}|"):
                f.write(line)
            else:
                found = True

    if found:
        print(f"Bookmark #{bookmark_id} deleted successfully.")
    else:
        print(f"Error: Bookmark #{bookmark_id} not found.")


def search(keyword):
    """Searches for bookmarks by title keyword[cite: 18]."""
    if not os.path.exists(DB_FILE):
        print("Not initialized.")
        return
    with open(DB_FILE, "r") as f:
        found = False
        for line in f:
            if keyword.lower() in line.split('|')[1].lower():
                print(line.strip())
                found = True
        if not found:
            print("No bookmarks found matching the keyword.")


def main():
    args = sys.argv[1:]
    if not args:
        print("Usage: python minibookmark.py <command> [args]")
        return

    command = args[0]
    if command == "init":
        init()
    elif command == "add":
        if len(args) < 3:
            print("Usage: python minibookmark.py add <title> <url>")
        else:
            add(args[1], args[2])
    elif command == "list":
        list_bookmarks()
    elif command == "delete":
        if len(args) < 2:
            print("Usage: python minibookmark.py delete <id>")
        else:
            delete(args[1])
    elif command == "search":
        if len(args) < 2:
            print("Usage: python minibookmark.py search <keyword>")
        else:
            search(args[1])
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()