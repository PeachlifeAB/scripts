import os
import re
import sys
import json
import requests

# Your IGDB API credentials
client_id = os.environ['IGDB_CLIENT_ID']
client_secret = os.environ['IGDB_CLIENT_SECRET']

# RAWG API credentials
rawg_api_key = os.environ['RAWG_API_KEY']

DEBUG = True

platform_ids = [
    (116, "Acorn Archimedes"),
    (16, "Amiga"),
    (114, "Amiga CD32"),
    (59, "Atari 2600"),
    (60, "Atari 7800"),
    (62, "Atari Jaguar"),
    (61, "Atari Lynx"),
    (15, "Commodore C64/128"),
    (90, "Commodore PET"),
    (94, "Commodore Plus/4"),
    (68, "ColecoVision"),
    (23, "Dreamcast"),
    (127, "Fairchild Channel F"),
    (51, "Family Computer Disk System"),
    (99, "Family Computer (FAMICOM)"),
    (33, "Game Boy"),
    (22, "Game Boy Color"),
    (24, "Game Boy Advance"),
    (104, "HP 2100"),
    (27, "MSX"),
    (53, "MSX2"),
    (42, "N-Gage"),
    (18, "Nintendo Entertainment System (NES)"),
    (21, "Nintendo GameCube"),
    (4, "Nintendo 64"),
    (20, "Nintendo DS"),
    (37, "Nintendo 3DS"),
    (5, "Wii"),
    (41, "Wii U"),
    (19, "Super Nintendo Entertainment System (SNES)"),
    (58, "Super Famicom"),
    (80, "Neo Geo AES"),
    (79, "Neo Geo MVS"),
    (119, "Neo Geo Pocket"),
    (120, "Neo Geo Pocket Color"),
    (88, "Odyssey"),
    (72, "Ouya"),
    (125, "PC-8801"),
    (108, "PDP-11"),
    (96, "PDP-10"),
    (7, "PlayStation"),
    (8, "PlayStation 2"),
    (9, "PlayStation 3"),
    (48, "PlayStation 4"),
    (38, "PlayStation Portable"),
    (46, "PlayStation Vita"),
    (117, "Philips CD-i"),
    (106, "SDS Sigma 7"),
    (121, "Sharp X68000"),
    (77, "Sharp X1"),
    (35, "Sega Game Gear"),
    (64, "Sega Master System"),
    (29, "Sega Mega Drive/Genesis"),
    (30, "Sega 32X"),
    (32, "Sega Saturn"),
    (78, "Sega CD"),
    (84, "SG-1000"),
    (50, "3DO Interactive Multiplayer"),
    (86, "TurboGrafx-16/PC Engine"),
    (87, "Virtual Boy"),
    (70, "Vectrex"),
    (11, "Xbox"),
    (12, "Xbox 360"),
    (49, "Xbox One"),
    (36, "Xbox Live Arcade"),
    (126, "TRS-80"),
    (122, "Nuon"),
    (26, "ZX Spectrum"),
]

if len(sys.argv) > 1:
        game_files_path = sys.argv[1]
        print(f"Game files path: {game_files_path}")
else:
    print("Please provide the path to your game files as a command-line argument.")
    sys.exit(1)

if DEBUG:
    platform_id = 20
    min_rating = 45
    max_result = 999
else:
    print("Select the platform ID:")
    for platform_id, platform_name in platform_ids:
        print(f"{platform_id}: {platform_name}")

    platform_id = int(input("Enter the platform ID: "))
    min_rating = int(input("Enter the minimum rating: "))
    max_result = 500

def get_access_token(client_id, client_secret):
    token_url = "https://id.twitch.tv/oauth2/token"
    payload = {
        'client_id': client_id,
        'client_secret': client_secret,
        'grant_type': 'client_credentials'
    }
    response = requests.post(token_url, params=payload)
    if response.status_code == 200:
        return response.json()['access_token']
    else:
        print("Error occurred while fetching the access token.")
        sys.exit(1)

access_token = get_access_token(client_id, client_secret)

def fetch_rawg_platforms(api_key):
    url = "https://api.rawg.io/api/platforms?key=" + api_key
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error occurred while fetching platforms. Status code: {response.status_code} url: {url}")
        sys.exit(1)

platforms = fetch_rawg_platforms(rawg_api_key)

print(f"Total platforms count: {platforms['count']}")
print("Platforms:")
for platform in platforms['results']:
    print(f"{platform['id']}: {platform['name']}")

def fetch_rawg_game_data(platform_id, api_key, min_rating):
    url = f"https://api.rawg.io/api/games?key={api_key}&platforms={platform_id}&rating_greater_or_equal={min_rating}&page_size=500"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()['results']
    else:
        print("Error occurred while fetching game data.")
        sys.exit(1)

def fetch_igdb_game_data(platform_id, access_token, min_rating):
    url = "https://api.igdb.com/v4/games"
    headers = {
        'Client-ID': client_id,
        'Authorization': f"Bearer {access_token}",
        'Content-Type': 'text/plain'
    }
    payload = f"""
    fields name;
    where platforms = {platform_id};
    limit {max_result};
    """

    response = requests.post(url, headers=headers, data=payload)
    if response.status_code == 200:
        print(f"Fetched games number: {len(response.json())}")
        return response.json()
    else:
        print("Error occurred while fetching game data.")
        sys.exit(1)

def clean_game_name(file_name):
    name = os.path.splitext(file_name)[0]
    name = re.sub(r'\(.*?\)', '', name).strip()
    name = re.sub(r'[^a-zA-Z0-9]', ' ', name)
    return name

nintendo_ds_games = fetch_game_data(platform_id, access_token, min_rating)

games = {}
for game in nintendo_ds_games:
    games[clean_game_name(game['name'])] = game['rating']

matched_files = set()
unmatched_files = set()

for file_name in os.listdir(game_files_path):
    cleaned_name = clean_game_name(file_name)
    if cleaned_name in games:
        matched_files.add(file_name)
    else:
        unmatched_files.add(file_name)

if len(unmatched_files) > 0:
    #print(f"\n{len(unmatched_files)} files do not match the specified criteria.")
    #print("The following files will be removed:")

    # for file_name in unmatched_files:
        # print(file_name)

    print(f"Matched files: {len(matched_files)}")
    print(f"Unmatched files: {len(unmatched_files)}")

    if DEBUG == False:
        confirmation = input("\nDo you want to remove these files? (y/n): ")

        if confirmation.lower() == 'y':
            for file_name in unmatched_files:
                file_path = os.path.join(game_files_path, file_name)
                os.remove(file_path)
                print(f"Removed: {file_name}")
        else:
            print("No files were removed.")
else:
    print("All files matched the specified criteria. No files will be removed.")