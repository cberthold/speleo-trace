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
├── models/                # Data models
├── viewmodels/            # Business logic & state management
├── views/                 # UI components
├── utils/                 # Utility functions
└── services/              # External services (future)

test/
├── models/                # Model tests
├── viewmodels/            # ViewModel tests
├── utils/                 # Utility tests
└── widget_test.dart       # Widget integration tests

.github/workflows/         # CI/CD pipelines
scripts/                   # Build scripts
```

## Architecture

This project follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Represent data structures and business entities
- **ViewModels**: Handle business logic and state management
- **Views**: Pure UI components that react to ViewModel changes
- **Utils**: Pure utility functions for calculations
- **Services**: Abstractions for external dependencies

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
