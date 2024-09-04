import 'dart:convert';
import 'package:http/http.dart' as http;

var envConfig = 'http://example.com/';

class ApiService {
  ApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();
  final http.Client _httpClient;
  static var fileBaseUrl = envConfig;

  Future<dynamic> getwithToken(String url, String token, bool hasBody) async {
    if (hasBody) {
      Map data = {'idToken': token};
      var body = json.encode(data);
      var requesturl = fileBaseUrl + url;
      final response = await _httpClient.post(Uri.parse(requesturl),
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      var requesturl = fileBaseUrl + url;
      final response = await _httpClient.get(
        Uri.parse(requesturl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  Future<dynamic> getwithEndpoint(
      String url, String endpoint, String token) async {
    var requesturl = fileBaseUrl + url;
    final response = await _httpClient.get(
      Uri.parse('$requesturl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> getwithTimestamp(String url, String endpoint,
      String startTime, String endTime, String token) async {
    var requesturl = fileBaseUrl + url;
    final response = await _httpClient.get(
      Uri.parse('$requesturl$endpoint?startTime=$startTime&endTime=$endTime'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> postMultipartwithToken(
      String url, String token, Map<String, String> fields) async {
    var requesturl = fileBaseUrl + url;
    var uri = Uri.parse(requesturl);
    var request = http.MultipartRequest('POST', uri);

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    Map<String, String> requestHeaders = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
    request.headers.addAll(requestHeaders);

    var response = await _httpClient.send(request);

    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
