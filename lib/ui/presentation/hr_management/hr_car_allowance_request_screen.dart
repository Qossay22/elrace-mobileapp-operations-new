import 'dart:convert';

import 'package:el_race/core/hr_management/providers/hr_management_providers.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/hr_management/widgets/hr_request_form_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Car Allowance — Odoo screenshot fields (car_req_type + rent_type).
class HrCarAllowanceRequestScreen extends ConsumerStatefulWidget {
  const HrCarAllowanceRequestScreen({super.key});

  static const draftKey = 'hr_draft_car_allowance_v2';

  @override
  ConsumerState<HrCarAllowanceRequestScreen> createState() =>
      _HrCarAllowanceRequestScreenState();
}

class _HrCarAllowanceRequestScreenState
    extends ConsumerState<HrCarAllowanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _carReqType;
  String? _rentType;
  final _description = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _loadDraft() {
    final raw =
        SharedPref().getPreferenceString(HrCarAllowanceRequestScreen.draftKey);
    if (raw.isEmpty) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _carReqType = m['car_req_type'] as String?;
      _rentType = m['rent_type'] as String?;
      _description.text = m['description'] as String? ?? '';
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    await SharedPref().setPreferencesString(
      HrCarAllowanceRequestScreen.draftKey,
      jsonEncode({
        'car_req_type': _carReqType,
        'rent_type': _rentType,
        'description': _description.text,
      }),
    );
    Fluttertoast.showToast(msg: 'Draft saved');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await HrRequestFormUi.submit(
      api: ref.read(hrApiClientProvider),
      code: 'Car Allowance',
      fields: {
        'car_req_type': _carReqType,
        if (_rentType != null) 'rent_type': _rentType,
      },
      description: _description.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      await SharedPref()
          .removePreference(HrCarAllowanceRequestScreen.draftKey);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrLegacyRequestFormShell(
      title: 'Car Allowance',
      formKey: _formKey,
      submitting: _submitting,
      onSaveDraft: _saveDraft,
      onSubmit: _submit,
      children: [
        HrRequestFormUi.label('Car Request Type *'),
        HrRequestFormUi.dropdown<String>(
          value: _carReqType,
          hint: 'Select type',
          items: const [
            DropdownMenuItem(value: 'request', child: Text('Request')),
            DropdownMenuItem(value: 'return', child: Text('Return')),
          ],
          onChanged: (v) => setState(() => _carReqType = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
        SizedBox(height: 14.h),
        HrRequestFormUi.label('Rent Type'),
        HrRequestFormUi.dropdown<String>(
          value: _rentType,
          hint: 'Select rent type',
          items: const [
            DropdownMenuItem(value: 'limitted', child: Text('Limited')),
            DropdownMenuItem(value: 'permanent', child: Text('Permanent')),
          ],
          onChanged: (v) => setState(() => _rentType = v),
        ),
        SizedBox(height: 14.h),
        HrRequestFormUi.label('Description'),
        TextFormField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          decoration:
              HrRequestFormUi.fieldDecoration('Write your description...'),
        ),
      ],
    );
  }
}
