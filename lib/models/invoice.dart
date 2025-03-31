class Invoice {
  final String businessName;
  final String businessContact;
  final String clientName;
  final String clientContact;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double taxRate;
  final double discount;
  final String? logoPath;

  Invoice({
    required this.businessName,
    required this.businessContact,
    required this.clientName,
    required this.clientContact,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    this.taxRate = 0.0,
    this.discount = 0.0,
    this.logoPath,
  });
}

class InvoiceItem {
  final String description;
  final double quantity;
  final double price;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}