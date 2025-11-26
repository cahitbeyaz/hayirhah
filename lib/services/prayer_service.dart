import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_model.dart';

class PrayerService {
  // Method 13 is Diyanet İşleri Başkanlığı, Turkey
  static const String _baseUrl = 'http://api.aladhan.com/v1/timings';
  static const int _method = 13; 

  // Fetch location from IP
  Future<Map<String, dynamic>> getLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get location from IP');
      }
    } catch (e) {
      throw Exception('Failed to connect to IP service: $e');
    }
  }

  // Fetch calendar prayer times (monthly)
  Future<List<PrayerTimes>> getCalendarTimes({double? latitude, double? longitude, String? city, String? country}) async {
    final now = DateTime.now();
    Uri url;

    if (city != null && country != null) {
      url = Uri.parse('http://api.aladhan.com/v1/calendarByCity/${now.year}/${now.month}?city=$city&country=$country&method=$_method');
    } else if (latitude != null && longitude != null) {
      url = Uri.parse('http://api.aladhan.com/v1/calendar/${now.year}/${now.month}?latitude=$latitude&longitude=$longitude&method=$_method');
    } else {
      throw Exception('Either coordinates or city/country must be provided');
    }

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => PrayerTimes.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load calendar times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
