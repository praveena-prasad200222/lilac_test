import 'package:expenzia/views/transcation_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/expense_database.dart';
import '../models/transaction_item.dart';

import 'transaction_form_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  List<TransactionItem> _all = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await ExpenseDatabase.instance.getAll();
      if (mounted)
        setState(() {
          _all = rows;
          _loading = false;
          _error = null;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = 'Could not load saved transactions. Please try again.';
        });
    }
  }

  double get _expenses =>
      _all.where((e) => e.type == 'expense').fold(0, (s, e) => s + e.amount);
  double get _credits =>
      _all.where((e) => e.type == 'credit').fold(0, (s, e) => s + e.amount);
  Future<void> _openForm(
      {TransactionItem? item, String type = 'expense'}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                TransactionFormScreen(item: item, type: item?.type ?? type)));
    _load();
  }

  Future<void> _delete(TransactionItem item) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Delete transaction?'),
                content: Text('Delete "${item.title}" permanently?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)))
                ]));
    if (ok == true && item.id != null) {
      await ExpenseDatabase.instance.delete(item.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _transactions(), _creditPage(), _profile()];
    return Scaffold(
        body: SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F7E79)))
                : pages[_tab]),
        floatingActionButton: _tab == 3
            ? null
            : FloatingActionButton.small(
                backgroundColor: const Color(0xFF2F7E79),
                onPressed: () =>
                    _openForm(type: _tab == 2 ? 'credit' : 'expense'),
                child: const Icon(Icons.add, color: Colors.white)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            color: const Color(0xFF2F7E79),
            shape: const CircularNotchedRectangle(),
            notchMargin: 5,
            child: SizedBox(
                height: 48,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home_outlined, 'Home', 0),
                      _navItem(Icons.history, 'Activity', 1),
                      const SizedBox(width: 36),
                      _navItem(
                          Icons.account_balance_wallet_outlined, 'Credit', 2),
                      _navItem(Icons.person_outline, 'Profile', 3),
                    ]))));
  }

  Widget _navItem(IconData icon, String label, int index) => InkWell(
      onTap: () => setState(() => _tab = index),
      child: SizedBox(
          width: 54,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 19, color: _tab == index ? Colors.white : Colors.white70),
            Text(label,
                style: TextStyle(
                    fontSize: 8,
                    color: _tab == index ? Colors.white : Colors.white70))
          ])));
  Widget _home() => RefreshIndicator(
      color: const Color(0xFF2F7E79),
      onRefresh: _load,
      child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 75),
          children: [
            const Text('Good evening,',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const Text('Sahal Muhammad',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 15),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFF2F7E79),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                          '₹${NumberFormat('#,##0.00').format(_credits - _expenses)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child:
                                _summary('Income', _credits, Icons.south_west)),
                        Expanded(
                            child: _summary(
                                'Expenses', _expenses, Icons.north_east))
                      ])
                    ])),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Today's Activity",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              TextButton(
                  onPressed: () => setState(() => _tab = 1),
                  child: const Text('See all',
                      style: TextStyle(color: Color(0xFF2F7E79), fontSize: 11)))
            ]),
            if (_error != null)
              _errorWidget()
            else if (_all.isEmpty)
              _empty('No transactions yet',
                  'Add your first expense to get started.')
            else
              ..._all.take(4).map((e) => TransactionTile(
                  item: e,
                  onEdit: () => _openForm(item: e),
                  onDelete: () => _delete(e))),
          ]));
  Widget _summary(String title, double amount, IconData icon) => Row(children: [
        Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 13)),
        const SizedBox(width: 7),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text('₹${NumberFormat('#,##0.00').format(amount)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600))
        ]))
      ]);
  Widget _transactions() =>
      _listPage('Transaction History', _all, 'No transactions found');
  Widget _creditPage() => _listPage('Credit',
      _all.where((e) => e.type == 'credit').toList(), 'No credit records yet');
  Widget _listPage(String title, List<TransactionItem> rows, String empty) =>
      Column(children: [
        Container(
            width: double.infinity,
            color: const Color(0xFF2F7E79),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600))),
        Expanded(
            child: _error != null
                ? _errorWidget()
                : rows.isEmpty
                    ? _empty(empty, 'Tap + to add a record.')
                    : ListView(
                        padding: const EdgeInsets.all(14),
                        children: rows
                            .map((e) => TransactionTile(
                                item: e,
                                onEdit: () => _openForm(item: e),
                                onDelete: () => _delete(e)))
                            .toList()))
      ]);
  Widget _profile() => ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 25),
        const Center(
            child: CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE5E5E5),
                child: Icon(Icons.person, size: 54, color: Colors.white))),
        const SizedBox(height: 12),
        const Center(
            child: Text('Sahal Muhammad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        const Center(
            child: Text('Personal account',
                style: TextStyle(fontSize: 11, color: Colors.black54))),
        const SizedBox(height: 30),
        OutlinedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: const Text('Clear storage?'),
                          content: const Text(
                              'This permanently deletes all locally saved transactions.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Clear',
                                    style: TextStyle(color: Colors.red)))
                          ]));
              if (ok == true) {
                await ExpenseDatabase.instance.clearAll();
                _load();
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Local transactions cleared')));
              }
            },
            child: const Text('Clear Storage',
                style: TextStyle(color: Colors.grey, fontSize: 11))),
        const SizedBox(height: 12),
        const Center(
            child: Text('Expenzia • Expense Management',
                style: TextStyle(fontSize: 10, color: Colors.black38)))
      ]);
  Widget _empty(String title, String subtitle) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(children: [
        const Icon(Icons.receipt_long_outlined,
            size: 42, color: Color(0xFF9BBAB8)),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 11))
      ]));
  Widget _errorWidget() => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton(onPressed: _load, child: const Text('Retry'))
      ]));
}
