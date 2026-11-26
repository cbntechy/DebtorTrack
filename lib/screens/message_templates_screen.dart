import 'package:debtortrack/core/services/template_service.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:debtortrack/models/message_template.dart';
import 'package:flutter/material.dart';
import 'package:debtortrack/core/services/entitlement_service.dart';
import 'package:debtortrack/screens/template_editor_screen.dart';
import 'package:debtortrack/screens/upgrade_screen.dart';

class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() => _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState extends State<MessageTemplatesScreen> {
  final TemplateService _templateService = TemplateService();

  List<MessageTemplate> _templates = [];
  String? _defaultTemplateId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _createTemplate() async {
    final isPro = EntitlementService.instance.isPro;

    if (!isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpgradeScreen()),
      );
      return;
    }

    final template = await Navigator.push<MessageTemplate>(
      context,
      MaterialPageRoute(builder: (context) => const TemplateEditorScreen()),
    );

    if (template == null || !mounted) return;

    final updatedTemplates = [..._templates, template];

    await _templateService.saveTemplates(updatedTemplates);

    if (!mounted) return;

    setState(() {
      _templates = updatedTemplates;
    });
  }

  Future<void> _editTemplate(MessageTemplate template) async {
    if (!EntitlementService.instance.isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpgradeScreen()),
      );
      return;
    }

    final updatedTemplate = await Navigator.push<MessageTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(existingTemplate: template),
      ),
    );

    if (updatedTemplate == null || !mounted) return;

    final updatedTemplates = _templates
        .map((item) => item.id == updatedTemplate.id ? updatedTemplate : item)
        .toList();

    await _templateService.saveTemplates(updatedTemplates);

    if (!mounted) return;

    setState(() {
      _templates = updatedTemplates;
    });
  }

  Future<void> _deleteTemplate(MessageTemplate template) async {
    if (!EntitlementService.instance.isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpgradeScreen()),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete template?'),
          content: Text('“${template.name}” will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final updatedTemplates = _templates
        .where((item) => item.id != template.id)
        .toList();

    await _templateService.saveTemplates(updatedTemplates);

    if (_defaultTemplateId == template.id) {
      await _templateService.saveDefaultTemplateId(
        TemplateService.defaultTemplateId,
      );
    }

    if (!mounted) return;

    setState(() {
      _templates = updatedTemplates;

      if (_defaultTemplateId == template.id) {
        _defaultTemplateId = TemplateService.defaultTemplateId;
      }
    });
  }

  Future<void> _loadTemplates() async {
    final templates = await _templateService.loadTemplates();
    final savedDefaultId = await _templateService.loadDefaultTemplateId();

    if (!mounted) return;

    setState(() {
      _templates = templates;
      _defaultTemplateId =
          templates.any((template) => template.id == savedDefaultId)
          ? savedDefaultId
          : templates.first.id;
      _isLoading = false;
    });
  }

  Future<void> _chooseDefaultTemplate(String templateId) async {
    await _templateService.saveDefaultTemplateId(templateId);

    if (!mounted) return;

    setState(() {
      _defaultTemplateId = templateId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default reminder template updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        title: const Text('Message templates'),
        actions: [
          IconButton(
            onPressed: _createTemplate,
            icon: const Icon(Icons.add),
            tooltip: 'New template',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Default reminder',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This template is selected automatically when you send a reminder.',
                ),
                const SizedBox(height: 16),

                RadioGroup<String>(
                  groupValue: _defaultTemplateId,
                  onChanged: (templateId) {
                    if (templateId == null) return;
                    _chooseDefaultTemplate(templateId);
                  },
                  child: Column(
                    children: _templates.map((template) {
                      return Card(
                        child: RadioListTile<String>(
                          value: template.id,
                          title: Text(template.name),
                          subtitle: Text(
                            template.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondary:
                              template.id == TemplateService.defaultTemplateId
                              ? const Icon(Icons.lock_outline)
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Edit template',
                                      onPressed: () => _editTemplate(template),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete template',
                                      onPressed: () =>
                                          _deleteTemplate(template),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
