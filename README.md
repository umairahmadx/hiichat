
# Hiichat

Hiichat is a modern chat application built with Flutter, providing a seamless user experience across multiple platforms. The application integrates Firebase for user authentication and real-time messaging capabilities.

## Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [Git Ignore Analysis](#git-ignore-analysis)

## Features

- **User Authentication**: Secure sign-up and login features with email verification.
- **Real-time Messaging**: Instant messaging capabilities using Cloud Firestore.
- **User Search**: Easily find other users with a built-in search functionality.
- **Responsive Design**: User-friendly UI that works seamlessly across all devices.

## Technologies Used

- **Flutter**: A UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Firebase**: A comprehensive app development platform for building high-quality applications.
- **Cloud Firestore**: A NoSQL database to store user data and chat messages in real time.

## Project Structure

```
hiichat/
├── lib/                              # Main application code
│   ├── firebase/                      # Firebase related configurations and services
│   ├── nestedScreen/                  # Screen navigations and functionalities
│   ├── main.dart                      # Entry point of the application
│   └── ...                            # Other Dart files
├── pubspec.yaml                       # Flutter dependencies and package configuration
└── .gitignore                         # Git ignore configuration
```

## Setup and Installation

To set up the Hiichat application locally, follow these detailed steps:

### Step 1: Install Flutter

Ensure you have Flutter installed on your machine. If Flutter is not installed, follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) for your operating system.

### Step 2: Create a New Flutter Project

1. Open your terminal (Command Prompt, PowerShell, or Terminal).
2. Run the following command to create a new Flutter project:
   ```bash
   flutter create hiichat
   ```
3. Change your working directory to the newly created project:
   ```bash
   cd hiichat
   ```

### Step 3: Replace the `lib` Folder and `pubspec.yaml`

1. **Delete the Existing `lib` Folder**:
   Inside your project directory, navigate to the `lib` folder and delete it. You can do this using the following commands:

   - For Unix-based systems (Linux/macOS):
     ```bash
     rm -rf lib/
     ```
   - For Windows:
     ```bash
     rmdir /s /q lib
     ```

2. **Replace with Hiichat's `lib` Folder**:
   Download the `lib` folder from the Hiichat project (you can clone the Hiichat repository or download it as a ZIP file) and place it into your newly created project directory. The structure should look like this:

   ```
   hiichat/
   ├── lib/                       # Replace this with the Hiichat lib folder
   ├── android/
   ├── ios/
   ├── web/
   ├── pubspec.yaml               # Replace this in the next step
   └── ...
   ```

3. **Replace the `pubspec.yaml` File**:
   - Delete the existing `pubspec.yaml` file:
      - For Unix-based systems:
        ```bash
        rm pubspec.yaml
        ```
      - For Windows:
        ```bash
        del pubspec.yaml
        ```

   - Download the `pubspec.yaml` from the Hiichat project and place it into your project directory.

### Step 4: Install Dependencies

Once you have replaced the `lib` folder and the `pubspec.yaml` file, you need to install the required dependencies:

1. In your terminal, run:
   ```bash
   flutter pub get
   ```

### Step 5: Set Up Firebase

1. Create a Firebase project by visiting the [Firebase Console](https://console.firebase.google.com/).
2. Add your application to the Firebase project (for Android and/or iOS) by following the instructions provided by Firebase.
3. Download the configuration files:
   - For **Android**, download `google-services.json` and place it in the `android/app/` directory.
   - For **iOS**, download `GoogleService-Info.plist` and place it in the `ios/Runner/` directory.

### Step 6: Initialize Firebase in Your Application

1. Open the `main.dart` file in the `lib` directory.
2. Ensure that Firebase is initialized by including the following line in your `main` function:
   ```dart
   await Firebase.initializeApp()
   ```

### Step 7: Run the Application

Finally, you can run the application:

1. Use the following command in your terminal:
   ```bash
   flutter run
   ```

After these steps, you should have the Hiichat application set up and running locally on your machine. Enjoy exploring the features and contributing to the project!

## Usage

After setting up the application, you can create a new account or log in using your existing credentials. Use the search functionality to find other users and start chatting.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any features or fixes you would like to add.

## Git Ignore Analysis

This project contains a well-structured `.gitignore` file to ensure unnecessary files and sensitive information are not included in the version control system. Below are the key components of the `.gitignore` file:

### 1. Miscellaneous Entries
- `*.class`, `*.log`, `*.pyc`: Ignores compiled files, logs, and temporary files.
- `.DS_Store`: Excludes macOS Finder metadata files.
- `.atom/`, `.history`, `.svn/`: Ignores editor configurations and version control metadata.

### 2. IntelliJ and Visual Studio Code Related
- `*.iml`, `.idea/`: Excludes IntelliJ IDEA project-specific files.
- `.vscode/`: Commented out, allowing optional inclusion for VS Code settings.

### 3. Flutter/Dart/Pub Related
- `**/doc/api/`, `.dart_tool/`: Ignores generated documentation and tooling files.
- `/build/`, `/android/`, `/ios/`, `/linux/`, `/macos/`, `/web/`, `/windows/`: Excludes platform-specific directories to prevent tracking build artifacts.
- `.pub-cache/`, `.pub/`: Excludes Pub-related cache files.

### 4. Sensitive Configuration
- `/lib/firebase_options.dart`: Excludes Firebase configuration files to maintain security.

### 5. Symbolication and Obfuscation Related
- `app.*.symbols`, `app.*.map.json`: Excludes debugging and mapping files for obfuscated code.

### 6. Android Studio Build Artifacts
- `/android/app/debug`, `/android/app/profile`, `/android/app/release`: Excludes specific Android build directories to prevent tracking build artifacts.

This careful management of files ensures that the repository remains clean and secure.