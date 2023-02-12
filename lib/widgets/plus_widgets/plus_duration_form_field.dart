import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resource_manager/data/utils/extensions/validator_extension.dart';
import 'package:resource_manager/resource_manager.dart';

class PlusDurationFormField extends FormField<int?> {
  final String title;
  final String? Function(String?)? onValidate;
  final bool isRequired;

  PlusDurationFormField({
    super.key,
    required this.title,
    this.isRequired = false,
    this.onValidate,
    super.onSaved,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
  }) : super(
          builder: (state) {
            return _DurationFormField(
              state: state,
              title: title,
              isRequired: isRequired,
            );
          },
          validator: ValidationBuilder(optional: !isRequired)
              .add(onValidate ?? (value) => null)
              .buildDyn(),
        );
}

class _DurationFormField extends StatefulWidget {
  const _DurationFormField({
    Key? key,
    required this.title,
    required this.state,
    this.isRequired = false,
  }) : super(key: key);
  final String? title;
  final FormFieldState<int?> state;
  final bool isRequired;

  @override
  State<_DurationFormField> createState() => _DurationFormFieldState();
}

class _DurationFormFieldState extends State<_DurationFormField> {
  late DurationUnit unit;
  late TextEditingController controller;

  @override
  void initState() {
    unit = DurationUnit.month;
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Opacity(
              opacity: 0.8,
              child: Text(
                widget.title ?? "",
                style: Get.context!.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Get.context!.theme.colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (widget.isRequired)
              Text(
                "*",
                style: Get.context!.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                  height: 1,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IntrinsicWidth(
              stepWidth: 100,
              child: PlusFormField(
                controller: controller,
                type: FieldType.number,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 20),
            PlusDropDown<DurationUnit>(
              initialValue: unit,
              isRequired: false,
              onChanged: (dynamic newValue) {
                changeState(newValue);
              },
              items: [
                DurationUnit.day,
                DurationUnit.month,
                DurationUnit.year,
              ].map<DropdownMenuItem<DurationUnit>>((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(
                    unit.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.state.errorText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: context.theme.errorColor,
              ),
            ),
          ),
      ],
    );
  }

  void changeState(DurationUnit unit) {
    setState(() {
      this.unit = unit;
    });
    var seconds = unit.getSeconds(controller.text);
    widget.state.didChange(seconds);
  }
}

enum DurationUnit { day, month, year }

extension DurationUnitExtension on DurationUnit {
  String get title {
    switch (this) {
      case DurationUnit.day:
        return "Day";
      case DurationUnit.month:
        return "Month";
      case DurationUnit.year:
        return "Year";
    }
  }

  int getSeconds(String text) {
    double value = double.parse(text);
    double result;
    switch (this) {
      case DurationUnit.day:
        result = value * 24 * 60 * 60;
        break;
      case DurationUnit.month:
        result = value * 30 * 24 * 60 * 60;
        break;
      case DurationUnit.year:
        result = value * 365 * 24 * 60 * 60;
        break;
    }
    return result.toInt();
  }
}
