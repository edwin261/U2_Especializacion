import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auth_session.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    required this.apiService,
    required this.session,
    required this.onProductCountChanged,
    super.key,
  });

  final ApiService apiService;
  final AuthSession session;
  final Future<void> Function(int count) onProductCountChanged;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 2,
  );

  List<Product> _products = [];
  int? _editingId;
  bool _loading = false;
  bool _saving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final products = await widget.apiService.getProducts(widget.session.token);
      final count = await widget.apiService.getMyProductCount(widget.session.token);

      if (!mounted) return;
      setState(() {
        _products = products;
      });
      await widget.onProductCountChanged(count);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      if (_editingId == null) {
        await widget.apiService.createProduct(
          token: widget.session.token,
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
        );
      } else {
        await widget.apiService.updateProduct(
          token: widget.session.token,
          productId: _editingId!,
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
        );
      }

      _resetForm();
      await _loadProducts();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    setState(() {
      _error = '';
    });

    try {
      await widget.apiService.deleteProduct(
        token: widget.session.token,
        productId: product.id,
      );
      await _loadProducts();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    }
  }

  void _editProduct(Product product) {
    setState(() {
      _editingId = product.id;
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
    });
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProductsHeader(total: _products.length),
          const SizedBox(height: 16),
          _buildForm(),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ErrorBox(message: _error),
          ],
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_products.isEmpty)
            const _EmptyProducts()
          else
            _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final nameField = TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre';
                  }
                  return null;
                },
              );
              final priceField = TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null) return 'Ingrese un precio valido';
                  if (price < 0) return 'El precio no puede ser negativo';
                  return null;
                },
              );
              final submitButton = FilledButton(
                onPressed: _saving ? null : _saveProduct,
                child: Text(_editingId == null ? 'Crear' : 'Actualizar'),
              );
              final cancelButton = _editingId == null
                  ? null
                  : OutlinedButton(
                      onPressed: _saving ? null : _resetForm,
                      child: const Text('Cancelar'),
                    );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    nameField,
                    const SizedBox(height: 10),
                    priceField,
                    const SizedBox(height: 10),
                    submitButton,
                    if (cancelButton != null) ...[
                      const SizedBox(height: 10),
                      cancelButton,
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: nameField,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: priceField,
                  ),
                  const SizedBox(width: 10),
                  submitButton,
                  if (cancelButton != null) ...[
                    const SizedBox(width: 10),
                    cancelButton,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Precio')),
            DataColumn(label: Text('Creador')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: _products.map((product) {
            final canManage = product.createdBy == widget.session.userId;

            return DataRow(
              cells: [
                DataCell(Text(product.name)),
                DataCell(Text(_currencyFormat.format(product.price))),
                DataCell(Text(product.creatorName)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: canManage ? () => _editProduct(product) : null,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: canManage ? () => _deleteProduct(product) : null,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Productos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xff2c3e50),
                fontWeight: FontWeight.w700,
              ),
        ),
        Text('$total registrados'),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffffebee),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xffc0392b)),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Text('No hay productos registrados.'),
      ),
    );
  }
}
