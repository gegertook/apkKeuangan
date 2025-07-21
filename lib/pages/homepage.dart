import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String _jenis = 'pemasukan';
  String _kategori = 'Makanan';

  bool _isLoading = false;
  List<Map<String, dynamic>> _transaksiList = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transaksi.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transaksi(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            type TEXT,
            category TEXT,
            name TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
    await _loadTransaksi();
  }

  Future<void> _loadTransaksi() async {
    if (_database == null) return;
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    final List<Map<String, dynamic>> transaksi = await _database!.query(
      'transaksi',
      where: 'user_id = ?',
      whereArgs: [user?.id],
      orderBy: 'date DESC',
    );

    setState(() {
      _transaksiList = transaksi;
      _isLoading = false;
    });
  }

  Future<void> _simpanTransaksi() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User belum login')));
      return;
    }

    final nama = _namaController.text.trim();
    final jumlah = num.tryParse(_jumlahController.text.trim()) ?? 0;

    if (nama.isEmpty || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan jumlah wajib diisi')),
      );
      return;
    }

    await _database?.insert('transaksi', {
      'user_id': user.id,
      'type': _jenis,
      'category': _kategori,
      'name': nama,
      'amount': jumlah,
      'date': DateTime.now().toIso8601String(),
    });

    _namaController.clear();
    _jumlahController.clear();
    await _loadTransaksi();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keuanganku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Tambah Transaksi', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _jenis,
                  items: const [
                    DropdownMenuItem(
                      value: 'pemasukan',
                      child: Text('pemasukan'),
                    ),
                    DropdownMenuItem(
                      value: 'pengeluaran',
                      child: Text('pengeluaran'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _jenis = value!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _kategori,
                  items: const [
                    DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                    DropdownMenuItem(
                      value: 'Transportasi',
                      child: Text('Transportasi'),
                    ),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _kategori = value!;
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Transaksi'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _simpanTransaksi,
              child: const Text('Simpan'),
            ),
            const Divider(),
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18)),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children:
                      _transaksiList.map((item) {
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text(
                            '${item['category']} - ${item['type']}',
                          ),
                          trailing: Text('${item['amount']}'),
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }
}
