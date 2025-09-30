import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_app/services/base_crud_service.dart';
import '../fixtures/mock_data.dart';

void main() {
  group('BaseCrudService', () {
    group('parseApiResponse', () {
      test('should parse successful response correctly', () {
        final response = http.Response(MockData.mockSuccessResponseBody, 200);

        final result = BaseCrudService.parseApiResponse(
          response,
          'Test Operation',
          successMessage: 'Test Success',
        );

        expect(result['success'], true);
        expect(result['data'], isNotNull);
        expect(result['message'], 'Success');
      });

      test('should handle API error response (code != 1)', () {
        final response = http.Response(MockData.mockErrorResponseBody, 200);

        final result = BaseCrudService.parseApiResponse(
          response,
          'Test Operation',
          errorMessage: 'Test Error',
        );

        expect(result['success'], false);
        expect(result['message'], 'Error occurred');
      });

      test('should handle HTTP error status codes', () {
        final response = http.Response('{"message": "Not found"}', 404);

        final result = BaseCrudService.parseApiResponse(
          response,
          'Test Operation',
        );

        expect(result['success'], false);
        expect(result['message'], 'Not found');
      });

      test('should handle invalid JSON response', () {
        final response = http.Response(
          MockData.mockInvalidJsonResponseBody,
          200,
        );

        final result = BaseCrudService.parseApiResponse(
          response,
          'Test Operation',
        );

        expect(result['success'], false);
        expect(result['message'], contains('200'));
      });
    });

    group('baseUrl', () {
      test('should have correct base URL', () {
        expect(BaseCrudService.baseUrl, 'https://mon.lad.vn');
      });
    });

    group('constants', () {
      test('should have correct base URL constant', () {
        const expectedUrl = 'https://mon.lad.vn';
        expect(BaseCrudService.baseUrl, expectedUrl);
      });
    });
  });
}
