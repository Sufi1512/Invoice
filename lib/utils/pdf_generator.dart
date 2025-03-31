import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:invoice_generator/models/invoice.dart';
import 'package:intl/intl.dart';

class PDFGenerator {
  static Future<void> generateInvoice(Invoice invoice) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy');

    // Load the Noto Sans font
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load logo if available
    pw.MemoryImage? logoImage;
    if (invoice.logoPath != null) {
      final file = File(invoice.logoPath!);
      final imageBytes = await file.readAsBytes();
      logoImage = pw.MemoryImage(imageBytes);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header:
            (context) => pw.Container(
              padding: pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                    )
                  else
                    pw.Text(
                      invoice.businessName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                        font: ttf,
                      ),
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                          font: ttf,
                        ),
                      ),
                      pw.Text(
                        '#${invoice.invoiceNumber}',
                        style: pw.TextStyle(
                          color: PdfColors.grey600,
                          font: ttf,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        build:
            (pw.Context context) => [
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        invoice.clientName,
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        invoice.clientContact,
                        style: pw.TextStyle(font: ttf),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${dateFormat.format(invoice.issueDate)}',
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        'Due: ${dateFormat.format(invoice.dueDate)}',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableHeader('Description', ttf),
                      _tableHeader('Qty', ttf),
                      _tableHeader('Price', ttf),
                      _tableHeader('Total', ttf),
                    ],
                  ),
                  ...invoice.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.description,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.quantity.toString(),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '₹${item.total.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _totalRow('Subtotal:', _calculateSubtotal(invoice), ttf),
                      _totalRow(
                        'Tax (${(invoice.taxRate * 100).toStringAsFixed(0)}%):',
                        _calculateTax(invoice),
                        ttf,
                      ),
                      _totalRow(
                        'Discount (${(invoice.discount * 100).toStringAsFixed(0)}%):',
                        _calculateDiscount(invoice),
                        ttf,
                      ),
                      pw.Divider(color: PdfColors.grey400),
                      _totalRow(
                        'Total:',
                        _calculateTotal(invoice),
                        ttf,
                        bold: true,
                        large: true,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                  font: ttf,
                ),
              ),
            ],
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.center,
              padding: pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                invoice.businessName + ' | ' + invoice.businessContact,
                style: pw.TextStyle(
                  color: PdfColors.grey500,
                  fontSize: 10,
                  font: ttf,
                ),
              ),
            ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_${invoice.invoiceNumber}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  static pw.Widget _tableHeader(String text, pw.Font font) => pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
      textAlign: pw.TextAlign.right,
    ),
  );

  static pw.Widget _totalRow(
    String label,
    double amount,
    pw.Font font, {
    bool bold = false,
    bool large = false,
  }) => pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : null,
            fontSize: large ? 16 : 12,
            font: font,
          ),
        ),
        pw.Text(
          '₹${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : null,
            fontSize: large ? 16 : 12,
            font: font,
          ),
        ),
      ],
    ),
  );

  static double _calculateSubtotal(Invoice invoice) =>
      invoice.items.fold(0, (sum, item) => sum + item.total);

  static double _calculateTax(Invoice invoice) =>
      _calculateSubtotal(invoice) * invoice.taxRate;

  static double _calculateDiscount(Invoice invoice) =>
      _calculateSubtotal(invoice) * invoice.discount;

  static double _calculateTotal(Invoice invoice) =>
      _calculateSubtotal(invoice) +
      _calculateTax(invoice) -
      _calculateDiscount(invoice);
}
