import 'package:flutter/material.dart';

import '../widgets/app_dropdown.dart';

class AppDropdownExample extends StatefulWidget {
  const AppDropdownExample({super.key});

  @override
  State<AppDropdownExample> createState() => _AppDropdownExampleState();
}

class _AppDropdownExampleState extends State<AppDropdownExample> {
  String? selectedValue = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dropdown padrão'),

            const SizedBox(height: 8),

            AppDropdown<String>(
              label: 'Status',
              items: const [
                'Todos',
                'Ativos',
                'Inativos',
              ],
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),

            const SizedBox(height: 32),

            const Text('Dropdown desabilitado'),

            const SizedBox(height: 8),

            AppDropdown<String>(
              label: 'Desabilitado',
              items: const [
                'Opção 1',
                'Opção 2',
              ],
              value: 'Opção 1',
              enabled: false,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}