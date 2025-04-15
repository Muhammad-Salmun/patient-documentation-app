import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnxietyQuestionnairePage extends StatefulWidget {
  final String patientId;

  const AnxietyQuestionnairePage({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<AnxietyQuestionnairePage> createState() =>
      _AnxietyQuestionnairePageState();
}

class _AnxietyQuestionnairePageState extends State<AnxietyQuestionnairePage> {
  final List<int?> _answers = List.filled(14, null);
  int? _currentStage;
  bool _isLoading = true;

  final List<String> _questions = [
    "Anxious mood: Worries, anticipation of the worst, fearful anticipation, irritability.",
    "Tension: Feelings of tension, fatigability, startle response, moved to tears easily.",
    "Fears: Of dark, of strangers, of being left alone, of animals, of traffic.",
    "Insomnia: Difficulty in falling asleep, broken sleep, unsatisfying sleep, nightmares.",
    "Intellectual: Difficulty in concentration, poor memory.",
    "Depressed mood: Loss of interest, lack of pleasure in hobbies.",
    "Somatic (muscular): Pains and aches, twitching, stiffness.",
    "Somatic (sensory): Tinnitus, blurring of vision, hot and cold flushes.",
    "Cardiovascular: Tachycardia, palpitations, pain in chest.",
    "Respiratory: Pressure or constriction in chest, choking feelings.",
    "Gastrointestinal: Difficulty swallowing, abdominal pain, nausea.",
    "Genitourinary: Frequency of micturition, urgency, loss of libido.",
    "Autonomic: Dry mouth, flushing, pallor, tendency to sweat.",
    "Behavior at interview: Fidgeting, restlessness, tremor of hands."
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentStage();
  }

  Future<void> _fetchCurrentStage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _currentStage = doc['currentStage'] ?? 1;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching patient data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAnxietyScore() async {
    final totalScore = _answers.fold(0, (sum, value) => sum + (value ?? 0));
    final fieldToUpdate = _currentStage == 1
        ? 'anxietyScoreBeforeSurgery'
        : 'anxietyScoreAfterSurgery';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Score?'),
        content: Text('Final anxiety score: $totalScore\nAre you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Submit")),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({
        fieldToUpdate: totalScore,
        'currentStage': _currentStage! + 1,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
        );
      }
    }
  }

  bool get _allAnswered => !_answers.contains(null);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Anxiety Questionnaire')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anxiety Questionnaire (Stage $_currentStage)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _answers.whereType<int>().length / _questions.length,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${_questions[index]}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          ...List.generate(5, (score) {
                            return RadioListTile<int>(
                              title: Text(score.toString()),
                              value: score,
                              groupValue: _answers[index],
                              onChanged: (value) {
                                setState(() {
                                  _answers[index] = value;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Score: ${_answers.whereType<int>().fold(0, (sum, value) => sum + value)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _allAnswered ? _saveAnxietyScore : null,
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Submit', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
