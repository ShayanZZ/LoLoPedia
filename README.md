# LoLoPedia

LoLoPedia is a Flutter application that provides information about League of Legends champions. Users can browse through a list of champions, search for specific ones, and view detailed information about each champion, including their splash art, roles, lore, and abilities.

## Features

- List view of all League of Legends champions
- Search functionality to filter champions
- Detailed view for each champion, including:
  - Splash art
  - Champion name and roles
  - Lore
  - Abilities

## Live Demo

You can try out the web version of LoLoPedia here: [https://shayanzz.github.io/LoLoPedia/](https://shayanzz.github.io/LoLoPedia/)

## Getting Started

To run this project locally, follow these steps:

1. Ensure you have Flutter installed on your machine. If not, follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

2. Clone this repository:
   ```
   git clone https://github.com/ShayanZZ/LoLoPedia.git
   ```

3. Navigate to the project directory:
   ```
   cd LoLoPedia
   ```

4. Get the dependencies:
   ```
   flutter pub get
   ```

5. Run the app:
   ```
   flutter run
   ```

## Dependencies

This project uses the following packages:

- `http`: For making API requests
- `cached_network_image`: For efficient loading and caching of network images

## API

LoLoPedia uses the Riot Games Data Dragon API to fetch champion data.
