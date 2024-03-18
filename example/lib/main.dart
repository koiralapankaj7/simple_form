import 'package:flutter/material.dart';
import 'package:simple_form/simple_form.dart';
import 'package:simple_utils/simple_utils.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SimpleField.text(labelText: "Text Field"),
              SimpleField.number(labelText: "Number Field"),
              SimpleField.amount(labelText: "Amount/Double Field"),
              SimpleField.date(labelText: "Date Field"),
              SimpleField.password(labelText: "Password Field"),
              SimpleField.pinCode(labelText: "Pin Code Field"),
              SimpleField.cardNo(labelText: "Card No Field"),
              SimpleField.phone(labelText: "Phone Field"),
              SimpleField.address(labelText: "Address Field"),
              SimpleField.country(labelText: "Country Field"),
              SimpleField.dropdown<String>(
                labelText: "Dropdown Field",
                items: List.generate(5, (index) => 'Item -${index + 1}'),
              ),
              SimpleField.switchBox(label: "Amount/Double Field"),
            ].paddedY(space: 16),
          ),
        ),
      ),
    );
  }
}
