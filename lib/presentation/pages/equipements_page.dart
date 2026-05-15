import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/entities/equipement.dart';
import 'package:frontend/presentation/state/equipement_state.dart';

class EquipementsPage extends StatefulWidget {
  const EquipementsPage({super.key});

  @override
  State<EquipementsPage> createState() => _EquipementsPageState();
}

class _EquipementsPageState extends State<EquipementsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipementState>().fetchEquipements();
    });
  }

  Color _getStatusColor(EquipementStatus s) {
    switch (s) {
      case EquipementStatus.enService: return const Color(0xFF10B981);
      case EquipementStatus.enMaintenance: return const Color(0xFFF59E0B);
      case EquipementStatus.enPanne: return const Color(0xFFEF4444);
      case EquipementStatus.reforme: return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(EquipementStatus s) {
    switch (s) {
      case EquipementStatus.enService: return 'En Service';
      case EquipementStatus.enMaintenance: return 'En Maintenance';
      case EquipementStatus.enPanne: return 'En Panne';
      case EquipementStatus.reforme: return 'Réformé';
    }
  }

  IconData _getStatusIcon(EquipementStatus s) {
    switch (s) {
      case EquipementStatus.enService: return Icons.check_circle_outline;
      case EquipementStatus.enMaintenance: return Icons.build_circle_outlined;
      case EquipementStatus.enPanne: return Icons.error_outline;
      case EquipementStatus.reforme: return Icons.archive_outlined;
    }
  }

  Color _getCriticiteColor(EquipementCriticite c) {
    switch (c) {
      case EquipementCriticite.basse: return const Color(0xFF3B82F6);
      case EquipementCriticite.moyenne: return const Color(0xFFF59E0B);
      case EquipementCriticite.haute: return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Gestion des Équipements', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir',
            onPressed: () => context.read<EquipementState>().fetchEquipements()),
        ],
      ),
      body: Consumer<EquipementState>(
        builder: (context, state, child) {
          if (state.isLoading && state.equipements.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement des équipements',
              ),
            );
          }
          if (state.error != null && state.equipements.isEmpty) {
            return Center(child: Text('Erreur: ${state.error}'));
          }
          if (!state.isLoading && state.equipements.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.precision_manufacturing_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Aucun équipement trouvé', style: GoogleFonts.inter(fontSize: 18, color: Colors.grey)),
            ]));
          }
          return Column(children: [
            _buildSummaryCards(state.equipements),
            Expanded(child: _buildContent(state.equipements)),
          ]);
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Equipement> list) {
    final enService = list.where((e) => e.statut == EquipementStatus.enService).length;
    final enMaint = list.where((e) => e.statut == EquipementStatus.enMaintenance).length;
    final enPanne = list.where((e) => e.statut == EquipementStatus.enPanne).length;
    final reforme = list.where((e) => e.statut == EquipementStatus.reforme).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (ctx, c) {
        final cards = [
          _statCard('Total', '${list.length}', Icons.precision_manufacturing, const Color(0xFF6366F1)),
          _statCard('En Service', '$enService', Icons.check_circle_outline, const Color(0xFF10B981)),
          _statCard('Maintenance', '$enMaint', Icons.build_circle_outlined, const Color(0xFFF59E0B)),
          _statCard('En Panne', '$enPanne', Icons.error_outline, const Color(0xFFEF4444)),
          _statCard('Réformés', '$reforme', Icons.archive_outlined, const Color(0xFF6B7280)),
        ];
        if (c.maxWidth > 600) {
          return Row(children: cards.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w))).toList());
        }
        return Wrap(spacing: 8, runSpacing: 8, children: cards.map((w) => SizedBox(width: (c.maxWidth - 16) / 2, child: w)).toList());
      }),
    );
  }

  Widget _statCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(count, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
        ])),
      ]),
    );
  }

  Widget _buildContent(List<Equipement> list) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth > 800) return _buildTable(list);
      return _buildCards(list);
    });
  }

  Widget _buildTable(List<Equipement> list) {
    return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF475569), fontSize: 13),
          dataTextStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155)),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Code')), DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Statut')), DataColumn(label: Text('Localisation')),
            DataColumn(label: Text('Criticité')), DataColumn(label: Text('Acquisition')),
          ],
          rows: list.map((eq) => DataRow(cells: [
            DataCell(Text(eq.code, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6366F1)))),
            DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 250), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(eq.nom, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (eq.description.isNotEmpty) Text(eq.description, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]))),
            DataCell(_statusBadge(eq.statut)),
            DataCell(Text(eq.localisation)),
            DataCell(_criticiteBadge(eq.criticite)),
            DataCell(Text(_fmtDate(eq.dateAcquisition))),
          ])).toList(),
        ),
      )),
    ));
  }

  Widget _statusBadge(EquipementStatus s) {
    final c = _getStatusColor(s);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_getStatusIcon(s), size: 14, color: c), const SizedBox(width: 4),
        Text(_getStatusLabel(s), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
      ]));
  }

  Widget _criticiteBadge(EquipementCriticite cr) {
    final c = _getCriticiteColor(cr);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Text(cr.value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)));
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _buildCards(List<Equipement> list) {
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (ctx, i) {
      final eq = list[i];
      return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(eq.nom, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 2),
              Text(eq.code, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF6366F1))),
            ])),
            _statusBadge(eq.statut),
          ]),
          if (eq.description.isNotEmpty) ...[const SizedBox(height: 8), Text(eq.description, style: TextStyle(fontSize: 13, color: Colors.grey[600]))],
          const Divider(height: 24),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]), const SizedBox(width: 4),
            Expanded(child: Text(eq.localisation, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
            _criticiteBadge(eq.criticite),
          ]),
        ])),
      );
    });
  }
}
