import 'package:el_race/core/app_globals.dart';
import 'package:el_race/ui/presentation/home_screen/bloc/profile_box/profile_box_bloc.dart';
import 'package:el_race/ui/presentation/home_screen/bloc/profile_box/profile_box_event.dart';
import 'package:el_race/ui/presentation/home_screen/bloc/profile_box/profile_box_state.dart';
import 'package:el_race/ui/presentation/home_screen/widgets/profile_widgets/profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listens to [ProfileBoxBloc] and opens the profile bottom sheet
/// instead of the legacy side drawer.
class ProfileSheetHost extends StatefulWidget {
  const ProfileSheetHost({super.key});

  @override
  State<ProfileSheetHost> createState() => _ProfileSheetHostState();
}

class _ProfileSheetHostState extends State<ProfileSheetHost> {
  bool _sheetOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBoxBloc, ProfileBoxState>(
      listenWhen: (previous, current) =>
          !previous.isProfileVisible && current.isProfileVisible,
      listener: (context, state) {
        if (_sheetOpen) return;

        context.read<ProfileBoxBloc>().add(const ProfileBoxHidden());

        final sheetContext = navKey.currentContext;
        if (sheetContext == null) return;

        _sheetOpen = true;
        ProfileBottomSheet.show(sheetContext).whenComplete(() {
          _sheetOpen = false;
        });
      },
      child: const SizedBox.shrink(),
    );
  }
}

/// Backward-compatible alias for existing imports.
typedef ProfileBoxWithSlideAnimation = ProfileSheetHost;
