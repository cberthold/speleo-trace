# Speleo Trace

A Flutter application for speleological triangulation using GPS and compass data.

## Features

- Real-time GPS positioning
- Compass integration
- Triangulation calculations
- Interactive map with bearing lines
- MVVM architecture

## Project Structure

```
lib/
├── main.dart              # App entry point
└── src/                   # Internal source code
    ├── models/            # Data models
    ├── viewmodels/        # Business logic & state management
    ├── views/             # UI components
    ├── utils/             # Utility functions
    └── services/          # External services (future)

test/
├── models/                # Model tests
├── viewmodels/            # ViewModel tests
├── utils/                 # Utility tests
└── widget_test.dart       # Widget integration tests

.github/workflows/         # CI/CD pipelines
scripts/                   # Build scripts
```

## Architecture

This project follows the MVVM (Model-View-ViewModel) pattern with a clean `lib/src/` organization that separates public API from internal implementation:

- **`lib/main.dart`**: Public entry point
- **`lib/src/models/`**: Data structures and business entities
- **`lib/src/viewmodels/`**: Business logic and state management
- **`lib/src/views/`**: Pure UI components that react to ViewModel changes
- **`lib/src/utils/`**: Pure utility functions for calculations
- **`lib/src/services/`**: Abstractions for external dependencies

The `src/` folder is a common pattern in Dart/Flutter projects to clearly separate public interfaces from internal code.

## Testing

Run tests with:

```bash
flutter test
```

Tests follow AAA (Arrange-Act-Assert) structure with BDD-style naming (given-when-then).

## Building

### Local Build

```bash
./scripts/build.sh
```

### CI/CD

The project uses GitHub Actions for continuous integration:

- Runs tests on every push/PR
- Builds APK and iOS artifacts
- Automatic semantic versioning releases

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details
