import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int index = 0;

  final pages = const [
    _Step(
        svg: 'assets/illustrations/onboard_fuel.svg',
        title: 'Catat BBM',
        desc: 'Simpan catatan isi BBM dengan cepat dan mudah.'),
    _Step(
        svg: 'assets/illustrations/onboard_stats.svg',
        title: 'Lihat Statistik',
        desc: 'Pantau pengeluaran, biaya/km, dan efisiensi.'),
    _Step(
        svg: 'assets/illustrations/onboard_sync.svg',
        title: 'Sinkron',
        desc: 'Data aman di cloud dan dapat diakses di mana saja.'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    context.go('/auth-gate');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (c, i) => pages[i],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == i
                        ? scheme.primary
                        : scheme.onSurface.withOpacity(.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => index == 0
                        ? null
                        : controller.previousPage(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOut),
                    child: const Text('Kembali'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => index == pages.length - 1
                        ? _finish()
                        : controller.nextPage(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOut),
                    child: Text(index == pages.length - 1 ? 'Mulai' : 'Lanjut'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.svg, required this.title, required this.desc});
  final String svg;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svg,
            width: 240,
            height: 150,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
