import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _generalNotification = true;
  bool _sound = true;
  bool _soundCall = true;
  bool _vibrate = false;
  bool _specialOffers = false;
  bool _payments = true;
  bool _promoAndDiscount = false;
  bool _cashback = true;
  bool _isDarkMode = false;
  String _preferredLanguage = 'English';

  // Available languages
  final Map<String, String> availableLanguages = {
    'English': 'en',
    'Urdu': 'ur',
    'Hindi': 'hi',
    'Arabic': 'ar',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Russian': 'ru',
    'Turkish': 'tr',
    'Bengali': 'bn',
    'Indonesian': 'id',
    'Portuguese': 'pt',
  };

  SettingsProvider() {
    _loadSettings();
  }

  bool get generalNotification => _generalNotification;
  bool get sound => _sound;
  bool get soundCall => _soundCall;
  bool get vibrate => _vibrate;
  bool get specialOffers => _specialOffers;
  bool get payments => _payments;
  bool get promoAndDiscount => _promoAndDiscount;
  bool get cashback => _cashback;
  bool get isDarkMode => _isDarkMode;
  String get preferredLanguage => _preferredLanguage;
  String get preferredLanguageCode => availableLanguages[_preferredLanguage] ?? 'en';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _generalNotification = prefs.getBool('generalNotification') ?? true;
    _sound = prefs.getBool('sound') ?? true;
    _soundCall = prefs.getBool('soundCall') ?? true;
    _vibrate = prefs.getBool('vibrate') ?? false;
    _specialOffers = prefs.getBool('specialOffers') ?? false;
    _payments = prefs.getBool('payments') ?? true;
    _promoAndDiscount = prefs.getBool('promoAndDiscount') ?? false;
    _cashback = prefs.getBool('cashback') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _preferredLanguage = prefs.getString('preferredLanguage') ?? 'English';
    notifyListeners();
  }

  Future<void> setPreferredLanguage(String language) async {
    _preferredLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredLanguage', language);
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> setGeneralNotification(bool value) async {
    _generalNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('generalNotification', value);
  }

  Future<void> setSound(bool value) async {
    _sound = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
  }

  Future<void> setSoundCall(bool value) async {
    _soundCall = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundCall', value);
  }

  Future<void> setVibrate(bool value) async {
    _vibrate = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrate', value);
  }

  Future<void> setSpecialOffers(bool value) async {
    _specialOffers = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('specialOffers', value);
  }

  Future<void> setPayments(bool value) async {
    _payments = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payments', value);
  }

  Future<void> setPromoAndDiscount(bool value) async {
    _promoAndDiscount = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoAndDiscount', value);
  }

  Future<void> setCashback(bool value) async {
    _cashback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cashback', value);
  }
}
