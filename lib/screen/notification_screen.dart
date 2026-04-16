import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends State<NotificationSettingScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF4169E1),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notification Setting',
          style: TextStyle(
            color: Color(0xFF4169E1),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: ListView(
          children: [
            _buildToggleItem(
              label: 'General Notification',
              value: settings.generalNotification,
              onChanged: (val) => settings.setGeneralNotification(val),
            ),
            _buildToggleItem(
              label: 'Sound',
              value: settings.sound,
              onChanged: (val) => settings.setSound(val),
            ),
            _buildToggleItem(
              label: 'Sound Call',
              value: settings.soundCall,
              onChanged: (val) => settings.setSoundCall(val),
            ),
            _buildToggleItem(
              label: 'Vibrate',
              value: settings.vibrate,
              onChanged: (val) => settings.setVibrate(val),
            ),
            _buildToggleItem(
              label: 'Special Offers',
              value: settings.specialOffers,
              onChanged: (val) => settings.setSpecialOffers(val),
            ),
            _buildToggleItem(
              label: 'Payments',
              value: settings.payments,
              onChanged: (val) => settings.setPayments(val),
            ),
            _buildToggleItem(
              label: 'Promo And Discount',
              value: settings.promoAndDiscount,
              onChanged: (val) => settings.setPromoAndDiscount(val),
            ),
            _buildToggleItem(
              label: 'Cashback',
              value: settings.cashback,
              onChanged: (val) => settings.setCashback(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w400,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF4169E1),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFDDE3F0),
              trackOutlineColor:
              WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}