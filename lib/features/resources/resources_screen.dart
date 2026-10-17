import 'package:flutter/material.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill_tabs.dart';
import 'data/resources_models.dart';
import 'widgets/resource_tile.dart';

/// 11.2 Resources: 11.2.1 Articles & Tips · 11.2.2 Workout Videos.
class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kind = _tab == 0 ? ResourceKind.article : ResourceKind.video;
    final items = demoResources.where((r) => r.kind == kind).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(l10n.tabNews, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.articlesTips, l10n.workoutVideos],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg + AppSpacing.navOverlap,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => ResourceTile(resource: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}
