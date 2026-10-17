import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? lockedLocation;
  final bool isLocationLocked;
  final bool alertsEnabled;
  final double highTempLimit;
  final double lowTempLimit;

  UserModel({
    required this.uid,
    this.lockedLocation,
    this.isLocationLocked = false,
    this.alertsEnabled = false,
    this.highTempLimit = 35.0,
    this.lowTempLimit = 15.0,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    if (!doc.exists) {
      return UserModel(uid: doc.id);
    }
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      lockedLocation: data['lockedLocation'],
      isLocationLocked: data['isLocationLocked'] ?? false,
      alertsEnabled: data['alertsEnabled'] ?? false,
      highTempLimit: (data['highTempLimit'] ?? 35.0).toDouble(),
      lowTempLimit: (data['lowTempLimit'] ?? 15.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lockedLocation': lockedLocation,
      'isLocationLocked': isLocationLocked,
      'alertsEnabled': alertsEnabled,
      'highTempLimit': highTempLimit,
      'lowTempLimit': lowTempLimit,
    };
  }
}
