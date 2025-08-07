# Realtime Fuel Availability System (RFAS)

A full-stack application providing a live platform for fuel stations to report their fuel levels and for drivers to locate available fuel nearby.

-----

## Table of Contents

1.  [Introduction](https://www.google.com/search?q=%23introduction)
2.  [Features](https://www.google.com/search?q=%23features)
3.  [Technology Stack](https://www.google.com/search?q=%23technology-stack)
4.  [Installation](https://www.google.com/search?q=%23installation)
5.  [Usage](https://www.google.com/search?q=%23usage)
6.  [Advantages](https://www.google.com/search?q=%23advantages)
7.  [Limitations](https://www.google.com/search?q=%23limitations)
8.  [Contributing](https://www.google.com/search?q=%23contributing)
9.  [Contact](https://www.google.com/search?q=%23contact)

-----

## Introduction

This project aims to solve the common problem of fuel uncertainty for drivers. RFAS provides a reliable, real-time system where fuel stations can broadcast their current stock levels. Drivers can then use a mobile application to see this information on a live map, allowing them to find available fuel without the guesswork, saving time and reducing anxiety.

-----

## Features

#### Driver Features (Mobile App)

  * **Live Map of Stations**: Displays nearby fuel stations on an interactive map using OpenStreetMap (OSM).
  * **Real-Time Fuel Status**: View up-to-the-minute fuel availability for each station.
  * **Favorites**: Save frequently visited stations for quick access to their status.
  * **GPS-Based Search**: Automatically finds the closest stations relative to the user's current location.

#### Station Owner Features (Web Portal)

  * **Secure User Authentication**: A dedicated portal with sign-up and log-in functionality for station owners, powered by Firebase.
  * **Location Registration**: Captures and stores the station's precise geographic coordinates during setup.
  * **Simple Dashboard**: An easy-to-use interface for owners to quickly update their fuel levels.

-----

## Technology Stack

  * **Frontend (Web Portal)**: `React.js`
  * **Frontend (Mobile App)**: `Flutter`
  * **Backend & Database**: `Firebase (Cloud Firestore)`
  * **Authentication**: `Firebase Authentication`
  * **Mapping API**: `OpenStreetMap (OSM)`

-----

## Installation

Follow these steps to set up the project locally. Note that the web portal and mobile app must be set up separately.

1.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/rfas-project.git
    ```
2.  Navigate to the project directory:
    ```sh
    cd rfas-project
    ```

**For the Web Portal (React):**

3.  Navigate to the web directory:
    ```sh
    cd web-portal
    ```
4.  Install dependencies:
    ```sh
    npm install
    ```
5.  Start the development server:
    ```sh
    npm start
    ```
6.  Open the app in your browser at `http://localhost:3000`

**For the Mobile App (Flutter):**

3.  Navigate to the mobile directory:
    ```sh
    cd mobile-app
    ```
4.  Install dependencies:
    ```sh
    flutter pub get
    ```
5.  Run the app on an emulator or connected device:
    ```sh
    flutter run
    ```

-----

## Usage

#### For Station Owners:

1.  Navigate to the web portal URL.
2.  Sign up with your station's details, including its location.
3.  Log in to the dashboard.
4.  Update your fuel levels whenever there is a change.

#### For Drivers:

1.  Open the mobile application.
2.  Allow location permissions to find nearby stations.
3.  Explore the map to see fuel stations and their live availability.
4.  Tap a station for more details or add it to your favorites.

-----

## Advantages

  * **Real-Time Data**: Provides instant, up-to-date information, eliminating uncertainty for drivers.
  * **Centralized System**: A single, reliable source of truth for fuel availability in a given area.
  * **Scalable Backend**: Built on Firebase, allowing the system to scale efficiently with more users and stations.
  * **Intuitive UI**: Designed for ease of use for both non-technical station staff and everyday drivers.

-----

## Limitations

  * **Data Reliant on Humans**: The system's accuracy depends on station owners updating their status in a timely manner.
  * **No Advanced Filtering**: Lacks features to filter by fuel type (e.g., `Diesel`, `Premium`) or specific station amenities.
  * **No Transactional Features**: The app does not support payments or pre-booking of fuel.

-----

## Contributing

Contributions are welcome to enhance the functionality and design of RFAS. Here’s how you can help:

1.  Fork the repository.
2.  Create a new branch:
    ```sh
    git checkout -b feature-name
    ```
3.  Make your changes and commit them:
    ```sh
    git commit -m "Add feature description"
    ```
4.  Push your changes:
    ```sh
    git push origin feature-name
    ```
5.  Open a pull request with a detailed description of your changes.

-----

## Contact

For questions or more information about this project, feel free to reach out:

  * **Email**: `akshatdjoshi@gmail.com`
  * **GitHub**: `Ackjosh`
  * **LinkedIn**: `Akshat Joshi`