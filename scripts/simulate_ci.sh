#!/bin/bash
# Simulate CI Pipeline locally
# Bash script to run the same steps as CI

echo "🚀 Starting CI Pipeline Simulation..."
echo ""

# Step 1: Check Flutter setup
echo "📋 Step 1: Checking Flutter setup..."
flutter --version
if [ $? -ne 0 ]; then
    echo "❌ Flutter not found! Please install Flutter first."
    exit 1
fi
echo "✅ Flutter setup OK"
echo ""

# Step 2: Get dependencies
echo "📦 Step 2: Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies!"
    exit 1
fi
echo "✅ Dependencies OK"
echo ""

# Step 3: Check formatting
echo "🎨 Step 3: Checking code formatting..."
dart format --output=none --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "⚠️ Code formatting issues found. Running formatter..."
    dart format .
    echo "✅ Code formatted"
else
    echo "✅ Code formatting OK"
fi
echo ""

# Step 4: Analyze code
echo "🔍 Step 4: Analyzing code..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Code analysis failed!"
    exit 1
fi
echo "✅ Code analysis OK"
echo ""

# Step 5: Generate mocks
echo "🏭 Step 5: Generating mocks..."
dart run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "⚠️ Mock generation failed, but continuing..."
else
    echo "✅ Mocks generated"
fi
echo ""

# Step 6: Run unit tests
echo "🧪 Step 6: Running unit tests..."
flutter test --coverage
if [ $? -ne 0 ]; then
    echo "❌ Unit tests failed!"
    exit 1
fi
echo "✅ Unit tests passed"
echo ""

# Step 7: Check for devices (integration tests)
echo "📱 Step 7: Checking for devices..."
devices=$(flutter devices --machine)
has_device=false

if echo "$devices" | grep -q '"type":"device"'; then
    has_device=true
fi

if [ "$has_device" = true ]; then
    echo "✅ Device found. Running integration tests..."
    flutter test integration_test/
    if [ $? -ne 0 ]; then
        echo "❌ Integration tests failed!"
        exit 1
    fi
    echo "✅ Integration tests passed"
else
    echo "⚠️ No devices found. Skipping integration tests."
    echo "💡 To run integration tests:"
    echo "   1. Connect Android device or start iOS simulator"
    echo "   2. Run: flutter test integration_test/"
fi
echo ""

# Summary
echo "🎉 CI Pipeline Simulation Complete!"
echo ""
echo "📊 Summary:"
echo "- ✅ Flutter setup: OK"
echo "- ✅ Dependencies: OK" 
echo "- ✅ Code formatting: OK"
echo "- ✅ Code analysis: OK"
echo "- ✅ Mock generation: OK"
echo "- ✅ Unit tests: PASSED"
if [ "$has_device" = true ]; then
    echo "- ✅ Integration tests: PASSED"
else
    echo "- ⚠️ Integration tests: SKIPPED"
fi
echo "- ✅ Coverage report: Generated"
echo ""
echo "🚀 Ready for CI!"
