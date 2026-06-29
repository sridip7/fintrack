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
  <img src="https://github.com/user-attachments/assets/351eb281-617e-4278-aa44-c805e1c71732" width="30%" />
  <img src="https://github.com/user-attachments/assets/5332cd8e-c104-426c-990b-8e8494c18f31" width="30%" />
  <img src="https://github.com/user-attachments/assets/8cdb938b-a197-4e68-9409-8f968e20e12e" width="30%" />
  <img src="https://github.com/user-attachments/assets/fb09b19e-82b0-4404-8319-32d1091f8349" width="30%" />
  <img src="https://github.com/user-attachments/assets/bb5f7644-ecfd-47c8-89f1-261e56262217" width="30%" />
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
