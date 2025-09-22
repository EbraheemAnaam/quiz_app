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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Question')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _qController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(
                _choiceControllers.length,
                (i) => RadioListTile<int>(
                  value: i,
                  groupValue: _answerIndex,
                  onChanged: (val) => setState(() => _answerIndex = val),
                  title: TextFormField(
                    controller: _choiceControllers[i],
                    decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Add Question'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
