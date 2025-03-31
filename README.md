
---

# Simple Invoice Generator

A Flutter application designed for freelancers and small business owners to create and generate professional PDF invoices with support for the Indian Rupee (₹) symbol. The app features a modern, animated UI and automatic calculations for easy invoicing.

## Features

- **Modern UI**: Clean, card-based interface with smooth animations.
- **Business Branding**: Add your business name, contact details, and logo.
- **Client Information**: Input client name and contact details.
- **Item Management**: Add, edit, or remove items (description, quantity, price) with swipe-to-delete functionality.
- **Automatic Calculations**: Computes subtotal, tax, discount, and total seamlessly.
- **Customizable Tax & Discount**: Set tax and discount percentages.
- **PDF Export**: Generates a professional PDF invoice with ₹ symbol support.
- **Cross-Platform**: Runs on Android, iOS, and other Flutter-supported platforms.

## Getting Started

Follow these steps to set up and run the Simple Invoice Generator on your local machine.

### Prerequisites

- **Flutter SDK**: Version 2.19.0 or higher (install from [flutter.dev](https://flutter.dev/docs/get-started/install))
- **Dart**: Included with Flutter
- **IDE**: Android Studio, VS Code, or any Flutter-supported editor
- **Device/Emulator**: For testing (physical device or emulator)

### Installation

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/yourusername/invoice_generator.git
   cd invoice_generator
   ```

2. **Install Dependencies**  
   Run the following command to fetch required packages:
   ```bash
   flutter pub get
   ```

3. **Add Fonts**  
   - Download:
     - [Poppins](https://fonts.google.com/specimen/Poppins) (Regular and Bold)
     - [Noto Sans](https://fonts.google.com/specimen/Noto+Sans) (Regular)
   - Place them in `assets/fonts/`:
     ```
     assets/fonts/
     ├── Poppins-Regular.ttf
     ├── Poppins-Bold.ttf
     └── NotoSans-Regular.ttf
     ```
   - Verify `pubspec.yaml` includes these assets (see below).

4. **Configure `pubspec.yaml`**  
   Ensure your `pubspec.yaml` matches:
   ```yaml
   name: invoice_generator
   description: A beautiful invoice generator for freelancers
   version: 1.0.0

   environment:
     sdk: '>=2.19.0 <3.0.0'

   dependencies:
     flutter:
       sdk: flutter
     pdf: ^3.10.8
     path_provider: ^2.1.3
     open_file: ^3.3.2
     intl: ^0.19.0
     image_picker: ^1.0.8
     flutter_animate: ^4.5.0

   dev_dependencies:
     flutter_test:
       sdk: flutter

   flutter:
     uses-material-design: true
     assets:
       - assets/fonts/
     fonts:
       - family: Poppins
         fonts:
           - asset: assets/fonts/Poppins-Regular.ttf
           - asset: assets/fonts/Poppins-Bold.ttf
             weight: 700
       - family: NotoSans
         fonts:
           - asset: assets/fonts/NotoSans-Regular.ttf
   ```

5. **Platform-Specific Setup**  
   - **Android**: Add permissions to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
     <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
     ```
   - **iOS**: Add to `ios/Runner/Info.plist`:
     ```xml
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Allow access to photo library to select a logo</string>
     ```

6. **Run the App**  
   Connect a device or start an emulator, then:
   ```bash
   flutter run
   ```

## Usage

1. **Open the App**: Launch on your device/emulator.
2. **Enter Business Details**:
   - Tap the logo placeholder to upload an image.
   - Fill in business name and contact info.
3. **Add Client Details**: Enter client name and contact.
4. **Manage Items**:
   - Click "Add" under "Items" to input description, quantity, and price.
   - Swipe items right-to-left to delete.
5. **Set Tax & Discount**: Adjust percentages as needed (defaults to 0%).
6. **Generate Invoice**: Tap "Generate Invoice" to create and view the PDF.

## Project Structure

```
invoice_generator/
├── lib/
│   ├── models/
│   │   └── invoice.dart        # Invoice and InvoiceItem models
│   ├── utils/
│   │   └── pdf_generator.dart  # PDF generation with ₹ support
│   ├── widgets/
│   │   └── custom_text_field.dart  # Custom text field widget
│   └── main.dart               # App UI and core logic
├── assets/
│   └── fonts/                  # Poppins and NotoSans font files
└── pubspec.yaml                # Dependencies and configuration
```

## Troubleshooting

- **₹ Symbol Missing in PDF**:
  - Ensure `NotoSans-Regular.ttf` is in `assets/fonts/` and listed in `pubspec.yaml`.
  - Run `flutter pub get` after updating `pubspec.yaml`.
- **App Crashes**:
  - Check for missing font files or dependencies.
  - Verify platform permissions.
- **PDF Not Opening**:
  - Ensure `open_file` works and a PDF viewer is installed on the device.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/) - Tutorials and API reference
- [Write Your First Flutter App](https://docs.flutter.dev/get-started/codelab) - Beginner guide
- [Flutter Cookbook](https://docs.flutter.dev/cookbook) - Useful samples

## Contributing

Contributions are welcome! Fork the repo, make changes, and submit a pull request.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

### Notes
- Replace `yourusername` with your GitHub username if hosting online.
- Add a `LICENSE` file if you choose to include one (e.g., MIT License text).
- Optionally, add screenshots to a `screenshots/` folder and link them under a "Screenshots" section.
