import 'package:flutter/material.dart';
import 'home_page.dart';

enum _LoginMode { guest, existing }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginMode mode = _LoginMode.guest;

  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _loginExisting() {
    final u = usernameCtrl.text.trim();
    final p = passwordCtrl.text;

    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı ve şifre gir.')),
      );
      return;
    }

    // Şimdilik demo: backend sonra
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEAF6EC), Color(0xFFDDEEE0)],
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 16,
                      offset: Offset(0, 10),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 34,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Giriş',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _ModeCard(
                            title: 'Misafir',
                            subtitle: 'Hızlı giriş (lokal)',
                            icon: Icons.person_outline,
                            active: mode == _LoginMode.guest,
                            color: cs.primary,
                            onTap: () =>
                                setState(() => mode = _LoginMode.guest),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeCard(
                            title: 'Mevcut Kullanıcı',
                            subtitle: 'Kullanıcı adı/şifre',
                            icon: Icons.lock_outline,
                            active: mode == _LoginMode.existing,
                            color: cs.primary,
                            onTap: () =>
                                setState(() => mode = _LoginMode.existing),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: mode == _LoginMode.existing
                          ? Column(
                              key: const ValueKey('existingForm'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: usernameCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Kullanıcı adı',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: cs.primary,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF6F7F8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: passwordCtrl,
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Şifre',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: cs.primary,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF6F7F8),
                                    suffixIcon: IconButton(
                                      tooltip: hidePassword
                                          ? 'Göster'
                                          : 'Gizle',
                                      onPressed: () => setState(
                                        () => hidePassword = !hidePassword,
                                      ),
                                      icon: Icon(
                                        hidePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) => _loginExisting(),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: _loginExisting,
                                    icon: const Icon(Icons.login),
                                    label: const Text('Giriş Yap'),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              key: const ValueKey('guestBlock'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cs.primary.withOpacity(0.18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Misafir modunda planlar cihazda tutulur. İstersen sonra mevcut kullanıcı ile giriş yapabilirsin.',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: _goHome,
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text(
                                      'Misafir Olarak Devam Et',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Not: Mevcut kullanıcı hesapları uygulama geliştiricileri tarafından tanımlanır.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = active ? color.withOpacity(0.45) : Colors.black12;
    final bg = active ? color.withOpacity(0.10) : const Color(0xFFF6F7F8);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? color : Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (active) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
