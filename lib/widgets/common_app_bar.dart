import 'package:flutter/material.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CommonAppBar {
  static Widget _buildTitle(BuildContext context, {Widget? centerWidget}) {
    final String dateStr = DateFormat(
      'EEEE, MMM d',
    ).format(DateTime.now()).toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dateStr,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        if (centerWidget != null)
          centerWidget
        else
          const Text(
            'Grace Stream',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  static Widget _buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: AppColors.textLight),
      onPressed: () {
        final scaffold = Scaffold.of(context);
        if (scaffold.hasDrawer) {
          scaffold.openDrawer();
        }
      },
    );
  }

  static List<Widget> _buildActions(
    BuildContext context, {
    List<Widget>? additionalActions,
  }) {
    return [
      if (additionalActions != null) ...additionalActions,
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary, size: 20),
        ),
      ),
    ];
  }

  static SliverAppBar sliver(
    BuildContext context, {
    Widget? centerWidget,
    List<Widget>? additionalActions,
    bool pinned = false,
    bool floating = true,
  }) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: floating,
      pinned: pinned,
      elevation: 0,
      leading: _buildLeading(context),
      centerTitle: true,
      title: _buildTitle(context, centerWidget: centerWidget),
      actions: _buildActions(context, additionalActions: additionalActions),
    );
  }

  static AppBar standard(
    BuildContext context, {
    Widget? centerWidget,
    List<Widget>? additionalActions,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildLeading(context),
      centerTitle: true,
      title: _buildTitle(context, centerWidget: centerWidget),
      actions: _buildActions(context, additionalActions: additionalActions),
    );
  }
}
