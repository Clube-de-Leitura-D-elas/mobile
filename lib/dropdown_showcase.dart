import 'package:flutter/material.dart';

import 'design_system/widgets/app_dropdown.dart';

class DropdownShowcaseScreen extends StatefulWidget {
  const DropdownShowcaseScreen({super.key});

  @override
  State<DropdownShowcaseScreen> createState() => _DropdownShowcaseScreenState();
}

class _DropdownShowcaseScreenState extends State<DropdownShowcaseScreen> {
  final List<String> _opcoes = ['Opção A', 'Opção B', 'Opção C', 'Opção D'];

  String? _valorTamanhoMd = 'Opção A';
  String? _valorTamanhoLg;
  bool _habilitadoDinamico = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown - Emulador Android')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teste Interativo de Variantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 1. Dropdown Médio
            AppDropdown<String>(
              label: 'Dropdown Médio (Preenchido)',
              hintText: 'Selecione',
              value: _valorTamanhoMd,
              items: _opcoes,
              size: AppDropdownSize.md,
              onChanged: (val) => setState(() => _valorTamanhoMd = val),
            ),

            const SizedBox(height: 24),

            // 2. Dropdown Grande com Hint
            AppDropdown<String>(
              label: 'Dropdown Grande (Placeholder)',
              hintText: 'Escolha uma opção na lista',
              value: _valorTamanhoLg,
              items: _opcoes,
              size: AppDropdownSize.lg,
              onChanged: (val) => setState(() => _valorTamanhoLg = val),
            ),

            const SizedBox(height: 24),

            // 3. Dropdown Dinâmico (Habilitar / Desabilitar)
            AppDropdown<String>(
              label: 'Dropdown com Toggle de Estado',
              hintText: 'Use o switch abaixo',
              enabled: _habilitadoDinamico,
              value: _valorTamanhoLg,
              items: _opcoes,
              size: AppDropdownSize.md,
              onChanged: (val) => setState(() => _valorTamanhoLg = val),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Switch(
                  value: _habilitadoDinamico,
                  onChanged: (val) => setState(() => _habilitadoDinamico = val),
                ),
                Text(_habilitadoDinamico ? 'Ativo' : 'Desativado'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
