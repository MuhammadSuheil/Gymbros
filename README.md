# Gymbros - Fitness Tracker App

<p align="center">
  <img src="assets/images/logofull.png" width="300" alt="Gymbros Logo">
</p>

Gymbros is a cross-platform fitness tracker application built with Flutter. It's designed to help users log, track, and analyze their workout sessions to achieve their fitness goals.

**Problem Statement:** Many gym-goers, from beginners to experienced lifters, struggle with inconsistently logging their workouts. They often forget their previous performance (weights, reps), lose track of their progress over time, and find it difficult to stay motivated.

**SDG Alignment (SDG 3: Good Health and Well-being):** This project directly contributes to SDG 3 by providing users with the tools to systematically track their physical exercise, monitor their strength gains, and maintain consistency, promoting an active and healthy lifestyle.

## 📥 Get the App

You can download the latest version of the app from our GitHub Releases page:

**[Download Latest Release](https://github.com/muhammadsuheil/gymbros/releases)**

## ✨ Key Features

- 🔐 **User Authentication**: Secure login and registration system using **Firebase Auth** and **Supabase Auth**.
- 🏋️ **Workout Tracking**: Log sets, reps, and weight (kg/lbs) for each exercise in a session in real-time.
- 📚 **Exercise Database**: Browse and select from a list of available exercises to add to your routine.
- 📈 **History & Analytics**: Review previous workout sessions in detail.
- 🔥 **Streak Tracking**: Monitor your consecutive workout days to stay motivated.
- 👤 **Profile Management**: Manage user profile information.
- 🔔 **Notifications**: Get reminders and notifications 

## 👤 Target Users & Use Cases

- **Target Users:**
  - Fitness enthusiasts, weightlifters, and bodybuilders.
  - Casual gym-goers who want to start tracking their progress.
  - Individuals seeking to build a consistent workout habit.

- **Use Cases:**
  - **Logging a Workout:** A user starts a new session, selects exercises (e.g., "Bench Press," "Squat"), and logs their sets, including the weight and number of repetitions for each.
  - **Reviewing Progress:** A user navigates to the History screen to review a workout from last week or filters to see all their "Bench Press" sessions from the last three months.
  - **Maintaining Motivation:** A user checks their "Streak" on the home screen to see how many consecutive days they have worked out, motivating them not to miss a session.

## 🛠️ Tech Stack & Architecture

### Architecture Pattern
The project follows an **Native MVVM (Model-View-ViewModel)** pattern, organized by feature (`/features` directory) with a clear separation of UI (`view`), business logic (`viewmodel`), and data services (`repository`).

### Core Technologies
- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **Backend & Database (BaaS)**:
  - **Firebase**
    - **Authentication**: For email/password and social logins.
    - **Firestore**: Primary NoSQL database for workout sessions, history, and user data.
  - **Supabase**
    - **Authentication**: (Alternative or supplementary auth)
    - **PostgreSQL Database**: (Used alongside Firestore for specific data)
    - **Storage**: For exercise images and other media.
- **State Management**:
  - **Provider**: For simple and efficient application state management.

### Technical Complexity
The project's complexity is centered on a few key areas:
1.  **Dual Backend Integration:** Manages authentication and data services for both Firebase (Firestore/Storage) and Supabase (PostgreSQL/Auth).
2.  **Real-time State Management:** Uses `provider` to manage the complex, nested state of a "live" workout session (session -> exercises -> sets) before committing it to the database.
3.  **Data-Driven UI:** Features dynamic UIs built from fetched data, including charts (`fl_chart`) and user-uploaded content.

## 🚀 Installation & Setup

To run this project locally, follow these steps:

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/muhammadsuheil/gymbros.git](https://github.com/muhammadsuheil/gymbros.git)
    cd gymbros
    ```

2.  **Install Flutter dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Backend Services (Firebase & Supabase)**
    - **Firebase:**
      - Create a new project on the [Firebase Console](https://console.firebase.google.com/).
      - Add an Android and/or iOS app to your Firebase project.
      - Download your configuration files:
        - For Android: `google-services.json` and place it in `android/app/`.
        - For iOS: `GoogleService-Info.plist` and place it in `ios/Runner/`.
      - In the Firebase console, enable the following services:
        - **Authentication** (Enable Email/Password method).
        - **Cloud Firestore** (Create database).
        - **Storage** (Create a storage bucket).
    - **Supabase:**
      - Create a new project on [Supabase](https://supabase.com/).
      - Go to your project's **Settings** > **API**.
      - Create a `.env` file in the root of the project (or add to your environment variables) with your Supabase URL and Anon Key. (You will need to modify the code to read these, e.g., using `flutter_dotenv`).
        ```
        SUPABASE_URL=YOUR_SUPABASE_URL
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
        ```

4.  **Create Splash Screen (Optional)**
    If you make changes to `native_splash.yaml`, run:
    ```bash
    flutter pub run flutter_native_splash:create
    ```

5.  **Run the App**
    ```bash
    flutter run
    ```

## 👨‍💻 Contributor

- **[Muhammad Suheil](https://github.com/muhammadsuheil)**