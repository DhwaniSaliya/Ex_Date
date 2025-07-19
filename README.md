<p align="center">
  <img src="assets/images/Logo2.png" alt="ExDate Logo" width="150"/>
</p>
# ExDate – Expiry Date Tracker for Food & Medicines

ExDate is a smart Flutter app that helps you track the expiry dates of food items and medicines, suggest recipes based on what you have, and minimize waste with timely alerts.

<div style="display: flex; flex-wrap: wrap; width: 1000px; margin: auto;">
  <img src="https://github.com/user-attachments/assets/748051cf-1988-40f3-93f1-f2345299b5c2" alt="Screenshot 1" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/42fff9b7-5d3d-411a-8762-a26f6aa316d4" alt="Screenshot 2" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/a0094890-3ff6-449f-967e-c4017af5a742" alt="Screenshot 3" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/ee02c638-8b23-4ffd-989c-80da7f77b1a9" alt="Screenshot 4" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/f452534a-dca0-4834-8f9a-3f040e8bbad0" alt="Screenshot 5" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/0de95ddf-69dd-4162-a973-5a22e06fba9f" alt="Screenshot 6" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/7b977943-47e7-479a-839f-a190f8ba03f1" alt="Screenshot 7" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/68c2d2ae-e5ad-410a-a177-85ecd34a79e3" alt="Screenshot 8" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/0c0a1130-76c4-420c-bdda-a6c082c2c44d" alt="Screenshot 9" width="180" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/f2bd5825-f43e-4f35-b979-49282b2a4f72" alt="Screenshot 10" width="180" style="margin: 5px;"/>
</div>

Features at a Glance
1. Smart Expiry Tracking
Lists upcoming items expiring within the next 30 days.

Sends local notifications approximately 12 hours before an item expires.

2. Screens & Functionality
Splash Screen: Simple and smooth animated startup.

Login / Signup / Forgot Password: Secure authentication using Firebase Auth.

Home Screen: Displays upcoming expiring items in a clean layout.

Add / Edit Item: Allows users to input item name, quantity, purchase and expiry date, and optional notes.

Item List & Detail Screen: View all saved items and inspect full details.

History Screen: Tracks and displays expired items.

Dashboard Screen: Provides visual summaries using bar, pie, and line charts.

Profile Screen: Lets users edit their username, change password, toggle notifications on/off, and logout.

3. Smart Recipe Integration
Search Recipes: Search recipes using available ingredients.

Recipe Suggestions: Suggests recipes based on ingredients you added {which u obviously will do for the ones that are going near expiry :) }.

Recipe Detail Screen: Shows which ingredients you have added to search and which are missing for a recipe.

4. APIs and Services Used
Firebase Authentication: Handles user sign-in, sign-up, and password management.

Firebase Firestore: Real-time database for storing user and item data.

Local Notification Service: Notifies users before item expiry.

Spoonacular API: Provides recipe data based on ingredients.

Pixabay API: Fetches relevant images for food and medicine items.

5. Dashboard Insights
Calendar View: Displays expiry dates visually across the month.

Line Chart: Shows expiry trends over the past 7 days.

Bar Chart: Visualizes item expiry count by date.

Pie Chart: Represents status breakdown of items (Expired, Expiring Soon, Safe).

6. Tech Stack
**Framework**: Flutter (Dart)
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
