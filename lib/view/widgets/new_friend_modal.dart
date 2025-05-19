import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewFriendModal extends StatelessWidget {
  /* Elli: Proof-of-concept for a new friend dialog. Keeping it simple w/ a
     StatelessWidget for the purpose of the exercise. */
  final String taskTitle;
  final int taskNumCompleted;
  final VoidCallback onClose;

  const NewFriendModal({
    super.key,
    required this.taskTitle,
    required this.taskNumCompleted,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "New Friend Unlocked!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              "You've completed $taskTitle $taskNumCompleted times!",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              "💜 This friend noticed your consistency and decided to join you on your self-care journey 💜",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            SvgPicture.asset(
              'lib/assets/friends/sheep.svg',
              height: 120,
              width: 120,
              placeholderBuilder: (context) => const Icon(
                Icons.pets,
                size: 120,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                text: "Say Hello!",
                onPressed: onClose,
                alignment: MainAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
