import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_model.dart';
import '../widgets/product_form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    final response =
        await http.get(Uri.parse('https://api.restful-api.dev/objects'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        products = data.map((json) => Product.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  void showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${product.id}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Nombre: ${product.name}'),
            SizedBox(height: 8),
            Text('Detalles: ${product.data.toString()}'),
          ],
        ),
      ),
    );
  }

  void openCreateForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductForm(
        onSubmit: (name, data) async {
          final response = await http.post(
            Uri.parse('https://api.restful-api.dev/objects'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({"name": name, "data": data}),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto creado exitosamente')),
            );
            fetchProducts();
          }
        },
      ),
    );
  }

  void openEditForm(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductForm(
        product: product,
        onSubmit: (name, data) async {
          final response = await http.put(
            Uri.parse('https://api.restful-api.dev/objects/${product.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({"name": name, "data": data}),
          );
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto actualizado')),
            );
            fetchProducts();
          }
        },
      ),
    );
  }

  void deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('https://api.restful-api.dev/objects/$id'),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado')),
      );
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(product.name),
                    onTap: () => showProductDetails(product),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => openEditForm(product),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteProduct(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateForm,
        child: Icon(Icons.add),
      ),
    );
  }
}