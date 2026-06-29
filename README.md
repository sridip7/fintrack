# FinTrack 💰

A beautiful, modern, and minimalistic personal finance tracker built with Flutter. 

FinTrack helps you keep track of your daily expenses, monitor your income, and visualize your spending habits over time with stunning charts and deep analytics.

## Features ✨

* **Quick Logging:** Easily add income and expenses on the go.
* **Smart Analytics:** View your spending breakdowns via interactive Pie Charts and Weekly Bar Charts.
* **Actionable Insights:** Automatically calculates your highest/lowest spending categories and average daily spend.
* **Modern UI:** Built with Material 3, featuring glassmorphism elements, custom animations, and a premium custom app icon.
* **Dark Mode Support:** Fully responsive dark and light themes that adapt to your system preferences.
* **Local Storage:** Lightning-fast, private on-device data storage.

## Screenshots 📱

<p align="center">
  <img src="https://github.com/user-attachments/assets/f220dacc-d656-480f-b16f-8e871b792986" width="30%" />
  <img src="https://github.com/user-attachments/assets/fb8a132f-6434-422f-85e7-3eb78839ebdc" width="30%" />
  <img src="https://github.com/user-attachments/assets/d39f752e-4a8c-4279-9c0d-edc5e10d96cd" width="30%" />
  <img src="https://github.com/user-attachments/assets/53050ebd-8e9e-4339-a8f3-63f454c99d7d" width="30%" />
  <img src="https://github.com/user-attachments/assets/046d8977-8689-4fdc-a029-4a89c81a642d" width="30%" />
  <img src="https://github.com/user-attachments/assets/299f998a-1aa1-451d-bbbb-cdb487e71d06" width="30%" />
</p>


## Getting Started 🚀

To run this project locally, you will need to have [Flutter installed](https://docs.flutter.dev/get-started/install) on your machine.

1. **Clone the repository**
   ```bash
   git clone https://github.com/sridip7/fintrack.git
   ```
2. **Navigate to the directory**
   ```bash
   cd fintrack
   ```
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Run the app**
   ```bash
   flutter run
   ```

## Build for Production 📦

To build a release APK for Android:
```bash
# Builds a fat APK containing all architectures
flutter build apk --release

# Builds highly-optimized, small APKs per architecture (Recommended)
flutter build apk --split-per-abi --release
```

## Built With 🛠️
* **[Flutter](https://flutter.dev/)** - UI Toolkit
* **[Provider](https://pub.dev/packages/provider)** - State Management
* **[Fl Chart](https://pub.dev/packages/fl_chart)** - Beautiful data visualizations
* **[Intl](https://pub.dev/packages/intl)** - Currency formatting and localization
