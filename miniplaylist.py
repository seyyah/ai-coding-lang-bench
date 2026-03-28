"""
mini-playlist v1 — Simplified implementation
Student: Kamil Efe Aygör (251478093)

--- V1 Task List ---
1. Task: Implement 'show' command using a while loop (read from file line by line).
2. Task: If the file is empty, warn the user with "Playlist is empty."
3. Task: If the requested playlist file is not found, print "Playlist not found."

--- V0 -> V1 Changes Summary ---
In V0, we could only initialize and create empty files (init, create).
In V1, using a while loop and readline() function, reading songs line by line
and listing them on the screen (show) feature was added.
"""
import sys
import os


def initialize():
    """Initializes the main miniplaylist directory."""
    if os.path.exists(".miniplaylist"):
        return "Already initialized"

    os.mkdir(".miniplaylist")
    return "Initialized empty playlist manager in .miniplaylist/"


def create_playlist(playlist_name):
    """Creates a new playlist file (.dat) with the given name."""
    if not os.path.exists(".miniplaylist"):
        return "Not initialized."

    file_path = ".miniplaylist/" + playlist_name + ".dat"

    if os.path.exists(file_path):
        return "Playlist already exists."

    f = open(file_path, "w")
    f.close()
    return "Playlist '" + playlist_name + "' created."


def show_playlist(playlist_name):
    """Reads and displays songs in the given playlist using a while loop."""
    if not os.path.exists(".miniplaylist"):
        return "Not initialized."

    file_path = ".miniplaylist/" + playlist_name + ".dat"

    if not os.path.exists(file_path):
        return "Playlist not found."

    f = open(file_path, "r")
    line = f.readline()

    if not line:
        f.close()
        return "Playlist is empty."

    result = ""

    while line != "":
        first_pipe = line.find("|")
        second_pipe = line.find("|", first_pipe + 1)

        if first_pipe != -1 and second_pipe != -1:
            song_id = line[:first_pipe]
            title = line[first_pipe + 1:second_pipe]
            date_str = line[second_pipe + 1:].strip()

            result = result + "[" + song_id + "] " + title + " (" + date_str + ")\n"

        line = f.readline()

    f.close()
    return result.strip()


def show_not_implemented(command_name):
    """Standard warning message for commands not yet implemented."""
    return "Command '" + command_name + "' will be implemented in future weeks."


# --- Main Program ---
if len(sys.argv) < 2:
    print("Usage: python miniplaylist.py <command> [args]")
elif sys.argv[1] == "init":
    print(initialize())
elif sys.argv[1] == "create":
    if len(sys.argv) < 3:
        print("Usage: python miniplaylist.py create <playlist_name>")
    else:
        print(create_playlist(sys.argv[2]))
elif sys.argv[1] == "add":
    print(show_not_implemented("add"))
elif sys.argv[1] == "show":
    if len(sys.argv) < 3:
        print("Usage: python miniplaylist.py show <playlist_name>")
    else:
        print(show_playlist(sys.argv[2]))
elif sys.argv[1] == "delete":
    print(show_not_implemented("delete"))
else:
    print("Unknown command: " + sys.argv[1])