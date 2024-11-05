import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/help.dart';
import '../../../../data/models/user.dart';

class HelpRequestForm extends StatefulWidget {
  final CustomUser currentUser;

  const HelpRequestForm({super.key, required this.currentUser});

  @override
  _HelpRequestFormState createState() => _HelpRequestFormState();
}

class _HelpRequestFormState extends State<HelpRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCase;
  String? _selectedPriority;
  bool _isLoading = false;

  final List<String> _caseOptions = [
    "Technical Issue",
    "Account Problem",
    "Feature Request",
    "Bug Report",
    "General Inquiry",
    "Other",
  ];

  final List<String> _priorityLevels = [
    "Low",
    "Medium",
    "High",
    "Urgent"
  ];

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.currentUser.email;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitHelpRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final helpRequest = Help(
        id: const Uuid().v4(),
        user: widget.currentUser,
        caseTitle: _selectedCase!,
        description: _descriptionController.text,
        email: _emailController.text,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
      );

      try {
        await helpRequest.saveToFirestore();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Help request submitted successfully".tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error submitting help request: ${e.toString()}".tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help Center".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                "Submit a Help Request".tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We're here to help! Please fill out the form below and we'll get back to you as soon as possible.".tr(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address".tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email address".tr();
                  }
                  if (!value.contains("@")) {
                    return "Please enter a valid email address".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Request Type".tr(),
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedCase,
                items: _caseOptions.map((String caseOption) {
                  return DropdownMenuItem(
                    value: caseOption,
                    child: Text(caseOption.tr()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCase = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a request type".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Priority Level".tr(),
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedPriority,
                items: _priorityLevels.map((String priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.tr()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a priority level".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description".tr(),
                  hintText: "Please provide details about your request...".tr(),
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description".tr();
                  }
                  if (value.length < 10) {
                    return "Please provide more details".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitHelpRequest,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24.0,
                        )
                      : Text(
                          "Submit Request".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}