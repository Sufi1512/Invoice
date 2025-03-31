import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:invoice_generator/models/invoice.dart';
import 'package:invoice_generator/utils/pdf_generator.dart';
import 'package:invoice_generator/widgets/custom_text_field.dart';

void main() {
  runApp(InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: InvoiceForm(),
    );
  }
}

class InvoiceForm extends StatefulWidget {
  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final List<InvoiceItem> _items = [];
  final businessNameController = TextEditingController();
  final businessContactController = TextEditingController();
  final clientNameController = TextEditingController();
  final clientContactController = TextEditingController();
  final taxController = TextEditingController(text: '0');
  final discountController = TextEditingController(text: '0');
  File? _logo;

  Future<void> _pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        final descController = TextEditingController();
        final qtyController = TextEditingController();
        final priceController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                ),
                CustomTextField(
                  controller: qtyController,
                  label: 'Quantity',
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  controller: priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.isNotEmpty &&
                    qtyController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    _items.add(
                      InvoiceItem(
                        description: descController.text,
                        quantity: double.parse(qtyController.text),
                        price: double.parse(priceController.text),
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _generateInvoice() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final invoice = Invoice(
        businessName: businessNameController.text,
        businessContact: businessContactController.text,
        clientName: clientNameController.text,
        clientContact: clientContactController.text,
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        items: _items,
        taxRate: double.parse(taxController.text) / 100,
        discount: double.parse(discountController.text) / 100,
        logoPath: _logo?.path,
      );
      PDFGenerator.generateInvoice(invoice);
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please add at least one item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invoice'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child:
                              _logo != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _logo!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: businessNameController,
                        label: 'Business Name',
                      ),
                      CustomTextField(
                        controller: businessContactController,
                        label: 'Business Contact',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Client Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: clientNameController,
                        label: 'Client Name',
                      ),
                      CustomTextField(
                        controller: clientContactController,
                        label: 'Client Contact',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: Icon(Icons.add),
                            label: Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (_items.isEmpty)
                        Center(
                          child: Text(
                            'No items added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ..._items
                          .map(
                            (item) => Dismissible(
                              key: Key(
                                item.description + item.total.toString(),
                              ),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed:
                                  (_) => setState(() => _items.remove(item)),
                              child: ListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                  'Qty: ${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                          .toList()
                          .animate(interval: 100.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.2),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: taxController,
                        label: 'Tax Rate (%)',
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        controller: discountController,
                        label: 'Discount (%)',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _generateInvoice,
                child: Text('Generate Invoice', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  minimumSize: Size(double.infinity, 60),
                ),
              ).animate().scale(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
