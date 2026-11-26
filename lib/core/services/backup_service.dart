import 'dart:convert';
import 'package:debtortrack/core/services/template_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupService {
  static const String _debtorsKey = 'debtors';
  static const String _templatesKey = 'messageTemplates';
  static const String _defaultTemplateKey = 'defaultMessageTemplateId';
  static const String _currencyKey = 'targetCurrency';

  Future<void> backupNow() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw StateError('You must sign in before backing up.');
    }

    final prefs = await SharedPreferences.getInstance();

    final debtorsJson = prefs.getString(_debtorsKey) ?? '[]';
    final templatesJson = prefs.getStringList(_templatesKey) ?? [];

    final backupData = {
      'schemaVersion': 1,
      'debtors': jsonDecode(debtorsJson),
      'templates': templatesJson
          .map((templateJson) => jsonDecode(templateJson))
          .toList(),
      'defaultTemplateId':
          prefs.getString(_defaultTemplateKey) ??
          TemplateService.defaultTemplateId,
      'targetCurrency': prefs.getString(_currencyKey),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };

    await Supabase.instance.client.from('user_backups').upsert(
      {
        'user_id': user.id,
        'data': backupData,
        'updated_at': backupData['updatedAt'],
      },
      onConflict: 'user_id',
    );
  }

  Future<Map<String, dynamic>?> getBackup() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw StateError('You must sign in before restoring a backup.');
  }

  final row = await Supabase.instance.client
      .from('user_backups')
      .select('data')
      .eq('user_id', user.id)
      .maybeSingle();

  if (row == null) {
    return null;
  }

  final backupData = row['data'];

  if (backupData is! Map) {
    throw StateError('The saved backup has an invalid format.');
  }

  return Map<String, dynamic>.from(backupData);
}

Future<void> restoreBackup(Map<String, dynamic> backupData) async {
  if (backupData['schemaVersion'] != 1) {
    throw StateError('This backup version is not supported.');
  }

  final debtors = backupData['debtors'];
  final templates = backupData['templates'];

  if (debtors is! List || templates is! List) {
    throw StateError('The saved backup is incomplete.');
  }

  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(_debtorsKey, jsonEncode(debtors));

  await prefs.setStringList(
    _templatesKey,
    templates.map((template) => jsonEncode(template)).toList(),
  );

  final defaultTemplateId = backupData['defaultTemplateId'];

  await prefs.setString(
    _defaultTemplateKey,
    defaultTemplateId is String && defaultTemplateId.isNotEmpty
        ? defaultTemplateId
        : TemplateService.defaultTemplateId,
  );

  final currencyCode = backupData['targetCurrency'];

  if (currencyCode is String && currencyCode.isNotEmpty) {
    await prefs.setString(_currencyKey, currencyCode);
  } else {
    await prefs.remove(_currencyKey);
  }
}
}