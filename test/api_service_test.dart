import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meena/feature/view_models/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

class FakeUri extends Fake implements Uri {}

void main() {
  group("Test for APi Service", () {
    late http.Client mockHttpClient;
    late ApiService apiService;
    late MockStreamedResponse mockStreamedResponse;

    setUpAll(() {
      registerFallbackValue(FakeUri());
      registerFallbackValue(http.MultipartRequest('POST', FakeUri()));
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = ApiService(httpClient: mockHttpClient);
      mockStreamedResponse = MockStreamedResponse();
    });

    group("construct the groups", () {
      test("Test if the api service does not require an mockHttpClient", () {
        expect(ApiService(), isNotNull);
      });
    });

    group("Apiservices test", () {
      const String testUrl = "test-url";
      const String token = "test-token";
      const String fileBaseUrl = "https://example.com/";
      const Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      group('test the getWithToken function, for Success and Failure', () {
        test("getwithToken : success with body", () async {
          final mockResponse = MockResponse();
          final response =
              http.Response(jsonEncode({"data": "test value"}), 200);

          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockResponse.body).thenReturn('{"data":"test value"}');

          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) => Future.value(response));

          final result = await apiService.getwithToken(testUrl, token, true);
          expect(result, {"data": "test value"});
        });

        test("getwithToken : success without body", () async {
          const String url = fileBaseUrl + testUrl;

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockResponse.body).thenReturn('{"data":"test value"}');
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          final response = await apiService.getwithToken(url, token, false);
          expect(response, {"data": "test value"});
        });

        test("getwithToken : failure without body", () async {
          const String url = fileBaseUrl + testUrl;

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(404);
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          expect(
            () async => await apiService.getwithToken(url, token, false),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('getwithEndpoint: Test success and failure scenarios', () {
        test("getwithEndpoint : success", () async {
          const String endpoint = "/endpoint";

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockResponse.body).thenReturn('{"data":"test value"}');
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          final response =
              await apiService.getwithEndpoint(testUrl, endpoint, token);
          expect(response, {"data": "test value"});
        });

        test("getwithEndpoint : failure", () async {
          const String endpoint = "/endpoint";

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(404);
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          expect(
            () async =>
                await apiService.getwithEndpoint(testUrl, endpoint, token),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('getwithTimestamp: Test success and failure scenarios', () {
        test("getwithTimestamp : success", () async {
          const String endpoint = "/endpoint";
          const String startTime = "2024-09-01T00:00:00Z";
          const String endTime = "2024-09-01T23:59:59Z";

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockResponse.body).thenReturn('{"data":"test value"}');
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          final response = await apiService.getwithTimestamp(
              testUrl, endpoint, startTime, endTime, token);
          expect(response, {"data": "test value"});
        });

        test("getwithTimestamp : failure", () async {
          const String endpoint = "/endpoint";
          const String startTime = "2024-09-01T00:00:00Z";
          const String endTime = "2024-09-01T23:59:59Z";

          final mockResponse = MockResponse();
          when(() => mockResponse.statusCode).thenReturn(404);
          when(
            () => mockHttpClient.get(any(), headers: headers),
          ).thenAnswer((_) => Future.value(mockResponse));

          expect(
            () async => await apiService.getwithTimestamp(
                testUrl, endpoint, startTime, endTime, token),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('postMultipartwithToken', () {
        test('returns correct data on success', () async {
          const url = 'test_url';
          const token = 'test_token';
          final fields = {'key1': 'value1', 'key2': 'value2'};

          final response = http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'key': 'value'}))),
            200,
          );

          when(() => mockHttpClient.send(any()))
              .thenAnswer((_) async => response);

          when(() => mockStreamedResponse.statusCode).thenReturn(200);

          final result =
              await apiService.postMultipartwithToken(url, token, fields);

          expect(result, {'key': 'value'});
          verify(() => mockHttpClient.send(any())).called(1);
        });

        test('throws exception on failure', () async {
          const url = 'test_url';
          const token = 'test_token';
          final fields = {'key1': 'value1', 'key2': 'value2'};

          when(() => mockStreamedResponse.statusCode).thenReturn(400);
          when(() => mockStreamedResponse.stream.bytesToString())
              .thenAnswer((_) async => '');

          when(() => mockHttpClient.send(any()))
              .thenAnswer((_) async => mockStreamedResponse);

          expect(
            () async =>
                await apiService.postMultipartwithToken(url, token, fields),
            throwsA(isA<Exception>()),
          );
          verify(() => mockHttpClient.send(any())).called(1);
        });

        test('returns data if the http call completes successfully', () async {
          const url = 'http://example.com/test_url';
          const token = 'test_token';
          final fields = {'field1': 'value1'};
          final response = http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'key': 'value'}))),
            200,
          );

          when(() => mockHttpClient.send(any()))
              .thenAnswer((_) async => response);

          final result =
              await apiService.postMultipartwithToken(url, token, fields);

          expect(result, {'key': 'value'});
        });

        test('throws an error if the response status is not 200', () async {
          const url = 'http://example.com/test_url';
          const token = 'test_token';
          final fields = {'field1': 'value1'};
          final response = http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'error': 'error'}))),
            400,
          );

          when(() => mockHttpClient.send(any()))
              .thenAnswer((_) async => response);

          expect(
            () async =>
                await apiService.postMultipartwithToken(url, token, fields),
            throwsA(isA<Exception>()),
          );
        });
        // });
      });
    });
  });
}
