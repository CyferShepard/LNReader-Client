import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../models/source_filter_field.dart';

class FilterBuilder extends StatefulWidget {
  final List<SourceFilterField> filters;
  final void Function(Map<String, dynamic> values)? onApply;

  const FilterBuilder({super.key, required this.filters, this.onApply});

  @override
  State<FilterBuilder> createState() => _FilterBuilderState();
}

class _FilterBuilderState extends State<FilterBuilder> {
  Map<String, dynamic> _values = apiController.filters;
  final Map<String, MultiSelectController<FieldOptions>> _controllers = {};

  @override
  void initState() {
    super.initState();
    initFilters();
  }

  initFilters({bool initControllers = true}) {
    for (final filter in widget.filters.where((f) => !f.isMainSearchField)) {
      if (filter.type.type == 'multiSelect') {
        _values[filter.fieldName] = _values[filter.fieldName] ?? filter.type.defaultValue?.value ?? <String>{};
        if (initControllers) {
          _controllers[filter.fieldName] = MultiSelectController<FieldOptions>();
        }
      } else {
        _values[filter.fieldName] = _values[filter.fieldName] ??
            (filter.type.defaultValue != null
                ? filter.type.defaultValue is int
                    ? filter.type.defaultValue.toString()
                    : filter.type.defaultValue.value
                : null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters'),
      content: SizedBox(
        // width: context.isTabletOrDesktop ? 600 : double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.filters.map(_buildField).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.onApply != null) widget.onApply!(_values);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            _values = {};
            initFilters(initControllers: false);
            Navigator.of(context).pop();
            if (widget.onApply != null) widget.onApply!(_values);
          },
          child: const Text('Reset Filters'),
        ),
      ],
    );
  }

  Widget _buildField(SourceFilterField filter) {
    switch (filter.type.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFieldEditor(
            label: filter.fieldName,
            initialValue: _values[filter.fieldName] ?? '',
            onSubmitted: (val) => _values[filter.fieldName] = val,
          ),
        );
      case 'numeric':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFieldEditor(
            label: filter.fieldName,
            initialValue: _values[filter.fieldName] ?? '',
            onSubmitted: (val) => _values[filter.fieldName] = val,
            keyboardType: TextInputType.number,
          ),
        );
      case 'dropdown':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: filter.fieldName),
            value: _values[filter.fieldName],
            items: filter.type.fieldOptions
                .map((opt) => DropdownMenuItem(
                      value: opt.value,
                      child: Text(opt.name),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _values[filter.fieldName] = val),
          ),
        );
      case 'multiSelect':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: MultiDropdown<FieldOptions>(
            // showClearIcon: false,
            fieldDecoration: FieldDecoration(
              labelText: filter.fieldName,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            controller: _controllers[filter.fieldName],
            onSelectionChange: (options) {
              setState(() {
                _values[filter.fieldName] = options.map((option) => option.value).toSet();
              });
            },
            items: filter.type.fieldOptions.map((option) {
              var selectedOptions = _values[filter.fieldName] as Set<String>? ?? <String>{};
              bool isSelected = selectedOptions.contains(option.value);
              return DropdownItem<FieldOptions>(
                value: option,
                label: option.name,
                selected: isSelected,
              );
            }).toList(),
            dropdownItemDecoration: DropdownItemDecoration(
              selectedIcon: const Icon(Icons.check_circle),
              selectedTextColor: Theme.of(context).colorScheme.onPrimary,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            dropdownDecoration: DropdownDecoration(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              maxHeight: 300,
              borderRadius: BorderRadius.circular(10),
            ),

            chipDecoration: ChipDecoration(
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// Usage example (show as popup):
// showDialog(
//   context: context,
//   builder: (ctx) => FilterBuilder(filters: source.filters, onApply: (values) { ... }),
//
