import 'package:flutter/material.dart';

class TextFieldEditor extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final String? label;
  final InputDecoration? decoration;
  final int maxLines;
  final IconData? icon;
  final String? Function(String value)? validator;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;

  const TextFieldEditor({
    super.key,
    required this.initialValue,
    this.label,
    this.onSubmitted,
    this.hintText = '',
    this.decoration,
    this.maxLines = 1,
    this.icon,
    this.validator,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<TextFieldEditor> createState() => TextFieldEditorState();
}

class TextFieldEditorState extends State<TextFieldEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscure = false;

  String? _errorText;
  set errorText(String? value) {
    setState(() {
      _errorText = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _obscure = widget.obscureText;

    // Add a listener to handle focus loss
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateAndSubmit();
      }
    });
  }

  bool validate() {
    final value = _controller.text.trim();
    String? error;
    if (widget.validator != null) {
      error = widget.validator!(value);
    }
    setState(() {
      _errorText = error;
    });
    if (error == null) {
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(value);
      }
      return true;
    }
    return false;
  }

  void _validateAndSubmit() {
    final value = _controller.text.trim();
    String? error;
    if (widget.validator != null) {
      error = widget.validator!(value);
    }
    setState(() {
      _errorText = error;
    });
    if (error == null) {
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(value);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          decoration: (widget.decoration != null
                  ? widget.decoration!
                  : InputDecoration(
                      prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.grey) : null,
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ))
              .copyWith(
            errorText: _errorText,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            errorStyle: const TextStyle(color: Colors.red),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color.fromARGB(255, 187, 61, 52)),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            _validateAndSubmit();
          },
        ),
      ],
    );
  }
}
