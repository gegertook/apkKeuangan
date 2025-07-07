import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedType = 'pemasukan';
  String _selectedCategory = 'Umum';

  final List<String> _categories = [
    'Umum',
    'Makanan',
    'Transportasi',
    'Gaji',
    'Lainnya',
  ];

  Future<void> _addTransaction() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    try {
      await Supabase.instance.client.from('transactions').insert({
        'user_id': userId,
        'type': _selectedType,
        'category': _selectedCategory,
        'name': name,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
      });

      _nameController.clear();
      _amountController.clear();

      setState(() {}); // refresh tampilan
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan transaksi: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getTransactions() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final res = await Supabase.instance.client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuanganku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tambah Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    items:
                        ['pemasukan', 'pengeluaran']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items:
                        _categories
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Transaksi'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getTransactions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Text('Belum ada transaksi');
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final tx = data[index];
                      return ListTile(
                        leading: Icon(
                          tx['type'] == 'pemasukan'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                        ),
                        title: Text(tx['name']),
                        subtitle: Text(
                          '${tx['category']} • ${DateFormat.yMd().add_Hm().format(DateTime.parse(tx['date']))}',
                        ),
                        trailing: Text(
                          'Rp ${tx['amount']}',
                          style: TextStyle(
                            color:
                                tx['type'] == 'pemasukan'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
