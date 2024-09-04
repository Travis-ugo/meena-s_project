import 'package:flutter_test/flutter_test.dart';
import 'package:meena/feature/view_models/dashboard_viewmodel.dart';
import 'package:meena/feature/view_models/api_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('DashboardProvider', () {
    late DashboardProvider dashboardProvider;
    late MockApiService mockApiService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockApiService = MockApiService();
      mockSharedPreferences = MockSharedPreferences();
      dashboardProvider = DashboardProvider(
        token: 'test_token',
        apiService: mockApiService,
        sharedPreferences: mockSharedPreferences,
      );

      registerFallbackValue(FakeUri());
      registerFallbackValue(http.MultipartRequest('POST', FakeUri()));
    });

    group('DashBoard Data', () {
      test('loadDataDashboard sets dashboards correctly on success', () async {
        when(() => mockSharedPreferences.getString('user_token'))
            .thenReturn('mock_token');
        when(() => mockApiService.getwithToken(
            DashboardProvider.dashboardsUrl, 'mock_token', false)).thenAnswer(
          (_) => Future.value(
            [
              {
                'dashboardId': 1,
                'name': 'Test Dashboard',
                'widgets': [],
              },
            ],
          ),
        );

        await dashboardProvider.loadDataDashboard();

        expect(dashboardProvider.dashboards.length, 1);
        expect(dashboardProvider.dashboards[0].dashboardId, 1);
        expect(dashboardProvider.dashboards[0].name, 'Test Dashboard');
        expect(dashboardProvider.isLoading, false);
      });

      test('loadDataDashboard sets dashboards to empty list on failure',
          () async {
        when(() => mockSharedPreferences.getString('user_token'))
            .thenReturn('mock_token');
        when(() => mockApiService.getwithToken(
                DashboardProvider.dashboardsUrl, 'mock_token', false))
            .thenThrow(Exception('Failed to load'));

        await dashboardProvider.loadDataDashboard();

        expect(dashboardProvider.dashboards.isEmpty, true);
        expect(dashboardProvider.isLoading, false);
      });
    });

    group('DashBoard Widget Data', () {
      test('loads dashboard data successfully', () async {
        const dashboardId = 1;
        const accessToken = 'test_token';

        final dashboardData = {
          'dashboardId': 1,
          'name': 'Test Dashboard',
          'widgets': [
            {
              'widgetId': 1,
              'name': 'Test Widget',
              'graphParameters':
                  '{"configdata": {"yAxis": ["Temperature"], "timeRange": "60"}}',
              'modalities': [
                {'name': 'Temperature', 'modalityId': '1'}
              ]
            }
          ]
        };

        when(() => mockApiService.postMultipartwithToken(any(), any(), any()))
            .thenAnswer((_) async => dashboardData);

        when(() => mockApiService
                .getwithTimestamp(any(), any(), any(), any(), any()))
            .thenAnswer((_) async => [
                  {'timestamp': 1620000000, 'value': 25.0}
                ]);

        when(() => mockSharedPreferences.getString('user_token'))
            .thenReturn(accessToken);

        await dashboardProvider.loadDashboardForTab(dashboardId);

        expect(dashboardProvider.dashboardData.containsKey(1), true);

        expect(dashboardProvider.dashboardData[dashboardId]?.dashboardId,
            dashboardId);
        verify(() => mockApiService.postMultipartwithToken(any(), any(), any()))
            .called(1);

        verify(() => mockApiService.getwithTimestamp(
            any(), any(), any(), any(), any())).called(1);
      });

      test('loadDashboardForTab handles errors correctly', () async {
        const dashboardId = 1;
        const accessToken = 'test_token';

        when(() => mockApiService.postMultipartwithToken(any(), any(), any()))
            .thenThrow(Exception('Failed to load dashboard'));
        when(() => mockSharedPreferences.getString('user_token'))
            .thenReturn(accessToken);

        await dashboardProvider.loadDashboardForTab(dashboardId);

        expect(dashboardProvider.dashboardData[dashboardId], isNull);

        verify(() => mockApiService.postMultipartwithToken(any(), any(), any()))
            .called(1);
      });
    });
  });
}
