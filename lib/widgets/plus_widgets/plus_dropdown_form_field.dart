import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:resource_manager/resource_manager.dart';

class PlusDropdownFormField extends StatefulWidget {
  const PlusDropdownFormField({
    Key? key,
    required this.field,
    required this.controller,
    required this.initialValue,
  }) : super(key: key);
  final Field field;
  final DialogController controller;
  final dynamic initialValue;

  @override
  State<PlusDropdownFormField> createState() => _PlusDropdownFormFieldState();
}

class _PlusDropdownFormFieldState extends State<PlusDropdownFormField> {
  List<Resource<dynamic>>? resources;
  int? id;
  int? initialValue;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initialize() async {
    var response = await widget.field.repository!.fetch();
    setState(() {
      resources = response;
      initialValue = widget.initialValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: initialize(),
            builder: (context, snapshot) {
              return PlusDropDown(
                initialValue: initialValue,
                title: widget.field.label ?? widget.field.name,
                onSaved: (value) {
                  widget.controller.saveValue(widget.field.name, value);
                },
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      "Select ${widget.field.label ?? widget.field.name}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (resources != null)
                    for (var resource in resources!)
                      DropdownMenuItem<int?>(
                        value: resource.id,
                        child: Text(
                          resource.name ?? "-",
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                ],
                isRequired: widget.field.isRequired,
                onChanged: (value) {
                  setState(() {
                    id = value;
                  });
                },
              );
            }
          ),
          if (widget.field.subField != null)
            FutureBuilder(
              future: widget.field.subField?.repository
                  ?.fetch(queries: {ReCase(widget.field.name).camelCase: id}),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: [
                    for (Resource resource in snapshot.data!)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Card(
                            elevation: 8,
                            shadowColor: Colors.grey.shade400,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 5,
                                right: 12,
                                top: 2,
                                bottom: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: resource.id ==
                                        widget.controller.result[
                                            widget.field.subField!.name],
                                    onChanged: (value) {
                                      setState(() {
                                        widget.controller.saveValue(
                                          widget.field.subField!.name,
                                          resource.id,
                                        );
                                      });
                                    },
                                  ),
                                  Text(resource.name!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                );
              },
            )
        ],
      ),
    );
  }
}
