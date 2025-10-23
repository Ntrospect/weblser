# weblser - AI-Powered Website Analyzer

A cross-platform Flutter application that analyzes websites using Claude AI to generate intelligent summaries of their purpose, features, and target audience.

**Live Website Analysis → AI-Generated Insights → Professional PDF Reports**

## Features

✨ **AI-Powered Analysis**
- Intelligent website content extraction and analysis
- Claude AI-generated summaries (2-3 sentences)
- Extracts page title, meta description, and full content

<img width="1024" height="686" alt="Screenshot 2025-10-23 130901" src="https://github.com/user-attachments/assets/5f35aa62-4d0b-4ece-bb7c-9983871278b7" />

📊 **Multi-Platform Support**
- Windows desktop application
- macOS desktop application
- iOS mobile app

<img width="400" height="771" alt="Screenshot 2025-10-23 131028" src="https://github.com/user-attachments/assets/9f96e1f3-bc8a-4bf6-b57b-1d7bdf0c1f93" />

<img width="400" height="779" alt="Screenshot 2025-10-23 131253" src="https://github.com/user-attachments/assets/a9355cf2-3a1f-46b0-b311-89869abc3e76" />


💼 **Professional PDF Reports**
- Generate formatted PDF reports with branding
- Custom company details and logos
- Professional styling and layout

📱 **User-Friendly Interface**
- Dark theme dashboard UI
- Responsive design
- Real-time analysis status
- Search history management

## Tech Stack

### Frontend
- Flutter 3.35.6 | Dart 3.9.2
- Provider (State Management)
- SharedPreferences (Local Storage)

### Backend
- FastAPI (Python)
- Claude 3.5 Sonnet API
- BeautifulSoup4 (HTML parsing)
- ReportLab (PDF generation)

### Deployment
- Ubuntu VPS
- Nginx (Reverse proxy)
- systemd (Service management)

## Installation

```bash
# Clone repository
git clone https://github.com/YOUR-USERNAME/weblser.git
cd weblser/weblser_app

# Install dependencies
flutter pub get

# Run the app
flutter run -d windows  # or: -d macos, -d ios
```

## API Configuration

Set your backend API endpoint in the Settings tab of the app.

Default: `http://140.99.254.83:8000`

## Building for Release

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

## Project Structure

```
weblser_app/
├── lib/
│   ├── main.dart
│   ├── models/analysis.dart
│   ├── screens/ (home, results, history, settings, splash)
│   ├── services/api_service.dart
│   ├── theme/dark_theme.dart
│   └── widgets/
├── assets/ (logos and branding)
├── pubspec.yaml
└── README.md
```

## Key Features

✅ Analyze any website with one click
✅ AI-generated intelligent summaries
✅ View analysis history
✅ Download professional PDF reports
✅ Configure API endpoint and branding
✅ Dark theme UI with Jumoki branding

## Backend API Endpoints

- `POST /api/analyze` - Analyze a website
- `GET /api/history` - Get analysis history
- `GET /api/analyses/{id}` - Get specific analysis
- `POST /api/pdf` - Generate PDF report
- `DELETE /api/analyses/{id}` - Delete analysis

See backend documentation for full API details.

## Development

```bash
# Hot reload during development
flutter run -d windows

# Run with profiling
flutter run -d windows --profile

# Build release version
flutter build windows --release
```

## Troubleshooting

**Build errors?**
```bash
flutter clean
flutter pub get
flutter run -d windows
```

**API connection issues?**
- Check backend is running
- Verify API endpoint in Settings
- Check firewall/network

## License

MIT License - See LICENSE file

## Support

- Jumoki Agency: https://jumoki.agency
- Email: info@jumoki.agency

---

Built with Flutter & Claude AI ❤️
