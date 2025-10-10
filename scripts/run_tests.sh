#!/bin/bash
# Bash script để chạy tất cả tests và generate coverage report
# Run Tests Script for Ping365

echo "🚀 Bắt đầu chạy test automation..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter không được tìm thấy. Vui lòng cài đặt Flutter trước."
    exit 1
fi

echo "📦 Cài đặt dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi cài đặt dependencies"
    exit 1
fi

echo "🔧 Generate mocks..."
dart run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    echo "⚠️ Cảnh báo: Không thể generate mocks"
fi

echo "📝 Kiểm tra code formatting..."
dart format --output=none --set-exit-if-changed .

if [ $? -ne 0 ]; then
    echo "⚠️ Code formatting không đúng. Chạy 'dart format .' để sửa."
fi

echo "🔍 Analyze code..."
flutter analyze

if [ $? -ne 0 ]; then
    echo "⚠️ Có issues trong code analysis"
fi

echo "🧪 Chạy unit tests..."
flutter test --coverage

if [ $? -ne 0 ]; then
    echo "❌ Unit tests thất bại"
    exit 1
fi

echo "🎯 Chạy widget tests..."
flutter test test/widget/

if [ $? -ne 0 ]; then
    echo "❌ Widget tests thất bại"
    exit 1
fi

echo "🔗 Chạy integration tests..."
flutter test integration_test/

if [ $? -ne 0 ]; then
    echo "❌ Integration tests thất bại"
    exit 1
fi

# Generate HTML coverage report if lcov is available
echo "📊 Tạo coverage report..."
if [ -f "coverage/lcov.info" ]; then
    echo "✅ Coverage data được tạo tại: coverage/lcov.info"
    
    # Try to generate HTML report if genhtml is available
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo "📊 HTML coverage report: coverage/html/index.html"
    else
        echo "💡 Để tạo HTML report, cài đặt lcov: sudo apt-get install lcov"
    fi
else
    echo "⚠️ Không tìm thấy coverage data"
fi

echo "✅ Tất cả tests đã hoàn thành thành công!"
echo "📋 Tóm tắt:"
echo "  - Unit tests: ✅"
echo "  - Widget tests: ✅"  
echo "  - Integration tests: ✅"
echo "  - Coverage report: coverage/lcov.info"
