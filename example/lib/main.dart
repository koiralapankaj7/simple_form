import 'package:flutter/material.dart';
import 'package:simple_form/simple_form.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TextSpan _buildJson(
    BuildContext context,
    Map<String, dynamic> json, {
    double space = 16,
  }) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    final children = <TextSpan>[];
    children.add(const TextSpan(text: '{\n'));

    for (final item in json.entries) {
      final value = item.value == null ? null : '"${item.value}"';
      final span = TextSpan(
        children: [
          WidgetSpan(child: SizedBox(width: space)),
          TextSpan(
            text: '"${item.key}"',
            style: style!.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ': '),
          TextSpan(
            text: '$value,\n',
            style: style.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
      children.add(span);
    }
    children.add(const TextSpan(text: '}\n'));
    return TextSpan(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SimpleForm(
          onChanged: () {
            setState(() {});
          },
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              // horizontal: max(16, (width - 400) * 0.5),
                              vertical: 16,
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                SimpleField.text(
                                  jsonKey: 'textField',
                                  isRequired: true,
                                ),
                                SimpleField.number(
                                  jsonKey: 'numberField',
                                  isRequired: true,
                                ),
                                SimpleField.amount(
                                  jsonKey: 'doubleField',
                                  isRequired: true,
                                ),
                                SimpleField.date(
                                  jsonKey: 'dateField',
                                  isRequired: true,
                                ),
                                SimpleField.password(
                                  jsonKey: 'passwordField',
                                  isRequired: true,
                                ),
                                SimpleField.pinCode(
                                  jsonKey: 'pinCodeField',
                                  isRequired: true,
                                ),
                                SimpleField.cardNo(
                                  jsonKey: 'cardNoField',
                                  isRequired: true,
                                ),
                                SimpleField.phone(
                                  jsonKey: 'phoneField',
                                  isRequired: true,
                                ),
                                SimpleField.address(
                                  jsonKey: 'addressField',
                                  isRequired: true,
                                ),
                                SimpleField.country(
                                  jsonKey: 'countryField',
                                  // isRequired: true,
                                ),
                                // SimpleField.dropdown<String>(
                                //   labelText: "Dropdown Field",
                                //   items: List.generate(5, (index) => 'Item -${index + 1}'),
                                // ),
                                SimpleField.switchBox(
                                  jsonKey: 'switchBoxField',
                                  label: "Switch Box Field",
                                  isRequired: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 16,
                            children: [
                              OutlinedButton(
                                onPressed: SimpleForm.of(context).reset,
                                child: const Text('Clear'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  if (SimpleForm.of(context).validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Validation Success'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Validate'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Container(
                    width: 400,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText.rich(
                      _buildJson(context, SimpleForm.of(context).json),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
