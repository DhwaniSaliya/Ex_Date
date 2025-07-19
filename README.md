<p align="center">
  <img src="assets/images/Logo2.png" alt="ExDate Logo" width="150"/>
</p>

# ExDate – Expiry Date Tracker for Food & Medicines

ExDate is a smart Flutter app that helps you track the expiry dates of food items and medicines, suggest recipes based on what you have, and minimize waste with timely alerts.

## Demo
[![Watch the video](https://img.youtube.com/vi/x7PxFA5COgg/0.jpg)](https://www.youtube.com/watch?v=x7PxFA5COgg)

or

🎥 [Watch Demo on YouTube](https://www.youtube.com/watch?v=x7PxFA5COgg)

📱**Features at a Glance**
- **Smart Expiry Tracking**
  - Lists upcoming items expiring within the next 30 days.

  - Sends local notifications everyday starting from when there's 7 days left for an item to expire.

- **Screens & Functionality**
  - **Splash Screen**: Simple and smooth animated startup.

  - **Login / Signup / Forgot Password**: Secure authentication using Firebase Auth.

  - **Home Screen**: Displays upcoming expiring items in a clean layout.

  - **Add / Edit Item**: Allows users to input item name, quantity, purchase and expiry date, and optional notes.

  - **Item List & Detail Screen**: View all saved items and inspect full details.

  - **History Screen**: Tracks and displays expired items.

  - **Dashboard Screen**: Provides visual summaries using bar, pie, and line charts.

  - **Profile Screen**: Lets users edit their username, change password, toggle notifications on/off, and logout.

- **Smart Recipe Integration**
  - **Search Recipes**: Search recipes using available ingredients.

  - **Recipe Suggestions**: Suggests recipes based on ingredients you added {which u obviously will do for the ones that are going near expiry :) }.

  - **Recipe Detail Screen**: Shows which ingredients you have added to search and which are missing for a recipe.

- **APIs and Services Used**
  - **Firebase Authentication**: Handles user sign-in, sign-up, and password management.

  - **Firebase Firestore**: Real-time database for storing user and item data.

  - **Local Notification Service**: Notifies users before item expiry.

  - **Spoonacular API**: Provides recipe data based on ingredients.

  - **Pixabay API**: Fetches relevant images for food and medicine items.

- **Dashboard Insights**
  - **Calendar View**: Displays expiry dates visually across the month.

  - **Line Chart**: Shows expiry trends over the past 7 days.

  - **Bar Chart**: Visualizes item expiry count by date.

  - **Pie Chart**: Represents status breakdown of items (Expired, Not Expired).

- **Tech Stack**
  - **Framework**: Flutter (Dart)
  - **Backend Services**: Firebase Authentication, Firebase Firestore
  - **APIs**: Spoonacular API, Pixabay API
  - **Packages / Libraries**:
    - flutter_local_notifications (local alerts)
    - fl_chart (for visual charts)
    - syncfusion_flutter_charts (for dashboard charts)
    - and more....


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
