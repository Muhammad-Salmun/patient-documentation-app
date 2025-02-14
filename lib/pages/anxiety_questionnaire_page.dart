import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnxietyQuestionnairePage extends StatefulWidget {
  final String patientId; // Firestore document ID

  const AnxietyQuestionnairePage({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<AnxietyQuestionnairePage> createState() =>
      _AnxietyQuestionnairePageState();
}

class _AnxietyQuestionnairePageState extends State<AnxietyQuestionnairePage> {
  // Store the selected values for each question
  final List<int> _answers = List.filled(14, 0); // 14 questions
  int? _currentStage;
  bool _isLoading = true;

  // List of questions
  final List<String> _questions = [
    "1. Anxious mood: Worries, anticipation of the worst, fearful anticipation, irritability.",
    "2. Tension: Feelings of tension, fatigability, startle response, moved to tears easily.",
    "3. Fears: Of dark, of strangers, of being left alone, of animals, of traffic.",
    "4. Insomnia: Difficulty in falling asleep, broken sleep, unsatisfying sleep, nightmares.",
    "5. Intellectual: Difficulty in concentration, poor memory.",
    "6. Depressed mood: Loss of interest, lack of pleasure in hobbies.",
    "7. Somatic (muscular): Pains and aches, twitching, stiffness.",
    "8. Somatic (sensory): Tinnitus, blurring of vision, hot and cold flushes.",
    "9. Cardiovascular symptoms: Tachycardia, palpitations, pain in chest.",
    "10. Respiratory symptoms: Pressure or constriction in chest, choking feelings.",
    "11. Gastrointestinal symptoms: Difficulty in swallowing, abdominal pain, nausea.",
    "12. Genitourinary symptoms: Frequency of micturition, urgency, loss of libido.",
    "13. Autonomic symptoms: Dry mouth, flushing, pallor, tendency to sweat.",
    "14. Behavior at interview: Fidgeting, restlessness, tremor of hands."
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentStage(); // Fetch the current stage from Firestore
  }

  // Fetch the current stage from Firestore
  Future<void> _fetchCurrentStage() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          _currentStage = data?['currentStage'] ?? 1; // Default to Stage 1
        });
      }
    } catch (e) {
      // print('Error fetching patient data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch patient data.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the anxiety score in Firestore
  Future<void> _saveAnxietyScore() async {
    try {
      final totalScore = _answers.reduce((value, element) => value + element);
      final fieldToUpdate = _currentStage == 1
          ? 'anxietyScoreBeforeSurgery'
          : 'anxietyScoreAfterSurgery';

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({
        fieldToUpdate: totalScore,
        'currentStage': _currentStage! + 1, // Move to the next stage
      });

      // Navigate back or show success message
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // print('Error saving anxiety score: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save score. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Anxiety Questionnaire'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anxiety Questionnaire (Stage $_currentStage)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Please rate the following questions based on the patient’s symptoms:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _questions[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (score) {
                          return Row(
                            children: <Widget>[
                              Radio<int>(
                                value: score,
                                groupValue: _answers[index],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[index] = value!;
                                  });
                                },
                              ),
                              Text('$score'),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            Text(
              'Calculated Anxiety Score: ${_answers.reduce((a, b) => a + b)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAnxietyScore,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
