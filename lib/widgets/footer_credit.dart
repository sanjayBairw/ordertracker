import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterCredit extends StatelessWidget {
  const FooterCredit({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://digitalheroesco.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      alignment: Alignment.center,
      child: InkWell(
        onTap: _launchURL,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.code_rounded,
                size: 16,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  children: [
                    TextSpan(text: 'Built for '),
                    TextSpan(
                      text: 'Digital Heroes Training Task',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.open_in_new_rounded,
                size: 13,
                color: Color(0xFF4F46E5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
