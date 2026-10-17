import 'package:flutter/material.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill_tabs.dart';

/// 11.4 Support & Help: Help Center (FAQ) · Online Support (chat).
/// TODO(ai): Online Support → AI chat-trener (Claude Haiku / Gemini Flash, server orqali).
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.tabSupport, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.helpCenter, l10n.onlineSupport],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _tab == 0 ? const _HelpCenter() : const _Chat()),
        ],
      ),
    );
  }
}

class _HelpCenter extends StatelessWidget {
  const _HelpCenter();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faq = [
      (l10n.faq1Q, l10n.faq1A),
      (l10n.faq2Q, l10n.faq2A),
      (l10n.faq3Q, l10n.faq3A),
      (l10n.faq4Q, l10n.faq4A),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: faq.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textSecondary,
            title: Text(faq[i].$1, style: AppTextStyles.title),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            expandedAlignment: Alignment.centerLeft,
            children: [Text(faq[i].$2, style: AppTextStyles.bodySecondary)],
          ),
        ),
      ),
    );
  }
}

class _Chat extends StatefulWidget {
  const _Chat();

  @override
  State<_Chat> createState() => _ChatState();
}

class _ChatState extends State<_Chat> {
  final _input = TextEditingController();
  final _messages = <(bool fromUser, String text)>[];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add((true, text)));
    _input.clear();
    // TODO(ai): serverdagi /ai/chat ga yuborish.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _messages.add((false, context.l10n.supportAutoReply)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = [(false, l10n.supportGreeting), ..._messages];
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: all.length,
            itemBuilder: (_, i) {
              final (fromUser, text) = all[i];
              return Align(
                alignment: fromUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: fromUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.md),
                      topRight: const Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(fromUser ? AppRadius.md : 4),
                      bottomRight: Radius.circular(fromUser ? 4 : AppRadius.md),
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      color: fromUser
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md + AppSpacing.navOverlap,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _send(),
                    style: AppTextStyles.body,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(hintText: l10n.typeMessage),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _send,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    fixedSize: const Size(52, 52),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
