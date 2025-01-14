import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet_action_widget.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet_drag_handler.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet_rename_widget.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet_view_item.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet_view_item_header.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

enum MobileViewBottomSheetBodyAction {
  undo,
  redo,
  share,
  rename,
  duplicate,
  delete,
  addToFavorites,
  removeFromFavorites,
  helpCenter;
}

typedef MobileViewBottomSheetBodyActionCallback = void Function(
  MobileViewBottomSheetBodyAction action,
);

class ViewPageBottomSheet extends StatefulWidget {
  const ViewPageBottomSheet({
    super.key,
    required this.view,
    required this.onAction,
    required this.onRename,
  });

  final ViewPB view;
  final MobileViewBottomSheetBodyActionCallback onAction;
  final void Function(String name) onRename;

  @override
  State<ViewPageBottomSheet> createState() => _ViewPageBottomSheetState();
}

class _ViewPageBottomSheetState extends State<ViewPageBottomSheet> {
  MobileBottomSheetType type = MobileBottomSheetType.view;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // drag handler
        const MobileBottomSheetDragHandler(),

        // header
        _buildHeader(),
        const VSpace(8.0),
        const Divider(),

        // body
        _buildBody(),
        const VSpace(24.0),
      ],
    );
  }

  Widget _buildHeader() {
    switch (type) {
      case MobileBottomSheetType.view:
      case MobileBottomSheetType.rename:
        // header
        return MobileViewItemBottomSheetHeader(
          showBackButton: type != MobileBottomSheetType.view,
          view: widget.view,
          onBack: () {
            setState(() {
              type = MobileBottomSheetType.view;
            });
          },
        );
    }
  }

  Widget _buildBody() {
    switch (type) {
      case MobileBottomSheetType.view:
        return MobileViewBottomSheetBody(
          view: widget.view,
          onAction: (action) {
            switch (action) {
              case MobileViewBottomSheetBodyAction.rename:
                setState(() {
                  type = MobileBottomSheetType.rename;
                });
                break;
              default:
                widget.onAction(action);
            }
          },
        );

      case MobileBottomSheetType.rename:
        return MobileBottomSheetRenameWidget(
          name: widget.view.name,
          onRename: (name) {
            widget.onRename(name);
          },
        );
    }
  }
}

class MobileViewBottomSheetBody extends StatelessWidget {
  const MobileViewBottomSheetBody({
    super.key,
    required this.view,
    required this.onAction,
  });

  final ViewPB view;
  final MobileViewBottomSheetBodyActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isFavorite = view.isFavorite;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // undo, redo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_undo_m,
                text: LocaleKeys.toolbar_undo.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.undo,
                ),
              ),
            ),
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_redo_m,
                text: LocaleKeys.toolbar_redo.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.redo,
                ),
              ),
            ),
          ],
        ),

        // rename, duplicate
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_rename_m,
                text: LocaleKeys.button_rename.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.rename,
                ),
              ),
            ),
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_duplicate_m,
                text: LocaleKeys.button_duplicate.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.duplicate,
                ),
              ),
            ),
          ],
        ),

        // share, delete
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_share_m,
                text: LocaleKeys.button_share.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.share,
                ),
              ),
            ),
            Expanded(
              child: BottomSheetActionWidget(
                svg: FlowySvgs.m_delete_m,
                text: LocaleKeys.button_delete.tr(),
                onTap: () => onAction(
                  MobileViewBottomSheetBodyAction.delete,
                ),
              ),
            ),
          ],
        ),

        // favorites
        BottomSheetActionWidget(
          svg: isFavorite
              ? FlowySvgs.m_favorite_selected_lg
              : FlowySvgs.m_favorite_unselected_lg,
          text: isFavorite
              ? LocaleKeys.button_removeFromFavorites.tr()
              : LocaleKeys.button_addToFavorites.tr(),
          onTap: () => onAction(
            isFavorite
                ? MobileViewBottomSheetBodyAction.removeFromFavorites
                : MobileViewBottomSheetBodyAction.addToFavorites,
          ),
        ),

        // help center
        BottomSheetActionWidget(
          svg: FlowySvgs.m_help_center_m,
          text: LocaleKeys.button_helpCenter.tr(),
          onTap: () => onAction(
            MobileViewBottomSheetBodyAction.helpCenter,
          ),
        ),
      ],
    );
  }
}
