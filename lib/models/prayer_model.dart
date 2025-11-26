class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date; // DD-MM-YYYY

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final date = json['date']['gregorian']['date'];
    return PrayerTimes(
      fajr: timings['Fajr'].split(' ')[0], // Remove (EST) etc if present
      sunrise: timings['Sunrise'].split(' ')[0],
      dhuhr: timings['Dhuhr'].split(' ')[0],
      asr: timings['Asr'].split(' ')[0],
      maghrib: timings['Maghrib'].split(' ')[0],
      isha: timings['Isha'].split(' ')[0],
      date: date,
    );
  }

  Map<String, String> toMap() {
    return {
      'İmsak': fajr,
      'Güneş': sunrise,
      'Öğle': dhuhr,
      'İkindi': asr,
      'Akşam': maghrib,
      'Yatsı': isha,
    };
  }

  // Helper to get time by name (Turkish)
  String? getTime(String prayerName) {
    switch (prayerName) {
      case 'İmsak': return fajr;
      case 'Güneş': return sunrise;
      case 'Öğle': return dhuhr;
      case 'İkindi': return asr;
      case 'Akşam': return maghrib;
      case 'Yatsı': return isha;
      default: return null;
    }
  }
}
