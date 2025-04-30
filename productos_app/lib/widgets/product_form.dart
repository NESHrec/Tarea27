import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(String name, Map<String, dynamic> data) onSubmit;

  const ProductForm({super.key, this.product, required this.onSubmit});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product != null ? widget.product!.name : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final Map<String, dynamic> data = {
        "color": "black",
        "category": "tech"
      }; // Puedes cambiar esto o hacerlo dinámico más adelante
      widget.onSubmit(name, data);
      Navigator.of(context).pop(); // Cierra el formulario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.product == null ? 'Crear' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}