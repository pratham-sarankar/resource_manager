import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';
import 'package:resource_manager/resource_manager.dart';
import 'package:resource_manager/widgets/plus_widgets/plus_dropdown_form_field.dart';
import 'package:resource_manager/widgets/plus_widgets/plus_duration_form_field.dart';
import 'package:resource_manager/widgets/plus_widgets/plus_foreign_form_field.dart';
import 'package:resource_manager/widgets/plus_widgets/plus_image_form_field.dart';
import 'package:resource_manager/widgets/plus_widgets/plus_recurring_form_field.dart';

class ResourceDialog extends StatelessWidget {
  const ResourceDialog({Key? key, required this.resource}) : super(key: key);
  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: resource.hashCode,
      init: DialogController(resource),
      builder: (controller) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: Get.width * 0.5,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(maxHeight: Get.height * 0.9),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTitle(),
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colorScheme.onBackground,
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 22),
                      Form(
                          key: controller.formKey,
                          child: getFields(controller)),
                    ],
                  ),
                ),
                footer(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  String getTitle() {
    var prefix = resource.isEmpty ? "Add" : "Update";
    return "$prefix ${ReCase(resource.runtimeType.toString()).titleCase}";
  }

  Widget getFields(DialogController controller) {
    List<Field> fields = resource.getFields();
    fields.sort((a, b) => a.compareTo(b));
    var groups = fields.groupBy((field) => field.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var group in groups.entries)
          getField(group.key, group.value, controller),
      ],
    );
  }

  Widget getField(
      FieldType type, List<Field> fields, DialogController controller) {
    switch (type) {
      case FieldType.image:
        return Column(
          children: [
            for (var field in fields) renderImageField(field, controller)
          ],
        );
      case FieldType.name:
        return renderTextFields(fields, controller);
      case FieldType.email:
        return renderTextFields(fields, controller);
      case FieldType.phoneNumber:
        return renderTextFields(fields, controller);
      case FieldType.password:
        return renderTextFields(fields, controller);
      case FieldType.text:
        return renderTextFields(fields, controller);
      case FieldType.dropdown:
        return Column(
          children: [
            for (var field in fields) renderDropdownField(field, controller)
          ],
        );
      case FieldType.date:
        return renderTextFields(fields, controller);
      case FieldType.time:
        return renderTextFields(fields, controller);
      case FieldType.number:
        return renderTextFields(fields, controller);
      case FieldType.foreign:
        return Column(
          children: [
            for (var field in fields) renderForeignFormField(field, controller),
          ],
        );
      case FieldType.recurring:
        return Column(
          children: [
            for (var field in fields)
              renderRecurringFormField(field, controller),
          ],
        );
      case FieldType.duration:
        return Column(
          children: [
            for (var field in fields)
              renderDurationFormField(field, controller),
          ],
        );
      case FieldType.custom:
        return Column(
          children: [
            for (var field in fields) field.builder!(controller),
          ],
        );

    }
  }

  Widget renderTextFields(List<Field> fields, DialogController controller) {
    int piece = 2;
    var slices = fields.slices(piece);
    return Column(
      children: [
        for (int i = 0; i < slices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                for (int j = 0; j < slices.elementAt(i).length; j++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right:
                              (j + 1) == slices.elementAt(i).length ? 0 : 20),
                      child: PlusFormField(
                        title: slices.elementAt(i).elementAt(j).label ??
                            slices.elementAt(i).elementAt(j).name,
                        type: slices.elementAt(i).elementAt(j).type,
                        isRequired: slices.elementAt(i).elementAt(j).isRequired,
                        onSaved: (value) {
                          if (value?.isEmpty ?? true) return;
                          controller.saveValue(
                              slices.elementAt(i).elementAt(j).name, value);
                        },
                        hintText: slices.elementAt(i).elementAt(j).hint,
                        initialText: controller
                            .result[slices.elementAt(i).elementAt(j).name],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget renderImageField(Field field, DialogController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: PlusImageFormField(
        title: field.label ?? "Picture",
        uploader: resource.fileUploader,
        downloader: resource.fileDownloader,
        onSaved: (key) {
          controller.saveValue(field.name, key);
        },
        initialValue: controller.result[field.name],
      ),
    );
  }

  Widget renderSimpleDropdownField(Field field, DialogController controller) {
    return PlusDropdownFormField(
      field: field,
      controller: controller,
      initialValue: controller.result[field.name],
    );
  }

  Widget renderDropdownField(Field field, DialogController controller) {
    int? id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder<List<Resource>>(
            future: field.repository!.fetch(queries: field.queries ?? {}),
            builder: (context, snapshot) {
              print(snapshot.data);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlusDropDown(
                    key: ValueKey(snapshot.hasData),
                    title: field.label ?? field.name,
                    onSaved: (value) {
                      controller.saveValue(field.name, value);
                    },
                    onChanged: (value) {
                      setState(() {
                        id = value;
                      });
                    },
                    isRequired: field.isRequired,
                    initialValue:
                        snapshot.hasData ? controller.result[field.name] : null,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          "Select ${field.label ?? field.name}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (snapshot.hasData)
                        ...snapshot.data!
                            .map(
                              (resource) => DropdownMenuItem<int?>(
                                value: resource.id,
                                child: Text(
                                  resource.name ?? "-",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    ],
                  ),
                  if (field.subField != null)
                    FutureBuilder(
                      future: field.subField?.repository
                          ?.fetch(queries: {ReCase(field.name).camelCase: id}),
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
                                    elevation: 10,
                                    shadowColor: Colors.grey.shade600,
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
                                                controller.result[
                                                    field.subField!.name],
                                            onChanged: (value) {
                                              setState(() {
                                                controller.saveValue(
                                                  field.subField!.name,
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
              );
            },
          );
        },
      ),
    );
  }

  Widget renderForeignFormField(Field field, DialogController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: PlusForeignFormField(
        title: "Search ${field.label ?? field.name}",
        foreignRepository: field.repository,
        onSaved: (value) {
          controller.saveValue(field.name, value);
        },
        initialValue: controller.result[field.name],
        isRequired: field.isRequired,
      ),
    );
  }

  Widget renderRecurringFormField(Field field, DialogController controller) {
    return PlusRecurringFormField(
      title: field.label ?? field.name,
      initialValue: controller.result[field.name] ?? "RRULE:FREQ=DAILY;",
      onSaved: (value) {
        controller.saveValue(field.name, value);
      },
    );
  }

  Widget renderDurationFormField(Field field, DialogController controller) {
    return PlusDurationFormField(
      title: field.label ?? field.name,
      initialValue: controller.result[field.name] ?? 30 * 24 * 60 * 60,
      onSaved: (value) {
        controller.saveValue(field.name, value);
      },
    );
  }

  Widget footer(DialogController controller) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              style: ButtonStyle(
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 18, horizontal: 35),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                fixedSize: const MaterialStatePropertyAll(Size(140, 40)),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.validate()) {
                  controller.save();
                  var result = resource.fromMap(controller.result);
                  return Get.back(result: result);
                }
              },
              style: ButtonStyle(
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 18, horizontal: 45),
                ),
                fixedSize: const MaterialStatePropertyAll(Size(140, 40)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DialogController extends GetxController {
  final Resource resource;

  late GlobalKey<FormState> formKey;

  Map<String, dynamic> result = {};

  DialogController(this.resource);

  @override
  void onInit() {
    super.onInit();
    result = resource.toMap();
    formKey = GlobalKey<FormState>();
  }

  bool validate() => formKey.currentState!.validate();

  void save() => formKey.currentState!.save();

  void saveValue(String key, dynamic value) {
    result[key] = value;
  }
}
