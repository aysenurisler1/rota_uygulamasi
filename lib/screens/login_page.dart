import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Arkaplan (sade)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEAF6EC), Color(0xFFDDEEE0)],
              ),
            ),
          ),

          // Üst bar (Amblem / AD)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: const Color(0xFF66B36A),
              child: Row(
                children: [
                  const Text(
                    'Amblem',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'AD',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Orta butonlar
          Center(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: const Text(
                      'Mevcut Kullanıcı',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      // şimdilik misafir de home'a geçsin (demo)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: const Text(
                      'Misafir Kullanıcı',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sol altta Kılavuz
          Positioned(
            left: 24,
            bottom: 24,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Kılavuz'),
                    content: const Text(
                      'Bu ekran demo iskeletidir.\n'
                      'Sonraki adım: giriş akışı + backend token.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Kılavuz'),
            ),
          ),
        ],
      ),
    );
  }
}

//x
