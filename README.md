RFAS - Realtime Fuel Availability System
RFAS is a full-stack application designed to bridge the information gap between fuel stations and drivers. It provides a real-time platform where station owners can update their current fuel availability, and consumers can view this information on an interactive map, ensuring they can find fuel efficiently when they need it most.

Features
This project is divided into two main components: the web portal for station owners and the mobile application for drivers.

For Drivers (Mobile App)
Interactive Map View: Utilizes OpenStreetMap (OSM) to display a live map of all registered fuel stations.

Real-time Fuel Status: See up-to-the-minute fuel levels at each station, indicated by intuitive icons or colors.

Find Nearby Stations: Automatically detects the user's location to show the closest available fuel options.

Favorites List: Allows users to save their frequently visited stations for quick access.

For Station Owners (Web Portal)
Secure Authentication: Station owners can sign up and log in securely using Firebase Authentication.

Location Registration: Captures the precise geographic coordinates of the station during the sign-up process.

Fuel Level Dashboard: A simple and secure interface for owners to update their current fuel stock in real-time.

System Architecture
The system consists of a React-based web portal where station owners authenticate via Firebase and write fuel/location data to a Cloud Firestore database. A Flutter mobile app reads this data in real-time from Firestore and uses the OpenStreetMap API to display the stations and their status on an interactive map for drivers. This architecture ensures low latency and high availability of data.

Technology Stack
Mobile Application: Flutter

Web Portal: React.js

Backend & Database: Firebase (Authentication, Cloud Firestore)

Mapping: OpenStreetMap (OSM)

Installation
To get this project running locally, you'll need to set up the web portal and the mobile app separately.

Prerequisites:

Node.js and npm installed

Flutter SDK installed

A Firebase project with Authentication and Firestore enabled.

Instructions:

Clone the repository:

Bash

git clone https://github.com/your-username/rfas-project.git
cd rfas-project
Set up Firebase:

Create a firebaseConfig.js file in the web portal's src directory with your Firebase project credentials.

Place your google-services.json (for Android) and GoogleService-Info.plist (for iOS) in the appropriate directories within the Flutter project.

Web Portal (React)
Navigate to the web directory:

Bash

cd web-portal
Install dependencies:

Bash

npm install
Start the development server:

Bash

npm start
The portal will be running at http://localhost:3000.

Mobile App (Flutter)
Navigate to the mobile directory:

Bash

cd mobile-app
Install dependencies:

Bash

flutter pub get
Run the app:

Bash

flutter run
Usage
As a Station Owner:
Open the web portal.

Register your fuel station with an email, password, and your station's location.

Log in to your dashboard.

Update the status of your fuel tanks as they change.

As a Driver:
Download and open the mobile app.

Grant location permissions to see nearby stations.

Browse the map to see stations around you and their current fuel levels.

Tap on a station to view more details or add it to your favorites.