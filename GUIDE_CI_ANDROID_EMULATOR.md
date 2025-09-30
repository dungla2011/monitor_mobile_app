# CI Android Emulator Setup Guide

## Overview
Hướng dẫn setup Android emulator trong GitHub Actions CI để chạy integration tests.

## Current Setup

### Emulator Configuration
- **API Level**: 29 (Android 10)
- **Target**: google_apis 
- **Architecture**: x86_64
- **Profile**: Nexus 6
- **RAM**: 4096M
- **Heap**: 512M
- **Cores**: 2

### CI Workflow Steps

#### 1. Enable KVM (Hardware Acceleration)
```yaml
- name: Enable KVM group perms
  run: |
    echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger --name-match=kvm
```

#### 2. Setup Java & Android SDK
```yaml
- name: Setup Java for Android
  uses: actions/setup-java@v4
  with:
    distribution: 'zulu'
    java-version: '17'
    
- name: Setup Android SDK
  uses: android-actions/setup-android@v3
```

#### 3. AVD Caching
```yaml
- name: AVD cache
  uses: actions/cache@v4
  id: avd-cache
  with:
    path: |
      ~/.android/avd/*
      ~/.android/adb*
    key: avd-29
```

#### 4. Create & Run Emulator
```yaml
- name: Run integration tests on Android Emulator
  uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 29
    target: google_apis
    arch: x86_64
    profile: Nexus 6
    cores: 2
    ram-size: 4096M
    heap-size: 512M
    script: |
      flutter test integration_test/ --verbose
```

## Performance Considerations

### CI Runtime Impact
- **Without Emulator**: ~2-3 minutes
- **With Emulator**: ~8-12 minutes
- **First run**: ~15-20 minutes (no cache)
- **Cached runs**: ~8-10 minutes

### Optimization Strategies

#### 1. AVD Caching
- Cache emulator snapshot sau first run
- Giảm thời gian setup từ ~5 phút xuống ~1 phút

#### 2. Emulator Configuration
- **RAM**: 4GB (đủ cho Flutter app)
- **Cores**: 2 (balance performance vs cost)
- **API Level 29**: Stable, widely supported

#### 3. Test Timeouts
- Tăng timeout cho emulator (chậm hơn real device)
- `pumpAndSettle(Duration(seconds: 15))`
- Performance test: 15s thay vì 5s

## Integration Test Adaptations

### Timeouts
```dart
// App launch
await tester.pumpAndSettle(const Duration(seconds: 10));

// Performance test
expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // 15s
```

### Debug Output
```dart
print('✅ App launched successfully on Android emulator');
print('⏱️ App loaded in ${stopwatch.elapsedMilliseconds}ms');
```

### Error Handling
- Graceful degradation nếu emulator fail
- Detailed logging cho debugging

## Cost Considerations

### GitHub Actions Minutes
- **Free tier**: 2000 minutes/month
- **Emulator tests**: ~10 minutes/run
- **Impact**: ~200 runs/month (reasonable)

### Optimization Tips
- Chỉ chạy trên `main` branch (production)
- Skip emulator cho PR (chỉ unit tests)
- Conditional emulator based on file changes

## Alternative Configurations

### Lighter Emulator
```yaml
api-level: 28
target: default  # No Google APIs
arch: x86_64
ram-size: 2048M  # 2GB RAM
heap-size: 256M  # Smaller heap
```

### Conditional Emulator
```yaml
# Only run integration tests for main branch
- name: Run integration tests
  if: github.ref == 'refs/heads/main'
  uses: reactivecircus/android-emulator-runner@v2
```

### File-based Triggering
```yaml
# Only run if app files changed
- uses: dorny/paths-filter@v2
  id: changes
  with:
    filters: |
      app:
        - 'lib/**'
        - 'integration_test/**'
        
- name: Run integration tests
  if: steps.changes.outputs.app == 'true'
```

## Troubleshooting

### Common Issues

#### 1. Emulator Startup Timeout
**Error**: `Emulator did not start within 300 seconds`

**Solutions**:
- Tăng timeout trong action
- Giảm RAM/heap size
- Use lighter API level

#### 2. KVM Not Available
**Error**: `KVM is not available`

**Solutions**:
- GitHub Actions runners support KVM
- Ensure KVM permissions step runs first

#### 3. Tests Timeout
**Error**: `Test timed out after 30 seconds`

**Solutions**:
- Tăng test timeouts
- Add more `pumpAndSettle` calls
- Simplify test scenarios

#### 4. Out of Memory
**Error**: `OutOfMemoryError`

**Solutions**:
- Giảm RAM allocation
- Giảm heap size
- Use lighter emulator profile

### Debug Commands
```yaml
# Check emulator status
script: |
  adb devices
  flutter devices
  flutter test integration_test/ --verbose
```

## Best Practices

### 1. Progressive Enhancement
- Start với unit tests only
- Add emulator khi cần thiết
- Monitor CI performance impact

### 2. Smart Caching
- Cache AVD snapshots
- Cache Flutter dependencies
- Cache Android SDK components

### 3. Fail Fast
- Run unit tests trước integration tests
- Skip emulator nếu unit tests fail

### 4. Resource Management
- Use appropriate emulator size
- Clean up resources sau tests
- Monitor GitHub Actions usage

## Current Status

✅ **Enabled**: Android emulator integration tests
✅ **Cached**: AVD snapshots for faster startup  
✅ **Optimized**: Reasonable resource allocation
✅ **Monitored**: Performance impact tracking

**Expected CI time**: ~8-12 minutes total
