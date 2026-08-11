import 'package:el_race/core/theme/app_colors.dart';
import 'package:el_race/core/constants/text_styles.dart';
import 'package:el_race/data/models/report_model.dart';
import 'package:el_race/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

Future<ReportModel> showRenameDialog(BuildContext context,
    {required ReportModel report}) async {
  ReportModel updatedReport = report;
  TextEditingController renameController =
      TextEditingController(text: report.name);
  await showDialog(
    context: context,
    barrierColor:
        Colors.black.withValues(alpha: 0.5), // Transparent black background
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded border
        ),
        backgroundColor: AppThemeColors.surface, // White background
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1,
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                maxCharacter: 100,
                showLabel: true,
                required: true,
                controller: renameController,
                inputType: TextInputType.phone,
                hintText: "Rename ${report.report == 1 ? "Report" : "Project"}",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    height: 44,
                    color: AppThemeColors.reportContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      "Cancel",
                      style: CustomTextStyle.reportTitle.copyWith(
                        color: AppThemeColors.reportMaroon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MaterialButton(
                      onPressed: () {
                        updatedReport =
                            updatedReport.copyWith(name: renameController.text);
                        Navigator.pop(context);
                      },
                      height: 44,
                      color: AppThemeColors.reportMaroon,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        "Save",
                        style: CustomTextStyle.reportTitle.copyWith(
                          color: AppThemeColors.surface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );

  return updatedReport;
}
