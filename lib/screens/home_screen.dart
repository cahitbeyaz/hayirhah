import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import '../services/prayer_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = PrayerService();
  List<PrayerTimes> _calendarPrayers = [];
  PrayerTimes? _todayPrayers;
  bool _isLoading = true;
  String? _errorMessage;
  String _locationMessage = "Konum Bulunuyor...";
  String? _nextPrayerName;
  Duration? _timeUntilNextPrayer;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayers();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_todayPrayers != null) {
        _calculateNextPrayer();
      }
    });
  }

  void _initLocationAndPrayers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationData = await _prayerService.getLocationFromIP();
      final city = locationData['city'];
      final country = locationData['country'];
      final lat = locationData['lat'];
      final lon = locationData['lon'];

      setState(() {
        _locationMessage = "$city, $country";
      });

      final times = await _prayerService.getCalendarTimes(
        latitude: lat,
        longitude: lon,
      );

      _processCalendarData(times);

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Konum otomatik olarak bulunamadı. Lütfen manuel seçiniz.";
          _isLoading = false;
        });
      }
    }
  }

  void _fetchPrayersByCity(String city, String country) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationMessage = "$city, $country";
    });

    try {
      final times = await _prayerService.getCalendarTimes(city: city, country: country);
      _processCalendarData(times);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _processCalendarData(List<PrayerTimes> times) {
    if (!mounted) return;

    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);

    PrayerTimes? today;
    try {
      today = times.firstWhere((p) => p.date == todayStr);
    } catch (e) {
      if (times.isNotEmpty) {
        today = times.firstWhere((p) => int.parse(p.date.split('-')[0]) == now.day, orElse: () => times.first);
      }
    }

    setState(() {
      _calendarPrayers = times;
      _todayPrayers = today;
      _isLoading = false;
    });
    _calculateNextPrayer();
  }

  void _showLocationDialog() {
    final cityController = TextEditingController();
    final countryController = TextEditingController(text: "Turkey");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konum Seç", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "Şehir"),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: "Ülke"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (cityController.text.isNotEmpty && countryController.text.isNotEmpty) {
                _fetchPrayersByCity(cityController.text, countryController.text);
              }
            },
            child: const Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  void _calculateNextPrayer() {
    if (_todayPrayers == null) return;

    final now = DateTime.now();
    final prayers = {
      'İmsak': _parseTime(_todayPrayers!.fajr),
      'Güneş': _parseTime(_todayPrayers!.sunrise),
      'Öğle': _parseTime(_todayPrayers!.dhuhr),
      'İkindi': _parseTime(_todayPrayers!.asr),
      'Akşam': _parseTime(_todayPrayers!.maghrib),
      'Yatsı': _parseTime(_todayPrayers!.isha),
    };

    String? nextName;
    DateTime? nextTime;

    final sortedPrayers = prayers.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (var entry in sortedPrayers) {
      if (entry.value.isAfter(now)) {
        nextName = entry.key;
        nextTime = entry.value;
        break;
      }
    }

    if (nextName == null) {
      nextName = 'İmsak';
      nextTime = prayers['İmsak']!.add(const Duration(days: 1));
    }

    setState(() {
      _nextPrayerName = nextName;
      _timeUntilNextPrayer = nextTime!.difference(now);
    });
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF8C9EFF),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage != null
                  ? _buildErrorView()
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _buildTodayHorizontalList(),
                                  const SizedBox(height: 32),
                                  _buildForecastList(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: GoogleFonts.outfit(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showLocationDialog,
              child: const Text("Manuel Konum Seç"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationMessage,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM, EEEE', 'tr_TR').format(DateTime.now()),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_location_alt, color: Colors.white70),
                onPressed: _showLocationDialog,
                tooltip: "Konumu Değiştir",
              )
            ],
          ),
          const SizedBox(height: 32),
          if (_timeUntilNextPrayer != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _nextPrayerName ?? "",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_timeUntilNextPrayer!),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTodayHorizontalList() {
    if (_todayPrayers == null) return const SizedBox();

    final prayers = [
      {'name': 'İmsak', 'time': _todayPrayers!.fajr},
      {'name': 'Güneş', 'time': _todayPrayers!.sunrise},
      {'name': 'Öğle', 'time': _todayPrayers!.dhuhr},
      {'name': 'İkindi', 'time': _todayPrayers!.asr},
      {'name': 'Akşam', 'time': _todayPrayers!.maghrib},
      {'name': 'Yatsı', 'time': _todayPrayers!.isha},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: prayers.map((p) {
          final isNext = _nextPrayerName == p['name'];
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isNext ? const Color(0xFF1A237E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: isNext ? [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p['name']!,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isNext ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p['time']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isNext ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildForecastList() {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    
    int startIndex = _calendarPrayers.indexWhere((p) => p.date == todayStr);
    if (startIndex == -1) startIndex = 0;

    // Get next 7 days starting from tomorrow
    final forecast = _calendarPrayers.skip(startIndex + 1).take(7).toList();

    if (forecast.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              const SizedBox(width: 80),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderLabel('İmsak'),
                    _buildHeaderLabel('Güneş'),
                    _buildHeaderLabel('Öğle'),
                    _buildHeaderLabel('İkindi'),
                    _buildHeaderLabel('Akşam'),
                    _buildHeaderLabel('Yatsı'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecast.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final day = forecast[index];
            final dateParts = day.date.split('-');
            final date = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
            final dayName = DateFormat('EEEE', 'tr_TR').format(date);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      dayName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildForecastTime(day.fajr),
                        _buildForecastTime(day.sunrise),
                        _buildForecastTime(day.dhuhr),
                        _buildForecastTime(day.asr),
                        _buildForecastTime(day.maghrib),
                        _buildForecastTime(day.isha),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderLabel(String label) {
    return SizedBox(
      width: 38,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildForecastTime(String time) {
    return SizedBox(
      width: 38,
      child: Text(
        time,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
