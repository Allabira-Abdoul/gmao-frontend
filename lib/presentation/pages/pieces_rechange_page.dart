import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/entities/piece_rechange.dart';
import 'package:frontend/presentation/state/piece_rechange_state.dart';

class PiecesRechangePage extends StatefulWidget {
  const PiecesRechangePage({super.key});

  @override
  State<PiecesRechangePage> createState() => _PiecesRechangePageState();
}

class _PiecesRechangePageState extends State<PiecesRechangePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PieceRechangeState>().fetchPiecesRechange();
    });
  }

  Color _stockColor(PieceRechange p) {
    if (p.quantiteEnStock == 0) return const Color(0xFFEF4444);
    if (p.quantiteEnStock <= p.seuilAlerte) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _stockLabel(PieceRechange p) {
    if (p.quantiteEnStock == 0) return 'Rupture';
    if (p.quantiteEnStock <= p.seuilAlerte) return 'Stock bas';
    return 'OK';
  }

  IconData _stockIcon(PieceRechange p) {
    if (p.quantiteEnStock == 0) return Icons.cancel_outlined;
    if (p.quantiteEnStock <= p.seuilAlerte) return Icons.warning_amber_rounded;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Pièces de Rechange', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir',
            onPressed: () => context.read<PieceRechangeState>().fetchPiecesRechange()),
        ],
      ),
      body: Consumer<PieceRechangeState>(
        builder: (context, state, child) {
          if (state.isLoading && state.pieces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.pieces.isEmpty) {
            return Center(child: Text('Erreur: ${state.error}'));
          }
          if (!state.isLoading && state.pieces.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Aucune pièce trouvée', style: GoogleFonts.inter(fontSize: 18, color: Colors.grey)),
            ]));
          }
          return Column(children: [
            _buildSummaryCards(state.pieces),
            Expanded(child: _buildContent(state.pieces)),
          ]);
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<PieceRechange> list) {
    final total = list.length;
    final ok = list.where((p) => p.quantiteEnStock > p.seuilAlerte).length;
    final bas = list.where((p) => p.quantiteEnStock > 0 && p.quantiteEnStock <= p.seuilAlerte).length;
    final rupture = list.where((p) => p.quantiteEnStock == 0).length;
    final valeur = list.fold<double>(0.0, (sum, p) => sum + (p.coutUnitaire * p.quantiteEnStock));

    return Padding(padding: const EdgeInsets.all(16), child: LayoutBuilder(builder: (ctx, c) {
      final cards = [
        _statCard('Total Pièces', '$total', Icons.inventory_2, const Color(0xFF6366F1)),
        _statCard('Stock OK', '$ok', Icons.check_circle_outline, const Color(0xFF10B981)),
        _statCard('Stock Bas', '$bas', Icons.warning_amber_rounded, const Color(0xFFF59E0B)),
        _statCard('Rupture', '$rupture', Icons.cancel_outlined, const Color(0xFFEF4444)),
        _statCard('Valeur Stock', '${valeur.toStringAsFixed(0)} DA', Icons.attach_money, const Color(0xFF8B5CF6)),
      ];
      if (c.maxWidth > 600) {
        return Row(children: cards.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w))).toList());
      }
      return Wrap(spacing: 8, runSpacing: 8, children: cards.map((w) => SizedBox(width: (c.maxWidth - 16) / 2, child: w)).toList());
    }));
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
          Text(count, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
        ])),
      ]),
    );
  }

  Widget _buildContent(List<PieceRechange> list) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth > 800) return _buildTable(list);
      return _buildCards(list);
    });
  }

  Widget _buildTable(List<PieceRechange> list) {
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
            DataColumn(label: Text('Référence')), DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Stock'), numeric: true), DataColumn(label: Text('Seuil'), numeric: true),
            DataColumn(label: Text('État Stock')), DataColumn(label: Text('Coût Unitaire'), numeric: true),
          ],
          rows: list.map((p) => DataRow(cells: [
            DataCell(Text(p.reference, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6366F1)))),
            DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 250), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(p.nom, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (p.description.isNotEmpty) Text(p.description, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]))),
            DataCell(Text('${p.quantiteEnStock}', style: TextStyle(fontWeight: FontWeight.w600, color: _stockColor(p)))),
            DataCell(Text('${p.seuilAlerte}')),
            DataCell(_stockBadge(p)),
            DataCell(Text('${p.coutUnitaire.toStringAsFixed(2)} DA')),
          ])).toList(),
        ),
      )),
    ));
  }

  Widget _stockBadge(PieceRechange p) {
    final c = _stockColor(p);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_stockIcon(p), size: 14, color: c), const SizedBox(width: 4),
        Text(_stockLabel(p), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
      ]));
  }

  Widget _buildCards(List<PieceRechange> list) {
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (ctx, i) {
      final p = list[i];
      return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.nom, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 2),
              Text(p.reference, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF6366F1))),
            ])),
            _stockBadge(p),
          ]),
          if (p.description.isNotEmpty) ...[const SizedBox(height: 8), Text(p.description, style: TextStyle(fontSize: 13, color: Colors.grey[600]))],
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.inventory, size: 16, color: Colors.grey[500]), const SizedBox(width: 4),
              Text('Stock: ${p.quantiteEnStock}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.notifications_active_outlined, size: 16, color: Colors.grey[500]), const SizedBox(width: 4),
              Text('Seuil: ${p.seuilAlerte}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ]),
            Text('${p.coutUnitaire.toStringAsFixed(2)} DA', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF8B5CF6))),
          ]),
        ])),
      );
    });
  }
}
