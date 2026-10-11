import 'package:flutter/material.dart';

import '../services/notification_service.dart';

// Gửi thông báo nhắc học / nhắc uống nước sau 2 phút / hẹn giờ học sau 10 phút
class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    void showSnack(String msg) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    return Scaffold(
      appBar: AppBar(title: const Text("Screen Noti Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                notificationService.showSimpleNotification();
              },
              child: const Text("Gửi thông báo nhắc học Ngoại ngữ"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await notificationService.scheduleNotificationAfter(
                  const Duration(minutes: 2),
                  'drink_water_channel',
                  'Uống nước',
                  'Nhắc uống nước đúng giờ',
                  id: 1,
                );
                showSnack('Đã hẹn nhắc uống nước sau 2 phút');
              },
              child: const Text("Gửi thông báo nhắc uống nước sau 2 phút"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await notificationService.scheduleNotificationAfter(
                  const Duration(minutes: 10),
                  'learn_english_channel',
                  'Học Ngoại ngữ',
                  'Đến giờ học Ngoại ngữ rồi!',
                  id: 2,
                );
                showSnack('Đã hẹn giờ nhắc học Ngoại ngữ sau 10 phút');
              },
              child: const Text(
                "Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
