import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'models/branch_model.dart';
import 'models/treatment_model.dart';
import 'services/pdf_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _balanceAmountController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedLocation;
  Branch? _selectedBranch;
  String? _selectedHour;
  String? _selectedMinute;
  String _paymentOption = 'Cash';

  // List to track added treatments
  final List<Map<String, dynamic>> _selectedTreatments = [];

  final primaryColor = const Color(0xFF006633);
  final backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = context.read<DataProvider>();
      dataProvider.fetchBranches();
      dataProvider.fetchTreatments();
    });
  }

  void _calculateBalance() {
    double total = double.tryParse(_totalAmountController.text) ?? 0;
    double advance = double.tryParse(_advanceAmountController.text) ?? 0;
    setState(() {
      _balanceAmountController.text = (total - advance).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Register',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: data.isLoading && data.branches.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Name'),
                        _buildTextField(
                          _nameController,
                          'Enter your full name',
                        ),

                        _buildLabel('Whatsapp Number'),
                        _buildTextField(
                          _whatsappController,
                          'Enter your Whatsapp number',
                          keyboardType: TextInputType.phone,
                        ),

                        _buildLabel('Address'),
                        _buildTextField(
                          _addressController,
                          'Enter your full address',
                        ),

                        _buildLabel('Location'),
                        _buildDropdown(
                          ['Kochi', 'Calicut', 'Trivandrum'],
                          'Choose your location',
                          _selectedLocation,
                          (val) => setState(() => _selectedLocation = val),
                        ),

                        _buildLabel('Branch'),
                        _buildBranchDropdown(
                          data.branches,
                          'Select the branch',
                          _selectedBranch,
                          (val) => setState(() => _selectedBranch = val),
                        ),

                        const SizedBox(height: 16),
                        _buildLabel('Treatments'),

                        // Dynamic Treatment List
                        ..._selectedTreatments.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var treatment = entry.value;
                          return _buildTreatmentCard(idx, treatment);
                        }),

                        const SizedBox(height: 12),

                        // Add Treatments Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              _showAddTreatmentDialog(context, data.treatments);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8E6C9),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '+ Add Treatments',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildLabel('Total Amount'),
                        _buildTextField(
                          _totalAmountController,
                          '',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateBalance(),
                        ),

                        _buildLabel('Discount Amount'),
                        _buildTextField(
                          _discountAmountController,
                          '',
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 12),
                        _buildLabel('Payment Option'),
                        Row(
                          children: [
                            _buildRadio('Cash'),
                            const SizedBox(width: 16),
                            _buildRadio('Card'),
                            const SizedBox(width: 16),
                            _buildRadio('UPI'),
                          ],
                        ),

                        const SizedBox(height: 12),
                        _buildLabel('Advance Amount'),
                        _buildTextField(
                          _advanceAmountController,
                          '',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateBalance(),
                        ),

                        _buildLabel('Balance Amount'),
                        _buildTextField(
                          _balanceAmountController,
                          '',
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),

                        _buildLabel('Treatment Date'),
                        _buildDatePicker(),

                        _buildLabel('Treatment Time'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                List.generate(
                                  24,
                                  (index) => index.toString().padLeft(2, '0'),
                                ),
                                'Hour',
                                _selectedHour,
                                (val) => setState(() => _selectedHour = val),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                List.generate(
                                  60,
                                  (index) => index.toString().padLeft(2, '0'),
                                ),
                                'Minutes',
                                _selectedMinute,
                                (val) => setState(() => _selectedMinute = val),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: data.isLoading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: data.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null) {
      _showError('Please select a branch');
      return;
    }
    if (_selectedTreatments.isEmpty) {
      _showError('Please add at least one treatment');
      return;
    }
    if (_dateController.text.isEmpty ||
        _selectedHour == null ||
        _selectedMinute == null) {
      _showError('Please select treatment date and time');
      return;
    }

    final dataProvider = context.read<DataProvider>();
    final success = await dataProvider.registerPatient(
      name: _nameController.text,
      whatsapp: _whatsappController.text,
      address: _addressController.text,
      branchId: _selectedBranch!.id,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
      discountAmount: double.tryParse(_discountAmountController.text) ?? 0,
      advanceAmount: double.tryParse(_advanceAmountController.text) ?? 0,
      balanceAmount: double.tryParse(_balanceAmountController.text) ?? 0,
      date: _dateController.text,
      hour: _selectedHour!,
      minute: _selectedMinute!,
      paymentOption: _paymentOption,
      treatments: _selectedTreatments,
    );

    if (success && mounted) {
      // Generate PDF with safety
      try {
        await PdfService.generateRegistrationPdf(
          name: _nameController.text,
          phone: _whatsappController.text,
          address: _addressController.text,
          branchName: _selectedBranch!.name,
          date: _dateController.text,
          time: '${_selectedHour!}:${_selectedMinute!}',
          treatments: _selectedTreatments,
          total: double.tryParse(_totalAmountController.text) ?? 0,
          advance: double.tryParse(_advanceAmountController.text) ?? 0,
          balance: double.tryParse(_balanceAmountController.text) ?? 0,
        );
      } catch (e) {
        print('PDF Generation Error: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Saved Successfully!')),
        );
        Navigator.of(context).pop();
      }
    } else if (mounted) {
      String errorMessage = dataProvider.error;
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      _showError(
        errorMessage.isNotEmpty ? errorMessage : 'Failed to save booking',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String hint,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBranchDropdown(
    List<Branch> branches,
    String hint,
    Branch? value,
    Function(Branch?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Branch>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
          items: branches.map((Branch branch) {
            return DropdownMenuItem<Branch>(
              value: branch,
              child: Text(branch.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Select Date',
          filled: true,
          fillColor: backgroundColor,
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              _dateController.text =
                  "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }

  Widget _buildRadio(String value) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Radio<String>(
            value: value,
            groupValue: _paymentOption,
            activeColor: primaryColor,
            onChanged: (val) {
              setState(() {
                _paymentOption = val!;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTreatmentCard(int index, Map<String, dynamic> treatment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  treatment['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedTreatments.removeAt(index);
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 24),
              _buildCountBadge('Male', treatment['male'].toString()),
              const SizedBox(width: 16),
              _buildCountBadge('Female', treatment['female'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, String count) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: primaryColor, fontSize: 13)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(count, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  void _showAddTreatmentDialog(
    BuildContext context,
    List<Treatment> treatments,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Treatment? selected;
        int maleCount = 0;
        int femaleCount = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Treatment',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Treatment>(
                          value: selected,
                          hint: Text(
                            'Choose preferred treatment',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: primaryColor,
                          ),
                          items: treatments.map((Treatment t) {
                            return DropdownMenuItem<Treatment>(
                              value: t,
                              child: Text(t.name),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selected = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Add Patients',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDialogCounter(
                      'Male',
                      maleCount,
                      () => setState(() {
                        if (maleCount > 0) maleCount--;
                      }),
                      () => setState(() => maleCount++),
                    ),
                    const SizedBox(height: 16),
                    _buildDialogCounter(
                      'Female',
                      femaleCount,
                      () => setState(() {
                        if (femaleCount > 0) femaleCount--;
                      }),
                      () => setState(() => femaleCount++),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selected == null) return;
                          if (maleCount == 0 && femaleCount == 0) return;

                          this.setState(() {
                            _selectedTreatments.add({
                              'treatment_id': selected!.id,
                              'name': selected!.name,
                              'male': maleCount,
                              'female': femaleCount,
                            });
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogCounter(
    String label,
    int count,
    VoidCallback onDecrement,
    VoidCallback onIncrement,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: onDecrement,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onIncrement,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
