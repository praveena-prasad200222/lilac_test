import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TransactionTile(
      {super.key,
      required this.item,
      required this.onEdit,
      required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final isCredit = item.type == 'credit';
    final color = isCredit ? const Color(0xFF28A879) : const Color(0xFFE05B57);
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F3F2),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(_iconFor(item.category),
                  color: const Color(0xFF2F7E79), size: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                    '${item.category} • ${DateFormat('dd MMM yyyy').format(item.date)}',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.black54)),
              ])),
          Text(
              '${isCredit ? '+' : '-'} ${NumberFormat('#,##0.00').format(item.amount)}',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 18,
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete'))
                  ]),
        ]));
  }

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return Icons.restaurant;
      case 'travel':
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'bills':
        return Icons.receipt_long;
      case 'salary':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}
