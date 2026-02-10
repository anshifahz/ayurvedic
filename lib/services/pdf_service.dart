import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateRegistrationPdf({
    required String name,
    required String phone,
    required String address,
    required String branchName,
    required String date,
    required String time,
    required List<Map<String, dynamic>> treatments,
    required double total,
    required double advance,
    required double balance,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    // Load Logo
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background Logo
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(logoImage, width: 400),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(logoImage, width: 60, height: 60),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'KUMARAKOM',
                            style: pw.TextStyle(font: fontBold, fontSize: 14),
                          ),
                          pw.Text(
                            'Choopunkal P.O, Kumarakom, Kottayam, Kerala - 686563',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Text(
                            'e-mail: unknown@gmail.com',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Text(
                            'Mob: +91 9876543210 | +91 9786653250',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Text(
                            'GST NO: 32AABCU8810R1ZN',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 20),

                  // Patient Details Section
                  pw.Text(
                    'Patient Details',
                    style: pw.TextStyle(
                      font: fontBold,
                      color: PdfColors.green700,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildRow('Name', name, fontBold, font),
                            _buildRow('Address', address, fontBold, font),
                            _buildRow('WhatsApp Number', phone, fontBold, font),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 40),
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildRow(
                              'Booked On',
                              DateFormat(
                                'dd/MM/yyyy | hh:mm a',
                              ).format(DateTime.now()),
                              fontBold,
                              font,
                            ),
                            _buildRow('Treatment Date', date, fontBold, font),
                            _buildRow('Treatment Time', time, fontBold, font),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  // Treatment Table Section
                  pw.Text(
                    'Treatment',
                    style: pw.TextStyle(
                      font: fontBold,
                      color: PdfColors.green700,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text(
                            '',
                            style: pw.TextStyle(font: fontBold),
                          ), // Hidden but for alignment
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'Price',
                              style: pw.TextStyle(
                                font: fontBold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'Male',
                              style: pw.TextStyle(
                                font: fontBold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'Female',
                              style: pw.TextStyle(
                                font: fontBold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'Total',
                              style: pw.TextStyle(
                                font: fontBold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...treatments.map((t) {
                        final double price =
                            double.tryParse(t['price']?.toString() ?? '0') ?? 0;
                        final int m = t['male'] ?? 0;
                        final int f = t['female'] ?? 0;
                        final double rowTotal = price * (m + f);
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Text(
                                t['name'] ?? '',
                                style: pw.TextStyle(font: font, fontSize: 11),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Text(
                                '₹${price.toInt()}',
                                style: pw.TextStyle(font: font, fontSize: 11),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Text(
                                m.toString(),
                                style: pw.TextStyle(font: font, fontSize: 11),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Text(
                                f.toString(),
                                style: pw.TextStyle(font: font, fontSize: 11),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Text(
                                '₹${rowTotal.toInt()}',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 10),

                  // Totals Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildTotalRow(
                            'Total Amount',
                            '₹${total.toInt()}',
                            fontBold,
                            font,
                          ),
                          _buildTotalRow(
                            'Discount',
                            '₹0',
                            fontBold,
                            font,
                          ), // Static or from value
                          _buildTotalRow(
                            'Advance',
                            '₹${advance.toInt()}',
                            fontBold,
                            font,
                          ),
                          pw.SizedBox(height: 5),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Divider(color: PdfColors.grey300),
                          ),
                          pw.SizedBox(height: 5),
                          _buildTotalRow(
                            'Balance',
                            '₹${balance.toInt()}',
                            fontBold,
                            font,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Footer Section
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Thank you for choosing us',
                          style: pw.TextStyle(
                            font: fontBold,
                            color: PdfColors.green700,
                            fontSize: 16,
                          ),
                        ),
                        pw.Text(
                          'Your well-being is our commitment, and we\'re honored',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          'you\'ve entrusted us with your health journey.',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        // Signature placeholder - squiggle
                        pw.Container(
                          height: 40,
                          width: 100,
                          child: pw.Center(
                            child: pw.Text(
                              'lee',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 24,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.Center(
                    child: pw.Text(
                      '"Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment."',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font font, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontBold, fontSize: 12),
            ),
          ),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(font: fontBold, fontSize: isTotal ? 14 : 12),
            ),
          ),
        ],
      ),
    );
  }
}
