import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/settings/settings_controller.dart';

class FormLine extends StatefulWidget {
  const FormLine({
    super.key,
    required this.label,
    required this.updateFun,
    required this.value,
  });
  final String value;
  final updateFun;
  final String label;

  @override
  State<FormLine> createState() => _FormLineState();
}

class _FormLineState extends State<FormLine> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myController.text = widget.value;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: TextFormField(
              controller: myController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: InputDecoration(
                labelStyle: TextStyle(color: colorScheme.onSurface),
                border: InputBorder.none,
                labelText: widget.label,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
                widget.updateFun(myController.text).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Saved')),
                  );
                });
              }
            },
          )
        ],
      ),
    );
  }
}
