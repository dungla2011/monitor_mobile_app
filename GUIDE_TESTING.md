# 🧪 Test Automation Guide - Ping24

Hướng dẫn chi tiết về test automation và CI/CD cho Ping24.

## 📋 Tổng quan

Dự án này sử dụng một hệ thống test automation hoàn chỉnh bao gồm:

- **Unit Tests**: Test các functions, methods và services
- **Widget Tests**: Test các UI components
- **Integration Tests**: Test toàn bộ user flow
- **CI/CD Pipeline**: Automated testing và deployment

## 🚀 Quick Start

### Chạy tất cả tests

```bash
# Windows (PowerShell)
.\scripts\run_tests.ps1

# Linux/macOS
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

### Chạy từng loại test riêng biệt

```bash
# Unit tests
flutter test test/unit/

# Widget tests  
flutter test test/widget/

# Integration tests
flutter test integration_test/

# Với coverage report
flutter test --coverage
```

## 📁 Cấu trúc thư mục Test

```
test/
├── fixtures/           # Mock data và test data
│   └── mock_data.dart
├── mocks/              # Generated mock classes
├── unit/               # Unit tests
│   ├── base_crud_service_test.dart
│   └── monitor_config_crud_service_test.dart
├── widget/             # Widget tests
│   └── crud_dialog_test.dart
├── integration/        # Integration test helpers
└── test_config.dart    # Test configuration

integration_test/       # Flutter integration tests
└── app_test.dart

scripts/               # Test automation scripts
├── run_tests.ps1     # Windows PowerShell script
└── run_tests.sh      # Linux/macOS bash script
```

## 🔧 Thiết lập môi trường Test

### 1. Cài đặt dependencies

```bash
flutter pub get
```

### 2. Generate mock classes

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Cấu hình IDE

**VS Code**: Cài đặt extensions:
- Flutter
- Dart
- Flutter Coverage

**Android Studio**: Cài đặt plugins:
- Flutter
- Dart

## 📊 Coverage Report

### Generate coverage report

```bash
flutter test --coverage
```

### Xem HTML coverage report

```bash
# Cài đặt lcov (nếu chưa có)
# Windows: choco install lcov
# Ubuntu: sudo apt-get install lcov
# macOS: brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Mở trong browser
open coverage/html/index.html
```

## 🧪 Viết Tests

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:monitor_app/services/base_crud_service.dart';

void main() {
  group('BaseCrudService', () {
    test('should parse successful response correctly', () {
      // Arrange
      final response = http.Response('{"code":1,"payload":{"test":"data"}}', 200);
      
      // Act
      final result = BaseCrudService.parseApiResponse(response, 'Test');
      
      // Assert
      expect(result['success'], true);
      expect(result['data'], isNotNull);
    });
  });
}
```

### Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monitor_app/widgets/crud_dialog.dart';

void main() {
  testWidgets('should display dialog with title', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(
      home: CrudDialog(title: 'Test', fields: [], onSubmit: (_) {}),
    ));
    
    // Act & Assert
    expect(find.text('Test'), findsOneWidget);
  });
}
```

### Integration Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monitor_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('app should launch successfully', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Pipeline tự động chạy khi:
- Push code lên `main` hoặc `develop` branch
- Tạo Pull Request

### Các bước trong Pipeline:

1. **Test Stage**:
   - Code formatting check
   - Static analysis
   - Unit tests
   - Widget tests
   - Integration tests
   - Coverage report

2. **Build Stage**:
   - Build Web app
   - Build Android APK
   - Build iOS app (trên macOS runner)

3. **Security Stage**:
   - Vulnerability scanning
   - Dependency check

4. **Deploy Stage**:
   - Deploy web app lên GitHub Pages
   - Upload APK artifacts

### Cấu hình Secrets

Trong GitHub repository settings, thêm các secrets:

```
GITHUB_TOKEN          # Tự động có sẵn
CODECOV_TOKEN        # Cho coverage reporting
```

## 📈 Best Practices

### 1. Test Organization

- **Unit tests**: Test từng function/method riêng biệt
- **Widget tests**: Test UI components và interactions
- **Integration tests**: Test user journeys hoàn chỉnh

### 2. Naming Conventions

```dart
// Unit test
void main() {
  group('ClassName', () {
    group('methodName', () {
      test('should do something when condition', () {
        // Test implementation
      });
    });
  });
}
```

### 3. Test Data Management

- Sử dụng mock data từ `test/fixtures/mock_data.dart`
- Tạo test data generators cho reusability
- Isolate test data để tránh dependencies

### 4. Mocking

```dart
// Generate mocks
@GenerateMocks([http.Client])
import 'my_test.mocks.dart';

// Use mocks
final mockClient = MockClient();
when(mockClient.get(any)).thenAnswer((_) async => 
  http.Response('{"success": true}', 200)
);
```

## 🐛 Debugging Tests

### Chạy single test

```bash
flutter test test/unit/base_crud_service_test.dart
```

### Debug mode

```bash
flutter test --debug test/unit/base_crud_service_test.dart
```

### Verbose output

```bash
flutter test --verbose
```

## 📝 Test Checklist

### Trước khi commit:

- [ ] Tất cả tests pass
- [ ] Code coverage >= 80%
- [ ] Không có linter warnings
- [ ] Code được format đúng
- [ ] Mock data được update nếu cần

### Trước khi merge PR:

- [ ] CI/CD pipeline pass
- [ ] Integration tests pass
- [ ] Performance tests pass (nếu có)
- [ ] Security scan pass

## 🔍 Troubleshooting

### Common Issues

1. **Mock generation fails**:
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Integration tests timeout**:
   - Tăng timeout trong test
   - Check network connectivity
   - Verify test data setup

3. **Coverage report không generate**:
   - Check lcov installation
   - Verify test files có chạy
   - Check file permissions

### Performance Issues

- Sử dụng `pumpAndSettle()` thay vì `pump()` cho animations
- Mock network calls để tránh real API calls
- Cleanup resources sau mỗi test

## 📚 Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [GitHub Actions for Flutter](https://docs.github.com/en/actions)

## 🤝 Contributing

Khi thêm features mới:

1. Viết tests trước (TDD approach)
2. Ensure coverage >= 80%
3. Update documentation
4. Run full test suite
5. Update CI/CD nếu cần

---

**Happy Testing! 🧪✨**
