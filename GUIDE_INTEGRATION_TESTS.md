# Integration Tests Guide

## Tổng quan
Integration tests kiểm tra toàn bộ luồng hoạt động của app trên thiết bị thật hoặc emulator.

## Yêu cầu
- **Android device** hoặc **iOS simulator** kết nối
- Không thể chạy trên Chrome/Web (Flutter limitation)

## Cách chạy Integration Tests

### 1. Kiểm tra devices có sẵn
```bash
flutter devices
```

### 2. Chạy integration tests
```bash
# Chạy trên device mặc định
flutter test integration_test/

# Chạy trên device cụ thể
flutter test integration_test/ -d <device_id>

# Ví dụ với Android
flutter test integration_test/ -d emulator-5554

# Ví dụ với iOS
flutter test integration_test/ -d "iPhone 15"
```

### 3. Setup Android Emulator (nếu chưa có)
```bash
# Tạo AVD mới
flutter emulators --create --name test_device

# Khởi động emulator
flutter emulators --launch test_device

# Hoặc dùng Android Studio để tạo và chạy emulator
```

### 4. Setup iOS Simulator (macOS only)
```bash
# Mở iOS Simulator
open -a Simulator

# Hoặc dùng Xcode để chạy simulator
```

## CI/CD Behavior

### GitHub Actions
- **Unit Tests**: ✅ Luôn chạy (không cần device)
- **Widget Tests**: ✅ Luôn chạy (không cần device)  
- **Integration Tests**: ⚠️ Skip nếu không có device

### Lý do skip trong CI
- GitHub Actions runners không có Android/iOS devices
- Web không support integration tests
- Cần setup phức tạp cho Android emulator trong CI

### Để enable Integration Tests trong CI
Có thể thêm Android emulator vào workflow:

```yaml
- name: Enable KVM group perms
  run: |
    echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger --name-match=kvm

- name: Setup Android SDK
  uses: android-actions/setup-android@v2

- name: Setup Android Emulator
  uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 29
    script: flutter test integration_test/
```

## Test Coverage

### Current Integration Tests
- ✅ App launch và stability
- ✅ Navigation flow
- ✅ Monitor Config CRUD (placeholder)
- ✅ Monitor Item CRUD (placeholder)
- ✅ Error handling
- ✅ Performance tests

### TODO
- [ ] Thực thi CRUD operations với real data
- [ ] Test network error scenarios
- [ ] Test offline functionality
- [ ] Test authentication flow
- [ ] Test notifications

## Troubleshooting

### "No devices connected"
```bash
# Kiểm tra devices
flutter devices

# Khởi động emulator
flutter emulators --launch <emulator_name>

# Hoặc kết nối Android device qua USB
```

### "Web devices are not supported"
- Integration tests không thể chạy trên Chrome
- Chỉ chạy trên Android/iOS devices

### Tests timeout
- Tăng timeout trong test code
- Đảm bảo emulator có đủ RAM (2GB+)
- Đảm bảo internet connection stable

## Best Practices

1. **Chạy unit/widget tests trước** integration tests
2. **Mock external dependencies** trong integration tests
3. **Test critical user flows** thay vì tất cả features
4. **Use page object pattern** cho maintainability
5. **Clean up test data** sau mỗi test

## Commands Summary

```bash
# Full test suite
flutter test --coverage                    # Unit + Widget tests
flutter test integration_test/             # Integration tests

# CI simulation
flutter analyze                           # Code analysis
flutter test --coverage                  # Automated tests
dart format --output=none --set-exit-if-changed .  # Format check
```
