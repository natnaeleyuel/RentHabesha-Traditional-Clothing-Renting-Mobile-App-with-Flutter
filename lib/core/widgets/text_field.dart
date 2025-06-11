import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomTextField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final String placeholder;
  final bool isPassword;
  final double borderRadius;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.borderRadius = 25,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _showPassword;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _showPassword = !widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppColors.bodyText(context), // Using dynamic color
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          focusNode: _focusNode,
          controller: TextEditingController(text: widget.value)
            ..selection = TextSelection.collapsed(offset: widget.value.length),
          onChanged: widget.onChanged,
          obscureText: widget.isPassword && !_showPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _focusNode.hasFocus
                    ? AppColors.focusedTextFieldStroke(context)
                    : AppColors.unfocusedTextFieldStroke(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.unfocusedTextFieldStroke(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.focusedTextFieldStroke(context),
              ),
            ),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: AppColors.unfocusedTextFieldText(context),
            ),
            suffixIcon: widget.isPassword
                ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: _focusNode.hasFocus
                      ? AppColors.focusedTextFieldText(context)
                      : AppColors.unfocusedTextFieldText(context),
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            )
                : null,
          ),
          style: TextStyle(
            color: _focusNode.hasFocus
                ? AppColors.focusedTextFieldText(context)
                : AppColors.unfocusedTextFieldText(context),
          ),
        ),
      ],
    );
  }
}


class CustomTextField2 extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final bool isPassword;
  final double borderRadius;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomTextField2({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.borderRadius = 25,
    this.focusNode,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<CustomTextField2> createState() => _CustomTextFieldState2();
}

class _CustomTextFieldState2 extends State<CustomTextField2> {
  late bool _showPassword;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _showPassword = !widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppColors.bodyText(context),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword && !_showPassword,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _focusNode.hasFocus
                    ? AppColors.focusedTextFieldStroke(context)
                    : AppColors.unfocusedTextFieldStroke(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.unfocusedTextFieldStroke(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.focusedTextFieldStroke(context),
              ),
            ),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: AppColors.unfocusedTextFieldText(context),
            ),
            suffixIcon: widget.isPassword
                ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: _focusNode.hasFocus
                      ? AppColors.focusedTextFieldText(context)
                      : AppColors.unfocusedTextFieldText(context),
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            )
                : null,
          ),
          style: TextStyle(
            color: _focusNode.hasFocus
                ? AppColors.focusedTextFieldText(context)
                : AppColors.unfocusedTextFieldText(context),
          ),
        ),
      ],
    );
  }
}