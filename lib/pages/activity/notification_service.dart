// notification_service.dart
final List<String> notifications = [];

void addNotification(String message) {
  notifications.insert(0, message); // Insert at the top to show latest notifications first
}
