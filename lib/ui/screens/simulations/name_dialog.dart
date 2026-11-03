import 'package:flutter/material.dart';

const maxNameLength = 30;

String? validateSimulationName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'Donnez un nom à cette simulation.';
  }
  if (name.trim().length > maxNameLength) {
    return 'Le nom fait au plus $maxNameLength caractères.';
  }
  return null;
}

Future<String?> showNameDialog(BuildContext context, String suggestedName) {
  final controller = TextEditingController(text: suggestedName);
  final formKey = GlobalKey<FormState>();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enregistrer la simulation'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
          validator: validateSimulationName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(controller.text.trim());
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
}
