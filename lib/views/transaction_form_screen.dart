import 'package:expenzia/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/expense_database.dart';
import '../models/transaction_item.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionItem? item;
  final String type;
  const TransactionFormScreen({super.key, this.item, this.type = 'expense'});
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Salary',
    'Other'
  ];
  String? _category;
  String _frequency = 'Monthly';
  late DateTime _date;
  bool _saving = false;
  bool get _isCredit => (widget.item?.type ?? widget.type) == 'credit';
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _date = item?.date ?? DateTime.now();
    _title.text = item?.title ?? '';
    _amount.text = item == null ? '' : item.amount.toStringAsFixed(2);
    _description.text = item?.description ?? '';
    _category = item?.category;
    _frequency = item?.frequency ?? 'Monthly';
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
                colorScheme:
                    const ColorScheme.light(primary: Color(0xFF2F7E79))),
            child: child!));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    setState(() => _saving = true);
    try {
      final item = TransactionItem(
          id: widget.item?.id,
          title: _title.text.trim(),
          amount: double.parse(_amount.text.trim()),
          category: _category!,
          date: _date,
          description: _description.text.trim(),
          type: _isCredit ? 'credit' : 'expense',
          frequency: _frequency);
      if (widget.item == null) {
        await ExpenseDatabase.instance.insert(item);
      } else {
        await ExpenseDatabase.instance.update(item);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Unable to save. Please check your details and try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final heading =
        _isCredit ? 'Credit' : (isEdit ? 'Edit Transaction' : 'Add Expense');
    return Scaffold(
        backgroundColor: const Color(0xFFF7F8F8),
        appBar: AppBar(
            title: Text(heading, style: const TextStyle(fontSize: 14)),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: Form(
                key: _formKey,
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _label('Transaction Type'),
                      DropdownButtonFormField<String>(
                          value: _isCredit ? 'Credit' : 'Expense',
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(
                                value: 'Expense', child: Text('Expense')),
                            DropdownMenuItem(
                                value: 'Credit', child: Text('Credit'))
                          ],
                          onChanged: isEdit
                              ? null
                              : (v) {
                                  if (v != null && (v == 'Credit') != _isCredit)
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                TransactionFormScreen(
                                                    type: v.toLowerCase())));
                                }),
                      const SizedBox(height: 13),
                      _label(_isCredit ? 'Credit Title' : 'Title'),
                      TextFormField(
                          controller: _title,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              const InputDecoration(hintText: 'Enter title'),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Title is required'
                              : null),
                      const SizedBox(height: 13),
                      _label('Category'),
                      DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                              hintText: 'Select category'),
                          items: _categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                          validator: (v) =>
                              v == null ? 'Category is required' : null),
                      const SizedBox(height: 13),
                      _label('Amount'),
                      TextFormField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              hintText: '0.00', prefixText: '₹ '),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').trim());
                            if (n == null || !n.isFinite)
                              return 'Enter a valid amount';
                            if (n <= 0)
                              return 'Amount must be greater than zero';
                            return null;
                          }),
                      const SizedBox(height: 13),
                      _label('Date'),
                      InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                      Icons.calendar_month_outlined,
                                      size: 18)),
                              child: Text(
                                  DateFormat('dd MMM yyyy').format(_date),
                                  style: const TextStyle(fontSize: 12)))),
                      if (_isCredit) ...[
                        const SizedBox(height: 13),
                        _label('Bill Type / Frequency'),
                        DropdownButtonFormField<String>(
                            value: _frequency,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Weekly', child: Text('Weekly')),
                              DropdownMenuItem(
                                  value: 'Monthly', child: Text('Monthly')),
                              DropdownMenuItem(
                                  value: 'Yearly', child: Text('Yearly'))
                            ],
                            onChanged: (v) =>
                                setState(() => _frequency = v ?? 'Monthly'))
                      ],
                      const SizedBox(height: 13),
                      _label('Description (Optional)'),
                      TextFormField(
                          controller: _description,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              const InputDecoration(hintText: 'Add a note')),
                      const SizedBox(height: 24),
                      PrimaryButton(
                          label: _saving ? 'Saving...' : 'Save',
                          onPressed: _saving ? () {} : _save),
                    ]))));
  }

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7373),
              fontWeight: FontWeight.w500)));
}
