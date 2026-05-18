import 'package:flutter/material.dart';
import '../widgets/glitch_text.dart';
import '../services/ai_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  String? imageUrl;
  String? result;
  bool isMuted = false;

  void handleSubmit() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    try {
      final aiResponse = await AIService.generateCreepyResponse(input);
      final expandedImagePrompt = await AIService.expandPromptForImage(input);
      print("🧠 Expanded image prompt: $expandedImagePrompt");
      final dreamImage = await AIService.generateDreamImage(expandedImagePrompt);

      

      setState(() {
        imageUrl = dreamImage;
        result = aiResponse;
        
      });
    } catch (e) {
      setState(() {
        result = "Something went wrong. The dream won't speak right now...";
      });
      print("ERROR during submit: $e");
    }
  }
  void speakResult() async {
    if (result == null || result!.isEmpty) return;

    if (isMuted) {
      print("Muted — not speaking.");
      return;
    }

    await flutterTts.stop();

    // iOS-specific audio fix
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth
      ],
    );

    await flutterTts.setVoice({
      "name": "en-us-x-sfg#male_ghost",
      "locale": "en-US",
    });
    await flutterTts.setPitch(0.7);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(result!);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GlitchText(text: "What do you fear?"),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your fear or dream...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black54,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isMuted ? "🔇 Muted" : "🔊 Whispering",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: isMuted,
                    onChanged: (val) {
                      setState(() {
                        isMuted = val;
                        print("Mute toggled: $isMuted");

                        if (isMuted) {
                          flutterTts.stop(); // Stop whisper immediately if speaking
                          print("Stopped TTS due to live mute.");
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Submit"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: speakResult,
                icon: const Icon(Icons.volume_up),
                label: const Text("Whisper It"),
              ),
              const SizedBox(height: 30),
              if (result != null)
                Column(
                  children: [
                    Text(
                      result!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (imageUrl != null) ...[
                      const Text(
                        "Dream Fragment:",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imageUrl!),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
