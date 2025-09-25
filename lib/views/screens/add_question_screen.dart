import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qController = TextEditingController();
  final List<TextEditingController> _choiceControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int? _answerIndex;
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _answerIndex == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final supabase = Supabase.instance.client;
    try {
      final choices = _choiceControllers.map((c) => c.text).toList();
      await supabase.from('qus').insert({
        'q': _qController.text,
        'c': choices,
        'a': _answerIndex,
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF1976D2);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
        backgroundColor: themeColor,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF6F6FB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create a new question',
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _qController,
                        decoration: InputDecoration(
                          labelText: 'Question',
                          filled: true,
                          fillColor: const Color(0xFFF3F1FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 18),
                      ...List.generate(
                        _choiceControllers.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: const Color(0xFFF3F1FA),
                            child: RadioListTile<int>(
                              value: i,
                              groupValue: _answerIndex,
                              activeColor: themeColor,
                              onChanged: (val) =>
                                  setState(() => _answerIndex = val),
                              title: TextFormField(
                                controller: _choiceControllers[i],
                                decoration: InputDecoration(
                                  labelText: 'Choice ${i + 1}',
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 15),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _submit,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Question'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
