import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:debtortrack/models/message_template.dart';

class TemplateService {
  static const String _defaultTemplateKey = 'defaultMessageTemplateId';
  static const String defaultTemplateId = 'default-friendly-reminder';
  static const String _templatesKey = 'messageTemplates';

  Future<List<MessageTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getStringList(_templatesKey) ?? [];
    if (templatesJson.isEmpty) {
      final defaultTemplate = MessageTemplate(
        id: defaultTemplateId,
        name: 'Friendly Reminder',
        body: 'Hello {name}, this is a friendly reminder that your payment of {amount} is due on {dueDate}. Please make the payment at your earliest convenience. Thank you!',
        createdAt: DateTime.now(),
      );
      await saveTemplates([defaultTemplate]);
      return [defaultTemplate];
    }
    return templatesJson
        .map(
          (json) =>
              MessageTemplate.fromMap(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveTemplates(List<MessageTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = templates
        .map((template) => jsonEncode(template.toMap()))
        .toList();
    await prefs.setStringList(_templatesKey, templatesJson);
  }

  Future<String> loadDefaultTemplateId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_defaultTemplateKey) ?? defaultTemplateId;
  }

  Future<void> saveDefaultTemplateId(String templateId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_defaultTemplateKey, templateId);
  }
}
