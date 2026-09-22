import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/app_colors.dart';

enum LegalDocument { termsOfService, privacyPolicy }

const _termsAsset = 'tools/assets/TermsOfService.txt';
const _privacyAsset = 'tools/assets/PrivacyPolicy.txt';

String _titleFor(LegalDocument document) =>
    document == LegalDocument.termsOfService
    ? 'Terms of Service'
    : 'Privacy Policy';

String _assetFor(LegalDocument document) =>
    document == LegalDocument.termsOfService ? _termsAsset : _privacyAsset;

Future<void> showLegalDocument(BuildContext context, LegalDocument document) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: SizedBox(
        width: 640,
        height: MediaQuery.sizeOf(dialogContext).height * 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _titleFor(document),
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<String>(
                  future: rootBundle.loadString(_assetFor(document)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 8),
                        child: SelectableText(
                          snapshot.data!,
                          style: AppTextStyles.bodySm.copyWith(height: 1.55),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LegalLinks extends StatelessWidget {
  final TextStyle? style;
  const LegalLinks({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant);
    final linkStyle = baseStyle.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('By continuing, you agree to the ', style: baseStyle),
        TextButton(
          onPressed: () =>
              showLegalDocument(context, LegalDocument.termsOfService),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Terms of Service', style: linkStyle),
        ),
        Text(' and ', style: baseStyle),
        TextButton(
          onPressed: () =>
              showLegalDocument(context, LegalDocument.privacyPolicy),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Privacy Policy', style: linkStyle),
        ),
        Text('.', style: baseStyle),
      ],
    );
  }
}

class LegalAgreementRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const LegalAgreementRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: LegalLinks()),
      ],
    );
  }
}

Future<bool> showLegalAgreementDialog(BuildContext context) async {
  var agreed = false;
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Before you continue'),
            content: const Text(
              'Please review and accept Civica’s Terms of Service and Privacy Policy to complete Google sign-up.',
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: [
              LegalAgreementRow(
                value: agreed,
                onChanged: (value) =>
                    setDialogState(() => agreed = value ?? false),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel sign-up'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: agreed
                        ? () => Navigator.of(dialogContext).pop(true)
                        : null,
                    child: const Text('Agree and continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ) ??
      false;
}
