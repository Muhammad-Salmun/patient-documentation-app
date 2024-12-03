import 'package:flutter/material.dart';
import 'package:surgery_doc/components/textfeild.dart';

class AnxietyQuestionnairePage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AnxietyQuestionnairePage({Key? key, required this.patient})
      : super(key: key);

  @override
  _AnxietyQuestionnairePageState createState() =>
      _AnxietyQuestionnairePageState();
}

class _AnxietyQuestionnairePageState extends State<AnxietyQuestionnairePage> {
  // Store the selected values for each question
  final List<int> _answers = List.filled(14, 0); // 14 questions

  final TextEditingController _anxietyScoreController = TextEditingController();

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

  // Function to handle form submission
  void _submitForm() {
    int totalScore = _answers.reduce((value, element) => value + element);

    // Save the total score to the patient data (could be stored locally or in Firebase)
    widget.patient['anxietyScoreBeforeSurgery'] = totalScore;

    // Return to the previous page (or move to the next stage)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anxiety Questionnaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Please rate the following questions based on the patient’s symptoms:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _questions[index],
                        style: TextStyle(fontSize: 16),
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
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            CustomTextFeild(
                controller: _anxietyScoreController,
                hintText: 'Enter Anxiety Score (0-56)'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
