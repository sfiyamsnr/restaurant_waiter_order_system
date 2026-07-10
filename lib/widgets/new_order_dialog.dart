import 'package:flutter/material.dart';

/// Shows a dialog asking for a table number. Returns the table number,
/// or null if the user cancelled.
Future<int?> showNewOrderDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const NewOrderDialog(),
  );
}

class NewOrderDialog extends StatefulWidget {
  const NewOrderDialog({super.key});

  @override
  State<NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tableController = TextEditingController();

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_tableController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Order'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _tableController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Table Number',
            prefixIcon: Icon(Icons.table_restaurant_rounded),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final parsed = int.tryParse((value ?? '').trim());
            if (parsed == null || parsed <= 0) {
              return 'Enter a valid table number';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
