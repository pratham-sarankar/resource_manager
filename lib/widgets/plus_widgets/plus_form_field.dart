import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:resource_manager/data/abstracts/resource.dart';
import 'package:resource_manager/data/utils/extensions/validator_extension.dart';

class PlusFormField extends StatefulWidget {
  const PlusFormField({
    Key? key,
    this.title,
    this.isRequired = false,
    this.onValidate,
    required this.type,
    this.onSaved,
    this.hintText,
    this.initialText,
    this.onSubmitted,
    this.enabled = true,
    this.controller,
  }) : super(key: key);
  final String? title;
  final bool isRequired;
  final String? Function(String?)? onValidate;
  final void Function(String?)? onSaved;
  final void Function(String?)? onSubmitted;
  final FieldType type;
  final String? hintText;
  final bool enabled;
  final TextEditingController? controller;
  final dynamic initialText;

  @override
  State<PlusFormField> createState() => _PlusFormFieldState();
}

class _PlusFormFieldState extends State<PlusFormField> {
  late final TextEditingController _controller;
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.type == FieldType.password;
    _controller = widget.controller ??
        TextEditingController(text: "${widget.initialText ?? ""}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
                      style: context.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (widget.isRequired)
                    Text(
                      "*",
                      style: context.textTheme.titleMedium!.copyWith(
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
        TextFormField(
          controller: _controller,
          keyboardType: widget.type.textInputType,
          obscureText: _isObscure,
          style: TextStyle(
            fontSize: 14,
            color: context.theme.colorScheme.onBackground,
          ),
          enabled: widget.enabled,
          onFieldSubmitted: widget.onSubmitted,
          cursorHeight: 18,
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            suffixIcon: widget.type == FieldType.password
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(_isObscure
                        ? CupertinoIcons.eye_solid
                        : CupertinoIcons.eye_slash_fill),
                  )
                : null,
            contentPadding: EdgeInsets.only(
              right: 10,
              left: 10,
              top: widget.type == FieldType.password ? 15 : 10,
              bottom: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: widget.hintText,
          ),
          onTap: () {
            if (widget.type == FieldType.date) {
              _pickDate();
            } else if (widget.type == FieldType.time) {
              _pickTime();
            }
          },
          onSaved: widget.onSaved,
          validator: ValidationBuilder(optional: !widget.isRequired)
              .add(widget.onValidate ?? (value) => null)
              .buildDyn(),
        ),
      ],
    );
  }

  void _pickDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 100),
      ),
    );
    if (date != null) {
      var formatter = DateFormat('d MMM y');
      String value = formatter.format(date);
      _controller.text = value;
    }
  }

  void _pickTime() async {
    var time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      _controller.text =
          "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";
    }
  }
}
