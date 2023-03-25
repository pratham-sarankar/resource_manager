import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:resource_manager/data/utils/extensions/validator_extension.dart';

class PlusDropDown<T> extends StatefulWidget {
  const PlusDropDown({
    Key? key,
    required this.items,
    this.title,
    this.isRequired = false,
    this.onChanged,
    this.initialValue,
    this.onValidate,
    this.onSaved,
  }) : super(key: key);
  final List<DropdownMenuItem<T?>> items;
  final T? initialValue;
  final void Function(dynamic)? onChanged;
  final String? Function(dynamic)? onValidate;
  final String? title;
  final bool isRequired;
  final void Function(dynamic)? onSaved;

  @override
  PlusDropDownState<T?> createState() => PlusDropDownState<T?>();
}

class PlusDropDownState<T> extends State<PlusDropDown> {
  late T? value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Column(
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
            ],
          ),
        DropdownButtonHideUnderline(
          child: IntrinsicWidth(
            child: DropdownButtonFormField2<T>(
              isExpanded: true,
              items: widget.items as List<DropdownMenuItem<T>>,
              value: value,
              onChanged: (selectedValue) {
                if (widget.onChanged == null) return;
                widget.onChanged!(selectedValue);
              },
              validator: ValidationBuilder(optional: !widget.isRequired)
                  .add(widget.onValidate ?? (value) => null)
                  .buildDyn(),
              onSaved: widget.onSaved,
            ),
          ),
        ),
      ],
    );
  }
}
