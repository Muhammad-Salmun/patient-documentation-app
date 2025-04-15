import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QualityScoreQuestionnairePage extends StatefulWidget {
  final String patientId;

  const QualityScoreQuestionnairePage({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<QualityScoreQuestionnairePage> createState() =>
      _QualityScoreQuestionnairePageState();
}

class _QualityScoreQuestionnairePageState
    extends State<QualityScoreQuestionnairePage> {
  final Map<String, int?> _answers = {
    'Mobility': null,
    'Self-Care': null,
    'Usual Activities': null,
    'Pain/Discomfort': null,
    'Anxiety/Depression': null,
  };

  double _vasScore = 0;
  bool _isSubmitting = false;

  bool get _allAnswered => !_answers.values.contains(null) && _vasScore > 0;

  double get _progress =>
      (_answers.values.whereType<int>().length + (_vasScore > 0 ? 1 : 0)) / 6;

  Future<void> _saveQualityOfLifeData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Submit Responses?"),
        content: Text(
            "VAS Score: ${_vasScore.toInt()}\nAre you sure you want to submit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({
        'qualityOfLifeScore': _vasScore.toInt(),
        'currentStage': 4,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save data.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quality of Life Questionnaire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Rate the patient’s health in the following dimensions:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ..._answers.keys.map((dimension) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dimension,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...List.generate(5, (i) {
                              return RadioListTile<int>(
                                title: Text('${i + 1}'),
                                value: i + 1,
                                groupValue: _answers[dimension],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[dimension] = value;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Overall Health (VAS)",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: _vasScore,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '${_vasScore.toInt()}',
                            onChanged: (value) {
                              setState(() {
                                _vasScore = value;
                              });
                            },
                          ),
                          Text(
                            'VAS Score: ${_vasScore.toInt()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
              onPressed: _allAnswered && !_isSubmitting
                  ? _saveQualityOfLifeData
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
