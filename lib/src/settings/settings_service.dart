import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  SettingsService(this.db);

  FirebaseFirestore db;

  /// Populates the document with default values if it doesn't exist.
  populateDoc() async {
    await db
        .collection("preferenze")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set({
      "partTimePercentage": 100,
      "companyName": "None",
      "companyAddress": "None"
    });
  }

  /// GET SETTINGS

  Future<dynamic> getDocField(String field, dynamic defaultValue) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return defaultValue;
    }
    var doc = await db
        .collection("preferenze")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    if (!doc.exists) {
      await populateDoc();
      return defaultValue;
    }
    return doc.data()![field];
  }

  Future<ThemeMode> themeMode() async => ThemeMode.dark;

  Future<String> tmzLocation() async => tz.local.name;

  Future<bool> isUserLogged() async =>
      FirebaseAuth.instance.currentUser != null;

  Future<int> partTimePercentage() async {
    return await getDocField("partTimePercentage", 100);
  }

  Future<String> companyName() async {
    return await getDocField("companyName", "None");
  }

  Future<String> companyAddress() async {
    return await getDocField("companyAddress", "None");
  }

  /// UPDATE SETTINGS

  Future<void> updateDocField(String field, dynamic value) async {
    await db
        .collection("preferenze")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({field: value});
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }

  Future<void> updateTmzLocation(String tmzLocation) async {}

  Future<void> updateUserLogged(bool isUserLogged) async {}

  Future<void> updatePartTimePercentage(int partTimePercentage) async {
    await updateDocField("partTimePercentage", partTimePercentage);
  }

  Future<void> updateCompanyName(String companyName) async {
    await updateDocField("companyName", companyName);
  }

  Future<void> updateCompanyAddress(String companyAddress) async {
    await updateDocField("companyAddress", companyAddress);
  }
}
