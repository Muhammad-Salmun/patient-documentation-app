import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QualityScoreQuestionnairePage extends StatefulWidget {
  final String patientId;

  const QualityScoreQuestionnairePage({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<QualityScoreQuestionnairePage> createState() =>
      _QualityOfLifePageState();
}

class _QualityOfLifePageState extends State<QualityScoreQuestionnairePage> {
  final Map<String, int> _answers = {
    'Mobility': 1,
    'Self-Care': 1,
    'Usual Activities': 1,
    'Pain/Discomfort': 1,
    'Anxiety/Depression': 1,
  };

  double _vasScore = 0; // Initial VAS score

  // Save the quality of life score to Firestore
  Future<void> _saveQualityOfLifeData() async {
    try {
      final finalScore = _vasScore;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({
        'qualityOfLifeScore': finalScore.toInt(),
        'currentStage': 4, // Move to final stage
      });
      if (!mounted) return;
      Navigator.pop(context); // Return to the previous page
    } catch (e) {
      // print('Error saving quality of life data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save data. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality of Life Questionnaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Please indicate your health in each of the following areas:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ..._answers.keys.map((dimension) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dimension,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return Row(
                        children: [
                          Radio<int>(
                            value: index + 1,
                            groupValue: _answers[dimension],
                            onChanged: (value) {
                              setState(() {
                                _answers[dimension] = value!;
                              });
                            },
                          ),
                          Text('${index + 1}'),
                        ],
                      );
                    }),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text(
              'Overall Health (VAS):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQualityOfLifeData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
