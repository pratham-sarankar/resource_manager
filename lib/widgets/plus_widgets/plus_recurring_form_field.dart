import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resource_manager/data/utils/extensions/validator_extension.dart';
import 'package:resource_manager/resource_manager.dart';
import 'package:rrule/rrule.dart';

class PlusRecurringFormField extends FormField<String?> {
  final String title;
  final String? Function(String?)? onValidate;
  final bool isRequired;

  PlusRecurringFormField({
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
            return _RecurringFormField(
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

class _RecurringFormField extends StatefulWidget {
  const _RecurringFormField({
    Key? key,
    required this.title,
    required this.state,
    this.isRequired = false,
  }) : super(key: key);
  final String? title;
  final FormFieldState<String?> state;
  final bool isRequired;

  @override
  State<_RecurringFormField> createState() => _RecurringFormFieldState();
}

class _RecurringFormFieldState extends State<_RecurringFormField> {
  late Frequency frequency;
  late Set<ByWeekDayEntry> byWeekDays;
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    var rrule = widget.state.value != null
        ? RecurrenceRule.fromString(widget.state.value!)
        : RecurrenceRule(frequency: Frequency.daily, byWeekDays: const {});
    frequency = rrule.frequency;
    byWeekDays = rrule.byWeekDays;
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
        PlusDropDown<Frequency>(
          initialValue: frequency,
          isRequired: false,
          onChanged: (dynamic newValue) {
            changeState(newValue, byWeekDays);
          },
          items: <Frequency>[
            Frequency.daily,
            Frequency.weekly,
            Frequency.monthly,
            Frequency.yearly,
          ].map<DropdownMenuItem<Frequency>>((freq) {
            return DropdownMenuItem(
              value: freq,
              child: Text(
                freq.title,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (frequency == Frequency.weekly)
          Column(
            children: [
              Row(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      "On",
                      style: Get.context!.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Get.context!.theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      weekdays[index],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    value: byWeekDays.contains(ByWeekDayEntry(index + 1)),
                    onChanged: (value) {
                      if (value ?? false) {
                        byWeekDays.add(ByWeekDayEntry(index + 1));
                      } else {
                        byWeekDays.remove(ByWeekDayEntry(index + 1));
                      }
                      changeState(frequency, byWeekDays);
                    },
                  );
                },
              ),
            ],
          ),
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

  void changeState(Frequency frequency, Set<ByWeekDayEntry> byWeekDays) {
    setState(() {
      this.frequency = frequency;
      this.byWeekDays = byWeekDays;
    });
    var rrule = RecurrenceRule(frequency: frequency, byWeekDays: byWeekDays);
    widget.state.didChange(rrule.toString());
  }
}

extension FrequencyExtension on Frequency {
  String get title {
    if (this == Frequency.daily) {
      return "Daily";
    } else if (this == Frequency.weekly) {
      return "Weekly";
    } else if (this == Frequency.monthly) {
      return "Monthly";
    } else if (this == Frequency.yearly) {
      return "Yearly";
    }
    throw UnimplementedError();
  }
}
