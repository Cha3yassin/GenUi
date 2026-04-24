import 'package:flutter/material.dart';

import '../../shared/models/procedure_model.dart';

class ProcedureSemanticTheme {
  const ProcedureSemanticTheme({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
    required this.secondary,
    required this.surface,
    required this.layoutStyle,
    required this.summaryHint,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color accent;
  final Color secondary;
  final Color surface;
  final String layoutStyle;
  final String summaryHint;
}

ProcedureSemanticTheme inferProcedureSemanticTheme(
  ProcedureModel procedure, {
  String locale = 'fr',
}) {
  final isArabic = locale == 'ar';
  final isEnglish = locale == 'en';
  final corpus = _normalizedCorpus(procedure);

  if (_matchesAny(corpus, const [
    'vente',
    'cession',
    'mutation',
    'acheteur',
    'vendeur',
    'contrat de vente',
  ])) {
    return ProcedureSemanticTheme(
      id: 'legal_transfer',
      label: isArabic
          ? 'نقل / بيع'
          : isEnglish
              ? 'Transfer / Sale'
              : 'Mutation / Vente',
      icon: Icons.compare_arrows_rounded,
      accent: Color(0xFF8B5E3C),
      secondary: Color(0xFF355C7D),
      surface: Color(0xFFF8F2ED),
      layoutStyle: 'dossier_first',
      summaryHint: isArabic
          ? 'مسار قانوني ووثائق تعاقدية'
          : isEnglish
              ? 'Legal flow and contractual documents'
              : 'Parcours juridique et pièces contractuelles',
    );
  }

  if (_matchesAny(corpus, const [
    'achat',
    'acheter',
    'concessionnaire',
    'bon de commande',
    'facture',
    'vehicule neuf',
  ])) {
    return ProcedureSemanticTheme(
      id: 'acquisition',
      label: isArabic
          ? 'شراء / اقتناء'
          : isEnglish
              ? 'Purchase / Acquisition'
              : 'Achat / Acquisition',
      icon: Icons.shopping_bag_rounded,
      accent: Color(0xFF0E7490),
      secondary: Color(0xFF155E75),
      surface: Color(0xFFEFF9FC),
      layoutStyle: 'featured_budget',
      summaryHint: isArabic
          ? 'الميزانية، المزود، وإدخال الاستعمال'
          : isEnglish
              ? 'Budget, supplier, and road activation'
              : 'Budget, fournisseur et mise en circulation',
    );
  }

  if (_matchesAny(corpus, const [
    'renouvellement',
    'nouvelle cin',
    'renouveler',
    'expire',
    'duplicata',
  ])) {
    return ProcedureSemanticTheme(
      id: 'renewal',
      label: isArabic
          ? 'تجديد'
          : isEnglish
              ? 'Renewal'
              : 'Renouvellement',
      icon: Icons.autorenew_rounded,
      accent: Color(0xFF2563EB),
      secondary: Color(0xFF1D4ED8),
      surface: Color(0xFFF1F6FF),
      layoutStyle: 'compact_workflow',
      summaryHint: isArabic
          ? 'تحديث، إيداع، واستلام'
          : isEnglish
              ? 'Update, submission, and pickup'
              : 'Mise à jour, dépôt et retrait',
    );
  }

  if (_matchesAny(corpus, const [
    'startup',
    'start up',
    'sarl',
    'societe',
    'entreprise',
    'rne',
    'patente',
  ])) {
    return ProcedureSemanticTheme(
      id: 'business_launch',
      label: isArabic
          ? 'تأسيس / إطلاق'
          : isEnglish
              ? 'Creation / Launch'
              : 'Création / Lancement',
      icon: Icons.rocket_launch_rounded,
      accent: Color(0xFFD6A94A),
      secondary: Color(0xFF2F4B7C),
      surface: Color(0xFFF8F4EA),
      layoutStyle: 'dashboard_launch',
      summaryHint: isArabic
          ? 'إطلاق، امتثال، وتفعيل'
          : isEnglish
              ? 'Launch, compliance, and activation'
              : 'Lancement, conformité et activation',
    );
  }

  return ProcedureSemanticTheme(
    id: 'general_admin',
    label: isArabic
        ? 'إجراء إداري'
        : isEnglish
            ? 'Administrative procedure'
            : 'Procédure administrative',
    icon: Icons.account_tree_rounded,
    accent: Color(0xFF4F46E5),
    secondary: Color(0xFF334155),
    surface: Color(0xFFF5F7FB),
    layoutStyle: 'balanced',
    summaryHint: isArabic
        ? 'عرض ديناميكي للإجراء'
        : isEnglish
            ? 'Dynamic procedure view'
            : 'Vue dynamique de la procédure',
  );
}

String _normalizedCorpus(ProcedureModel procedure) {
  final buffer = StringBuffer();
  buffer.write('${procedure.summary.title} ');
  buffer.write('${procedure.summary.summary} ');

  for (final block in procedure.blocks) {
    final data = block.data;
    if (data['title'] != null) buffer.write('${data['title']} ');
    if (data['subtitle'] != null) buffer.write('${data['subtitle']} ');
    if (data['body'] != null) buffer.write('${data['body']} ');

    final items = data['items'] as List<dynamic>?;
    if (items != null) {
      for (final item in items) {
        buffer.write('$item ');
      }
    }

    final steps = data['steps'] as List<dynamic>?;
    if (steps != null) {
      for (final step in steps) {
        if (step is Map<String, dynamic>) {
          buffer.write('${step['title']} ${step['description']} ');
        }
      }
    }

    final fees = data['fees'] as List<dynamic>?;
    if (fees != null) {
      for (final fee in fees) {
        if (fee is Map<String, dynamic>) {
          buffer.write('${fee['label']} ');
        }
      }
    }
  }

  return buffer.toString().toLowerCase();
}

bool _matchesAny(String corpus, List<String> terms) {
  return terms.any(corpus.contains);
}
