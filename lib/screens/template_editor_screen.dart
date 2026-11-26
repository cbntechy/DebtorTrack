import 'package:debtortrack/models/message_template.dart';
import 'package:flutter/material.dart';

class TemplateEditorScreen extends StatefulWidget {
  final MessageTemplate? existingTemplate;

  const TemplateEditorScreen({
    super.key,
    this.existingTemplate,
  });

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.existingTemplate?.name ?? '',
    );

    _bodyController = TextEditingController(
      text: widget.existingTemplate?.body ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) return;

    final template = MessageTemplate(
      id: widget.existingTemplate?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      body: _bodyController.text.trim(),
      createdAt: widget.existingTemplate?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, template);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTemplate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit template' : 'New template'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template name',
                hintText: 'For example: Polite reminder',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a template name';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _bodyController,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText:
                    'Hi {name}, your balance of {amount} is due on {dueDate}.',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a reminder message';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Available placeholders: {name}, {amount}, {dueDate}',
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saveTemplate,
              child: Text(isEditing ? 'Save changes' : 'Create template'),
            ),
          ],
        ),
      ),
    );
  }
}