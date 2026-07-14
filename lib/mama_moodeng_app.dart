import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

void mainApp() {}

final shellIndexProvider = StateProvider<int>((ref) => 0);
final selectedMoodProvider = StateProvider<String?>((ref) => null);
final weeklyStreakProvider = StateProvider<int>((ref) => 7);
final coinWalletProvider = StateProvider<int>((ref) => 1280);
final latestGlucoseProvider = StateProvider<int>((ref) => 104);
final petHappinessProvider = StateProvider<int>((ref) => 82);
final selectedShopTabProvider = StateProvider<int>((ref) => 0);
final selectedLibraryCategoryProvider = StateProvider<int>((ref) => 0);
final bookmarkedArticleIdsProvider = StateProvider<Set<String>>((ref) => <String>{'gdm-basics'});
final completedChallengeIdsProvider = StateProvider<Set<String>>((ref) => <String>{'morning-glucose'});
final ownedShopItemsProvider = StateProvider<Set<String>>(
  (ref) => <String>{'character-aurora', 'outfit-cloud', 'furniture-willow'},
);
final equippedCharacterIdProvider = StateProvider<String>((ref) => 'character-aurora');
final equippedOutfitIdProvider = StateProvider<String>((ref) => 'outfit-cloud');
final equippedFurnitureIdProvider = StateProvider<String>((ref) => 'furniture-willow');
final selectedBlendIngredientsProvider = StateProvider<List<String>>(
  (ref) => <String>['Green Apple', 'Milk', 'Spinach'],
);

class MamaMoodengApp extends StatelessWidget {
  const MamaMoodengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mama Moodeng',
      themeMode: ThemeMode.system,
      theme: buildMamaTheme(Brightness.light),
      darkTheme: buildMamaTheme(Brightness.dark),
      home: const MamaShell(),
    );
  }
}

ThemeData buildMamaTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: MamaColors.primary,
    brightness: brightness,
  ).copyWith(
    primary: MamaColors.primary,
    secondary: MamaColors.blush,
    tertiary: MamaColors.sky,
    error: MamaColors.coral,
    surface: isDark ? const Color(0xFF171A20) : MamaColors.surface,
    onSurface: isDark ? const Color(0xFFF4F6F8) : MamaColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: isDark ? const Color(0xFF0E1116) : MamaColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        color: scheme.onSurface,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF15181E) : Colors.white,
      indicatorColor: MamaColors.mint,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF1B2027) : const Color(0xFFF6F6F2),
      selectedColor: MamaColors.mint,
      side: BorderSide(color: isDark ? const Color(0xFF313844) : MamaColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF181C23) : MamaColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MamaColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MamaColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1B2027) : const Color(0xFFF6F7F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: isDark ? const Color(0xFF313844) : MamaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: isDark ? const Color(0xFF313844) : MamaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: MamaColors.primary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: MamaColors.muted),
    ),
    textTheme: Typography.material2021().black.apply(
      fontFamily: 'Manrope',
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
  );
}

class MamaShell extends ConsumerWidget {
  const MamaShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);

    final pages = <Widget>[
      const HomePage(),
      const MedicalDictionaryPage(),
      const PetCafeGamePage(),
      const CustomizationShopPage(),
      const InsightsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: pages),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Mood check-in',
        backgroundColor: MamaColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => showMoodSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => ref.read(shellIndexProvider.notifier).state = value,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.coffee_rounded), label: 'Buddy'),
          NavigationDestination(icon: Icon(Icons.dry_cleaning_rounded), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Insights'),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinWalletProvider);
    final glucose = ref.watch(latestGlucoseProvider);
    final streak = ref.watch(weeklyStreakProvider);
    final selectedMood = ref.watch(selectedMoodProvider);
    final challengeIds = ref.watch(completedChallengeIdsProvider);
    final buddy = _findShopItemById(ref.watch(equippedCharacterIdProvider));

    return RefreshIndicator(
      onRefresh: () async {
        final nextGlucose = 96 + math.Random().nextInt(16);
        ref.read(latestGlucoseProvider.notifier).state = nextGlucose;
        await Future<void>.delayed(const Duration(milliseconds: 650));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          PageFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _TopGreetingRow(
                  selectedMood: selectedMood,
                  onMoodTap: () => showMoodSheet(context, ref),
                ),
                const SizedBox(height: 18),
                BuddyProgressCard(
                  buddyName: buddy?.name ?? 'Buddy',
                  happiness: ref.watch(petHappinessProvider),
                  streak: streak,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.casino_rounded,
                        iconColor: MamaColors.primary,
                        title: 'My Gold Coins',
                        value: '$coins',
                        subtitle: 'Reward wallet',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.opacity_rounded,
                        iconColor: MamaColors.coral,
                        title: 'Latest Glucose',
                        value: '$glucose',
                        subtitle: 'mg/dL',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Environmental Alerts',
                  subtitle: 'Real-time guidance for air quality and heat',
                  trailing: TextButton(
                    onPressed: () => ref.read(shellIndexProvider.notifier).state = 4,
                    child: const Text('Open report'),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: EnvironmentAlertCard(
                        icon: Icons.air_rounded,
                        label: 'PM2.5',
                        value: 'High',
                        advice:
                            'Today\'s air quality is unhealthy. Buddy recommends staying indoors and choosing light indoor exercise.',
                        accent: MamaColors.sun,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: EnvironmentAlertCard(
                        icon: Icons.thermostat_rounded,
                        label: 'Heat Index',
                        value: 'Very high',
                        advice:
                            'Today\'s temperature is very high. Please drink more water and avoid dehydration.',
                        accent: MamaColors.coral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Weekly Calendar',
                  subtitle: 'A quick glance at your rhythm',
                  trailing: Text(
                    _weekLabel(DateTime.now()),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: MamaColors.muted,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                WeeklyCalendarStrip(selectedDate: DateTime.now()),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Daily Challenges',
                  subtitle: 'Complete tasks to grow Buddy and earn coins',
                  trailing: TextButton(
                    onPressed: () => showMoodSheet(context, ref),
                    child: const Text('Check in'),
                  ),
                ),
                const SizedBox(height: 12),
                for (final challenge in homeChallenges)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChallengeCard(
                      challenge: challenge,
                      completed: challengeIds.contains(challenge.id),
                      onTap: () {
                        final completed = ref.read(completedChallengeIdsProvider.notifier);
                        final coinsNotifier = ref.read(coinWalletProvider.notifier);
                        if (completed.state.contains(challenge.id)) {
                          return;
                        }
                        completed.state = <String>{...completed.state, challenge.id};
                        coinsNotifier.state += challenge.rewardCoins;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('+${challenge.rewardCoins} coins for ${challenge.title}'),
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'Quick Navigation',
                  subtitle: 'Jump to the rest of the companion',
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 560 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.14,
                      children: [
                        QuickActionCard(
                          icon: Icons.menu_book_rounded,
                          label: 'Medical Library',
                          accent: MamaColors.sky,
                          onTap: () => ref.read(shellIndexProvider.notifier).state = 1,
                        ),
                        QuickActionCard(
                          icon: Icons.coffee_rounded,
                          label: 'Pet Cafe',
                          accent: MamaColors.mint,
                          onTap: () => ref.read(shellIndexProvider.notifier).state = 2,
                        ),
                        QuickActionCard(
                          icon: Icons.dry_cleaning_rounded,
                          label: 'Customization',
                          accent: MamaColors.peach,
                          onTap: () => ref.read(shellIndexProvider.notifier).state = 3,
                        ),
                        QuickActionCard(
                          icon: Icons.insights_rounded,
                          label: 'Analytics',
                          accent: MamaColors.lavender,
                          onTap: () => ref.read(shellIndexProvider.notifier).state = 4,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MedicalDictionaryPage extends ConsumerStatefulWidget {
  const MedicalDictionaryPage({super.key});

  @override
  ConsumerState<MedicalDictionaryPage> createState() => _MedicalDictionaryPageState();
}

class _MedicalDictionaryPageState extends ConsumerState<MedicalDictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedLibraryCategoryProvider);
    final bookmarkedIds = ref.watch(bookmarkedArticleIdsProvider);

    final filtered = articles.where((article) {
      final matchesCategory = selectedCategory == 0 || article.category == libraryCategories[selectedCategory];
      final lowerQuery = _query.toLowerCase();
      final matchesQuery = lowerQuery.isEmpty ||
          article.title.toLowerCase().contains(lowerQuery) ||
          article.summary.toLowerCase().contains(lowerQuery);
      return matchesCategory && matchesQuery;
    }).toList();

    return RefreshIndicator(
      onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 450)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          PageFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Medical Dictionary',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bookmarks',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bookmark collection is ready.')),
                        );
                      },
                      icon: const Icon(Icons.bookmark_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search articles...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(libraryCategories.length, (index) {
                      final selected = selectedCategory == index;
                      return Padding(
                        padding: EdgeInsets.only(right: index == libraryCategories.length - 1 ? 0 : 10),
                        child: FilterPill(
                          label: libraryCategories[index],
                          selected: selected,
                          onTap: () => ref.read(selectedLibraryCategoryProvider.notifier).state = index,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Recommended for You',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: MamaColors.muted,
                      ),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  EmptyArticlesState(query: _query)
                else
                  Column(
                    children: [
                      for (final article in filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleListCard(
                            article: article,
                            bookmarked: bookmarkedIds.contains(article.id),
                            onBookmarkTap: () {
                              final state = ref.read(bookmarkedArticleIdsProvider.notifier);
                              final next = <String>{...state.state};
                              if (next.contains(article.id)) {
                                next.remove(article.id);
                              } else {
                                next.add(article.id);
                              }
                              state.state = next;
                            },
                            onTap: () => openArticleDetail(context, article),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Browse All',
                  subtitle: 'Simple, doctor-friendly reading cards',
                ),
                const SizedBox(height: 12),
                for (final article in articles.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ArticleListCard(
                      article: article,
                      bookmarked: bookmarkedIds.contains(article.id),
                      onBookmarkTap: () {
                        final state = ref.read(bookmarkedArticleIdsProvider.notifier);
                        final next = <String>{...state.state};
                        if (next.contains(article.id)) {
                          next.remove(article.id);
                        } else {
                          next.add(article.id);
                        }
                        state.state = next;
                      },
                      onTap: () => openArticleDetail(context, article),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PetCafeGamePage extends ConsumerStatefulWidget {
  const PetCafeGamePage({super.key});

  @override
  ConsumerState<PetCafeGamePage> createState() => _PetCafeGamePageState();
}

class _PetCafeGamePageState extends ConsumerState<PetCafeGamePage> {
  String _status = 'Ready to blend?';
  int _rewardPreview = 0;

  @override
  Widget build(BuildContext context) {
    final coinBalance = ref.watch(coinWalletProvider);
    final glucose = ref.watch(latestGlucoseProvider);
    final happiness = ref.watch(petHappinessProvider);
    final selectedTab = ref.watch(petCafeTabProvider);
    final ingredientChoices = ref.watch(selectedBlendIngredientsProvider);
    final result = evaluateBlend(ingredientChoices);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buddy Cafe',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A playful mini-game that teaches healthy food choices.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MamaColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Home',
                    onPressed: () => ref.read(shellIndexProvider.notifier).state = 0,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 286,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF3E4D7), Color(0xFFD7E4EE), Color(0xFFFCE9D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 90,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFB8A290), Color(0xFFDFCFC1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 26,
                        left: 24,
                        right: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatPill(
                              icon: Icons.casino_rounded,
                              label: '$coinBalance coins',
                            ),
                            StatPill(
                              icon: Icons.opacity_rounded,
                              label: '$glucose mg/dL',
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 76,
                        child: Container(
                          height: 116,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 28,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: MamaColors.surface,
                              child: Icon(
                                Icons.pets_rounded,
                                size: 56,
                                color: MamaColors.primary.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Buddy happiness $happiness%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SegmentTabs(
                labels: const ['Mix & Sell', 'Market', 'Reports'],
                selectedIndex: selectedTab,
                onChanged: (value) => ref.read(petCafeTabProvider.notifier).state = value,
              ),
              const SizedBox(height: 16),
              if (selectedTab == 0) ...[
                Text(
                  'Blender Mini-Game',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(3, (index) {
                          final current = ingredientChoices[index];
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                              child: IngredientDropdown(
                                value: current,
                                onChanged: (value) {
                                  final next = [...ingredientChoices];
                                  next[index] = value;
                                  ref.read(selectedBlendIngredientsProvider.notifier).state = next;
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: MamaColors.background,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 62,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: result.isHealthy
                                      ? [MamaColors.primary, MamaColors.mint]
                                      : [MamaColors.coral, MamaColors.peach],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _status,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: MamaColors.muted,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: MamaColors.muted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () {
                          final outcome = evaluateBlend(ref.read(selectedBlendIngredientsProvider));
                          final coinsNotifier = ref.read(coinWalletProvider.notifier);
                          final happinessNotifier = ref.read(petHappinessProvider.notifier);
                          coinsNotifier.state += outcome.rewardCoins;
                          happinessNotifier.state =
                              (happinessNotifier.state + outcome.happinessDelta).clamp(0, 100).toInt();
                          setState(() {
                            _status = outcome.label;
                            _rewardPreview = outcome.rewardCoins;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${outcome.label} +${outcome.rewardCoins} coins')),
                          );
                        },
                        child: const Text('Blend & Sell'),
                      ),
                      if (_rewardPreview > 0) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Last reward: +$_rewardPreview coins',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MamaColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SoftCard(
                  color: const Color(0xFFFFFBF4),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: MamaColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Need more style? Visit the Customization Shop',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => ref.read(shellIndexProvider.notifier).state = 3,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Go to Shop'),
                      ),
                    ],
                  ),
                ),
              ] else if (selectedTab == 1) ...[
                const SectionHeader(
                  title: 'Market',
                  subtitle: 'Swap low GI blends for bonuses',
                ),
                const SizedBox(height: 12),
                for (final offer in marketOffers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: offer.color.withValues(alpha: 0.18),
                          child: Icon(offer.icon, color: offer.color),
                        ),
                        title: Text(
                          offer.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(offer.subtitle),
                        trailing: Text(
                          offer.reward,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                const SectionHeader(
                  title: 'Reports',
                  subtitle: 'A quick summary of Buddy Cafe behavior',
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ReportMiniTile(
                              label: 'Happy blends',
                              value: '14',
                              accent: MamaColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ReportMiniTile(
                              label: 'Dizzy blends',
                              value: '3',
                              accent: MamaColors.coral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ReportMiniTile(
                              label: 'Coins earned',
                              value: '$coinBalance',
                              accent: MamaColors.sun,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ReportMiniTile(
                              label: 'Buddy mood',
                              value: '$happiness%',
                              accent: MamaColors.sky,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (selectedTab == 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Buddy is learning from your ingredients.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CustomizationShopPage extends ConsumerWidget {
  const CustomizationShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedShopTabProvider);
    final ownedItems = ref.watch(ownedShopItemsProvider);
    final coins = ref.watch(coinWalletProvider);

    final items = shopItemsBySlot[selectedTab == 0
            ? ShopSlot.character
            : selectedTab == 1
                ? ShopSlot.outfit
                : ShopSlot.furniture] ??
        const <ShopItem>[];

    final slotLabel = switch (selectedTab) {
      0 => 'Characters',
      1 => 'Skins/Outfits',
      _ => 'Furniture',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Customization Shop',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Back to home',
                    onPressed: () => ref.read(shellIndexProvider.notifier).state = 0,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.casino_rounded, color: MamaColors.sun),
                  const SizedBox(width: 6),
                  Text(
                    '[$coins] Coins',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentTabs(
                labels: const ['Characters', 'Skins/Outfits', 'Furniture'],
                selectedIndex: selectedTab,
                onChanged: (value) => ref.read(selectedShopTabProvider.notifier).state = value,
              ),
              const SizedBox(height: 18),
              Text(
                'New Arrivals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 560 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.take(4).length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ShopItemCard(
                        item: item,
                        owned: ownedItems.contains(item.id),
                        equipped: isEquipped(ref, item),
                        onBuy: () => buyShopItem(context, ref, item),
                        onEquip: () => equipShopItem(ref, item),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                'All Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 560 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ShopItemCard(
                        item: item,
                        owned: ownedItems.contains(item.id),
                        equipped: isEquipped(ref, item),
                        onBuy: () => buyShopItem(context, ref, item),
                        onEquip: () => equipShopItem(ref, item),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              SoftCard(
                color: const Color(0xFFFFFBF4),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, color: MamaColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Equipping updates Buddy, cafe, and furniture instantly without restarting.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current tab: $slotLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinWalletProvider);
    final glucose = ref.watch(latestGlucoseProvider);
    final happiness = ref.watch(petHappinessProvider);
    final streak = ref.watch(weeklyStreakProvider);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                'Medical Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Doctor-friendly summaries with fast-glance charts.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ExportButton(label: 'PDF', icon: Icons.picture_as_pdf_rounded, onTap: () => _showExportSnack(context, 'PDF')),
                  ExportButton(label: 'Image', icon: Icons.image_rounded, onTap: () => _showExportSnack(context, 'Image')),
                  ExportButton(label: 'Share', icon: Icons.share_rounded, onTap: () => _showExportSnack(context, 'Share')),
                ],
              ),
              const SizedBox(height: 18),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Blood Glucose Trend',
                      subtitle: '7-day graph with safe target range',
                    ),
                    const SizedBox(height: 10),
                    const MiniLineChart(
                      values: [92, 98, 105, 111, 104, 99, 108],
                      lineColor: MamaColors.primary,
                      fillColor: Color(0xFFEDF7D8),
                    ),
                    const SizedBox(height: 10),
                    TargetRangeStrip(currentValue: glucose.toDouble(), minSafe: 70, maxSafe: 140),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Weekly Mood Chart',
                      subtitle: 'Gentle check-ins across the week',
                    ),
                    const SizedBox(height: 10),
                    const MiniBarChart(
                      values: [0.58, 0.78, 0.44, 0.8, 0.67, 0.76, 0.89],
                      labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                      barColor: MamaColors.blush,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task completion',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          CircularStatRing(
                            value: 0.74,
                            centerLabel: '74%',
                            accent: MamaColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pet happiness',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          CircularStatRing(
                            value: happiness / 100,
                            centerLabel: '$happiness%',
                            accent: MamaColors.coral,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Coin Earning History',
                      subtitle: 'Recent reward momentum',
                    ),
                    const SizedBox(height: 10),
                    const MiniBarChart(
                      values: [0.5, 0.72, 0.62, 0.83, 0.68, 0.9, 0.76],
                      labels: ['1', '2', '3', '4', '5', '6', '7'],
                      barColor: MamaColors.sun,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$coins coins total  |  $streak-day streak',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                color: const Color(0xFFFFFBF4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Summary',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SummaryRow(label: 'Average glucose in target range', value: '5 / 7 days'),
                    SummaryRow(label: 'Mood check-ins logged', value: '11'),
                    SummaryRow(label: 'Healthy blends completed', value: '14'),
                    SummaryRow(label: 'Buddy happiness score', value: '$happiness / 100'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KnowledgeDetailPage extends ConsumerWidget {
  const KnowledgeDetailPage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(bookmarkedArticleIdsProvider).contains(article.id);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Share',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share option is ready for later integration.')),
                          );
                        },
                        icon: const Icon(Icons.share_rounded),
                      ),
                      IconButton(
                        tooltip: 'Bookmark',
                        onPressed: () {
                          final state = ref.read(bookmarkedArticleIdsProvider.notifier);
                          final next = <String>{...state.state};
                          if (next.contains(article.id)) {
                            next.remove(article.id);
                          } else {
                            next.add(article.id);
                          }
                          state.state = next;
                        },
                        icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Hero(
                    tag: 'article-hero-${article.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 260,
                            width: double.infinity,
                            child: _NetworkHeroImage(
                              url: article.heroImageUrl,
                              fallback: article.heroStops,
                            ),
                          ),
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: MamaColors.primary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                article.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      BadgePill(
                        icon: Icons.schedule_rounded,
                        label: article.readTime,
                      ),
                      BadgePill(
                        icon: Icons.verified_rounded,
                        label: 'Medically Reviewed',
                        iconColor: MamaColors.primary,
                      ),
                      BadgePill(
                        icon: Icons.bookmark_rounded,
                        label: article.category,
                        iconColor: MamaColors.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    article.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.65,
                          color: MamaColors.muted,
                        ),
                  ),
                  const SizedBox(height: 16),
                  for (final block in article.blocks) ...[
                    ArticleCallout(block: block),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Related Articles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final related in articles.where((item) => item.id != article.id && item.category == article.category).take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SmallRelatedArticleCard(
                        article: related,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => KnowledgeDetailPage(article: related),
                            ),
                          );
                        },
                      ),
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

// Data and helpers

class MamaColors {
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFCF8);
  static const text = Color(0xFF202225);
  static const muted = Color(0xFF7A8394);
  static const border = Color(0xFFE6E8EE);
  static const primary = Color(0xFF8CBC42);
  static const mint = Color(0xFFDDECC0);
  static const blush = Color(0xFFF7D6DF);
  static const coral = Color(0xFFF76D8F);
  static const peach = Color(0xFFFFD8B6);
  static const sky = Color(0xFFD5ECF7);
  static const lavender = Color(0xFFE8DCF5);
  static const sun = Color(0xFFFFC247);
}

enum ShopSlot { character, outfit, furniture }

enum ArticleBlockType { tip, warning, note }

class ArticleBlock {
  const ArticleBlock({
    required this.type,
    required this.title,
    required this.body,
  });

  final ArticleBlockType type;
  final String title;
  final String body;
}

class Article {
  const Article({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.readTime,
    required this.reviewed,
    required this.heroImageUrl,
    required this.heroStops,
    required this.body,
    required this.blocks,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final String readTime;
  final bool reviewed;
  final String heroImageUrl;
  final List<Color> heroStops;
  final String body;
  final List<ArticleBlock> blocks;
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.slot,
    required this.name,
    required this.price,
    required this.description,
    required this.colors,
    required this.icon,
  });

  final String id;
  final ShopSlot slot;
  final String name;
  final int price;
  final String description;
  final List<Color> colors;
  final IconData icon;
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rewardCoins,
    required this.icon,
    required this.accent,
  });

  final String id;
  final String title;
  final String subtitle;
  final int rewardCoins;
  final IconData icon;
  final Color accent;
}

class MoodChoice {
  const MoodChoice({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.advice,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String advice;
}

class MarketOffer {
  const MarketOffer({
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String reward;
  final IconData icon;
  final Color color;
}

class BlendOutcome {
  const BlendOutcome({
    required this.label,
    required this.message,
    required this.rewardCoins,
    required this.happinessDelta,
    required this.isHealthy,
  });

  final String label;
  final String message;
  final int rewardCoins;
  final int happinessDelta;
  final bool isHealthy;
}

const libraryCategories = <String>[
  'All',
  'Nutrition Guide',
  'Climate Warnings',
  'Maternal Routines',
  'Exercise',
  'Medication',
  'FAQ',
];

const homeChallenges = <Challenge>[
  Challenge(
    id: 'morning-glucose',
    title: 'Morning Glucose Log',
    subtitle: 'Capture your fasting reading for Buddy.',
    rewardCoins: 50,
    icon: Icons.opacity_rounded,
    accent: MamaColors.mint,
  ),
  Challenge(
    id: 'mood-check',
    title: 'Mood Check-in',
    subtitle: 'Notice how your body and mind feel.',
    rewardCoins: 20,
    icon: Icons.favorite_rounded,
    accent: MamaColors.blush,
  ),
  Challenge(
    id: 'meal-log',
    title: 'Post-Breakfast Meal Log',
    subtitle: 'Record what you ate after breakfast.',
    rewardCoins: 100,
    icon: Icons.restaurant_rounded,
    accent: MamaColors.peach,
  ),
  Challenge(
    id: 'walk',
    title: '10-Minute Walk',
    subtitle: 'A short stroll can support glucose balance.',
    rewardCoins: 80,
    icon: Icons.directions_walk_rounded,
    accent: MamaColors.sky,
  ),
  Challenge(
    id: 'water',
    title: 'Water Intake',
    subtitle: 'Stay hydrated and keep Buddy calm.',
    rewardCoins: 20,
    icon: Icons.water_drop_rounded,
    accent: MamaColors.lavender,
  ),
];

const moods = <MoodChoice>[
  MoodChoice(
    id: 'excited',
    label: 'Excited',
    icon: Icons.celebration_rounded,
    color: Color(0xFFFBE0EA),
    advice: 'Excitement is lovely. Keep your meals steady and enjoy the moment with calm breathing.',
  ),
  MoodChoice(
    id: 'joyful',
    label: 'Joyful',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: Color(0xFFF8EFCF),
    advice: 'Joy is a good sign. Keep sipping water and stay gently active when it feels good.',
  ),
  MoodChoice(
    id: 'grateful',
    label: 'Grateful',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE9DCF5),
    advice: 'Gratitude can lower stress. A quiet pause may help your glucose stay steady.',
  ),
  MoodChoice(
    id: 'energized',
    label: 'Energized',
    icon: Icons.bolt_rounded,
    color: Color(0xFFE0F0E3),
    advice: 'If you feel energized, use it for a short walk after eating and keep the momentum gentle.',
  ),
  MoodChoice(
    id: 'sensitive',
    label: 'Sensitive',
    icon: Icons.waves_rounded,
    color: Color(0xFFD7ECF8),
    advice: 'If today feels sensitive, slow down, hydrate, and keep your next meal balanced.',
  ),
  MoodChoice(
    id: 'confused',
    label: 'Confused',
    icon: Icons.help_outline_rounded,
    color: Color(0xFFF4F1F1),
    advice: 'Confused moments are normal. Buddy recommends one small step: check, log, and breathe.',
  ),
  MoodChoice(
    id: 'bored',
    label: 'Bored',
    icon: Icons.sentiment_neutral_rounded,
    color: Color(0xFFF1F4F8),
    advice: 'A short routine reset can help. Try a glass of water or a quick stretch.',
  ),
  MoodChoice(
    id: 'stressed',
    label: 'Stressed',
    icon: Icons.priority_high_rounded,
    color: Color(0xFFFDF1D6),
    advice:
        'Stress can nudge glucose upward. Buddy recommends a short break, a glass of water, and three slow breaths.',
  ),
  MoodChoice(
    id: 'angry',
    label: 'Angry',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: Color(0xFFFDE2E6),
    advice: 'A brief pause is enough. Try stepping away for a minute and return when your body feels calmer.',
  ),
  MoodChoice(
    id: 'insecure',
    label: 'Insecure',
    icon: Icons.shield_rounded,
    color: Color(0xFFF2EBE8),
    advice: 'You do not need to do this perfectly. One consistent meal choice is already progress.',
  ),
  MoodChoice(
    id: 'hurt',
    label: 'Hurt',
    icon: Icons.heart_broken_rounded,
    color: Color(0xFFF8E0EA),
    advice: 'If you feel hurt, keep things gentle and lean on support. Buddy is staying beside you.',
  ),
  MoodChoice(
    id: 'guilty',
    label: 'Guilty',
    icon: Icons.do_not_disturb_rounded,
    color: Color(0xFFDFF1F2),
    advice: 'Guilt is heavy. A single reading or meal does not define your day. Reset and continue kindly.',
  ),
];

final petCafeTabProvider = StateProvider<int>((ref) => 0);

const marketOffers = <MarketOffer>[
  MarketOffer(
    title: 'Low GI Strawberry Cup',
    subtitle: 'Bright, safe, and perfect after breakfast.',
    reward: '+120 coins',
    icon: Icons.local_drink_rounded,
    color: MamaColors.primary,
  ),
  MarketOffer(
    title: 'Calm Carrot Toast',
    subtitle: 'A steady snack with gentle energy.',
    reward: '+90 coins',
    icon: Icons.bakery_dining_rounded,
    color: MamaColors.sun,
  ),
  MarketOffer(
    title: 'Hydration Bonus',
    subtitle: 'Buddy rewards every water-first routine.',
    reward: '+40 coins',
    icon: Icons.water_drop_rounded,
    color: MamaColors.coral,
  ),
];

const articles = <Article>[
  Article(
    id: 'gdm-basics',
    category: 'Nutrition Guide',
    title: 'Why GI Matters',
    summary: 'How glycemic index affects glucose spikes and hunger.',
    readTime: '6 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFF6E9CE), Color(0xFFD9EBE2), Color(0xFFF8D6C4)],
    body:
        'The glycemic index ranks carbohydrates by how quickly they can raise blood glucose. '
        'Pairing carbohydrates with protein, fiber, and healthy fats can smooth the response and help you feel steady longer.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Pro-Tip for Mom',
        body:
            'Try a 10-minute light walk immediately after breakfast. It can help glucose move into the muscles more efficiently.',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Watch the spikes',
        body:
            'Large fruit portions, sweetened drinks, and refined pastries tend to climb fast. Keep portions simple and balanced.',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Medical note',
        body:
            'Use patterns, not one number, to judge your day. Your care team cares about repeated trends over time.',
      ),
    ],
  ),
  Article(
    id: 'meal-swaps',
    category: 'Nutrition Guide',
    title: 'Safe Breakfast Swaps',
    summary: 'Better combinations that still feel filling and comforting.',
    readTime: '5 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2fdfd?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFFCE7D8), Color(0xFFFFF4DF), Color(0xFFDCEEE5)],
    body:
        'A balanced breakfast can start with protein, then add a moderate carbohydrate source and a little fat. '
        'The goal is not restriction. It is choosing combinations that keep you comfortable and consistent.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Try this first',
        body: 'Swap sweet cereal for plain yogurt, berries, chia seeds, and a few nuts.',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Read labels gently',
        body: 'Granola and flavored yogurts can hide a lot of sugar. Check the serving size before deciding.',
      ),
    ],
  ),
  Article(
    id: 'heat-warning',
    category: 'Climate Warnings',
    title: 'High Heat Index and Hydration',
    summary: 'Why very hot days need extra water and lighter activity.',
    readTime: '4 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFFFE6C3), Color(0xFFF8D7B8), Color(0xFFFCE8D4)],
    body:
        'Very hot weather can make dehydration more likely. When the heat index rises, the body works harder to stay cool, so water and shade matter more than usual.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy recommends',
        body: 'Stay indoors when the air feels heavy, and choose short gentle movement instead of long outdoor walks.',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Hydration reminder',
        body: 'If your urine becomes dark or you feel dizzy, slow down and drink water immediately.',
      ),
    ],
  ),
  Article(
    id: 'walk-routine',
    category: 'Maternal Routines',
    title: 'Walking After Meals',
    summary: 'A tiny routine that can make glucose feel easier to manage.',
    readTime: '3 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1517483000871-1db4f7d2d6c3?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFE7F2DE), Color(0xFFD6E9F3), Color(0xFFF1E3C7)],
    body:
        'A short walk after meals can help glucose move more efficiently and can support your mood too. '
        'Keep the pace comfortable, especially during pregnancy.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Easy routine',
        body: 'Set a 10-minute timer and walk around the house or hallway after breakfast or lunch.',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Keep it gentle',
        body: 'If you feel tired, split the walk into two smaller rounds and keep breathing easy.',
      ),
    ],
  ),
  Article(
    id: 'medication-faq',
    category: 'Medication',
    title: 'Medication Questions for GDM',
    summary: 'How to think about medication timing and follow-up safely.',
    readTime: '7 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFE9E1F7), Color(0xFFD7ECF8), Color(0xFFF8E2E9)],
    body:
        'If your clinician recommends medication or insulin, the plan is there to protect both you and the baby. '
        'Use the schedule they provide, and never adjust doses without asking them first.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Ask before changing',
        body: 'Do not skip or double a dose on your own. Confirm any change with your care team.',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Follow-up matters',
        body: 'Track the numbers that matter and bring them to your visits. The trend tells the story.',
      ),
    ],
  ),
  Article(
    id: 'durian-faq',
    category: 'FAQ',
    title: 'Can I Eat Durian?',
    summary: 'A gentle answer with portion awareness and swaps.',
    readTime: '4 min read',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFF5E7CC), Color(0xFFE5F0DD), Color(0xFFF8DDE4)],
    body:
        'Durian can raise glucose quickly because it has a strong carbohydrate load. '
        'If you really want fruit, keep the portion tiny and pair it with a protein-rich snack.',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy says',
        body: 'Choose guava or green apple more often when you need a fruit snack.',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Portion caution',
        body: 'Avoid turning fruit into a dessert-sized serving. Small and balanced is the safer direction.',
      ),
    ],
  ),
];

const shopItemsBySlot = <ShopSlot, List<ShopItem>>{
  ShopSlot.character: [
    ShopItem(
      id: 'character-aurora',
      slot: ShopSlot.character,
      name: 'Aurora Buddy',
      price: 0,
      description: 'The default calm companion.',
      colors: [Color(0xFFCBE7A9), Color(0xFFF5F8E5)],
      icon: Icons.pets_rounded,
    ),
    ShopItem(
      id: 'character-clover',
      slot: ShopSlot.character,
      name: 'Clover Buddy',
      price: 240,
      description: 'A brighter personality with leafy vibes.',
      colors: [Color(0xFFDDF2C0), Color(0xFFF3FBE8)],
      icon: Icons.nature_rounded,
    ),
    ShopItem(
      id: 'character-luna',
      slot: ShopSlot.character,
      name: 'Luna Buddy',
      price: 300,
      description: 'A moonlit look for calmer evenings.',
      colors: [Color(0xFFDCE5F9), Color(0xFFF7F6FF)],
      icon: Icons.brightness_2_rounded,
    ),
    ShopItem(
      id: 'character-pearl',
      slot: ShopSlot.character,
      name: 'Pearl Buddy',
      price: 260,
      description: 'Soft and elegant with a gentle blush tone.',
      colors: [Color(0xFFF5DDE8), Color(0xFFFFF4F7)],
      icon: Icons.circle_rounded,
    ),
  ],
  ShopSlot.outfit: [
    ShopItem(
      id: 'outfit-cloud',
      slot: ShopSlot.outfit,
      name: 'Cloud Apron',
      price: 0,
      description: 'A soft starter outfit for Buddy.',
      colors: [Color(0xFFF4F5F8), Color(0xFFE5EDF7)],
      icon: Icons.checkroom_rounded,
    ),
    ShopItem(
      id: 'outfit-mint',
      slot: ShopSlot.outfit,
      name: 'Mint Wrap',
      price: 180,
      description: 'Clean, fresh, and calm for the cafe.',
      colors: [Color(0xFFDDF2C0), Color(0xFFF2F9E5)],
      icon: Icons.checkroom_rounded,
    ),
    ShopItem(
      id: 'outfit-breeze',
      slot: ShopSlot.outfit,
      name: 'Breeze Cardigan',
      price: 210,
      description: 'Light layers for warm days.',
      colors: [Color(0xFFD7ECF8), Color(0xFFF3FAFD)],
      icon: Icons.checkroom_rounded,
    ),
    ShopItem(
      id: 'outfit-sunrise',
      slot: ShopSlot.outfit,
      name: 'Sunrise Dress',
      price: 280,
      description: 'A cheerful look with a soft glow.',
      colors: [Color(0xFFFFD8B6), Color(0xFFFFF3E8)],
      icon: Icons.checkroom_rounded,
    ),
  ],
  ShopSlot.furniture: [
    ShopItem(
      id: 'furniture-willow',
      slot: ShopSlot.furniture,
      name: 'Willow Sofa',
      price: 0,
      description: 'The default cozy cafe sofa.',
      colors: [Color(0xFFF7ECDD), Color(0xFFFFFAF4)],
      icon: Icons.chair_rounded,
    ),
    ShopItem(
      id: 'furniture-lamp',
      slot: ShopSlot.furniture,
      name: 'Petal Lamp',
      price: 160,
      description: 'Adds warmth to the room at night.',
      colors: [Color(0xFFFFE6C3), Color(0xFFFFF9EC)],
      icon: Icons.lightbulb_rounded,
    ),
    ShopItem(
      id: 'furniture-shelf',
      slot: ShopSlot.furniture,
      name: 'Soft Shelf',
      price: 220,
      description: 'Display your gentle little cafe items.',
      colors: [Color(0xFFDDECC0), Color(0xFFF9FDEB)],
      icon: Icons.view_module_rounded,
    ),
    ShopItem(
      id: 'furniture-rug',
      slot: ShopSlot.furniture,
      name: 'Moon Rug',
      price: 190,
      description: 'Quiet texture under Buddy\'s feet.',
      colors: [Color(0xFFE8DCF5), Color(0xFFFDF9FF)],
      icon: Icons.auto_awesome_rounded,
    ),
  ],
};

// Shared widgets and helpers

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.maxWidth = 560,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, maxWidth);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _TopGreetingRow extends StatelessWidget {
  const _TopGreetingRow({
    required this.selectedMood,
    required this.onMoodTap,
  });

  final String? selectedMood;
  final VoidCallback onMoodTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: MamaColors.mint,
          child: Text(
            'MB',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeGreeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                'Mama Moodeng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (selectedMood != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onMoodTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: MamaColors.blush.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Mood today: $selectedMood',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'Mood check-in',
          onPressed: onMoodTap,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3038) : MamaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.045),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MamaColors.muted,
                      ),
                ),
              ],
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? MamaColors.primary.withValues(alpha: 0.14) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? MamaColors.primary.withValues(alpha: 0.35) : MamaColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? MamaColors.primary : MamaColors.text,
          ),
        ),
      ),
    );
  }
}

class BuddyProgressCard extends StatelessWidget {
  const BuddyProgressCard({
    super.key,
    required this.buddyName,
    required this.happiness,
    required this.streak,
  });

  final String buddyName;
  final int happiness;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFE7F4C8),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buddy\'s Happiness',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MamaColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Level Up Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: MamaColors.text,
                      ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    disabledBackgroundColor: MamaColors.primary,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: Text('Visit $buddyName'),
                ),
                const SizedBox(height: 12),
                Text(
                  '$streak-day streak  |  $happiness% happiness',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          CircularStatRing(
            value: happiness / 100,
            centerLabel: '$happiness%',
            accent: MamaColors.primary,
            size: 100,
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
          ),
        ],
      ),
    );
  }
}

class EnvironmentAlertCard extends StatelessWidget {
  const EnvironmentAlertCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.advice,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String advice;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: accent.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: accent.withValues(alpha: 0.16),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            advice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MamaColors.muted,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class WeeklyCalendarStrip extends StatelessWidget {
  const WeeklyCalendarStrip({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday - 1));
    final entries = List.generate(7, (index) => start.add(Duration(days: index)));

    return SoftCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: entries.map((date) {
          final isToday =
              date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
          return Expanded(
            child: Column(
              children: [
                Text(
                  weekdayShort(date.weekday),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MamaColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? MamaColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isToday ? Colors.white : MamaColors.text,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.completed,
    required this.onTap,
  });

  final Challenge challenge;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: completed ? const Color(0xFFF2FAE5) : Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: challenge.accent.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(challenge.icon, color: MamaColors.text),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  challenge.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MamaColors.muted,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  completed ? 'Completed | +${challenge.rewardCoins} coins' : '+${challenge.rewardCoins} coins',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: completed ? MamaColors.primary : MamaColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: completed ? null : onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed ? MamaColors.primary : Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: completed ? MamaColors.primary : MamaColors.border),
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.add_rounded,
                color: completed ? Colors.white : MamaColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SoftCard(
        color: accent.withValues(alpha: 0.12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.18),
              child: Icon(icon, color: MamaColors.text),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleListCard extends StatelessWidget {
  const ArticleListCard({
    super.key,
    required this.article,
    required this.bookmarked,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final Article article;
  final bool bookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Hero(
              tag: 'article-hero-${article.id}',
              child: Container(
                width: 104,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: article.heroStops,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MamaColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MamaColors.muted,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: MamaColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.verified_rounded, size: 16, color: MamaColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Reviewed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MamaColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBookmarkTap,
              icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyArticlesState extends StatelessWidget {
  const EmptyArticlesState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFF9FAFC),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 36),
          const SizedBox(height: 10),
          Text(
            'No articles found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            query.isEmpty ? 'Try selecting a category above.' : 'Try adjusting your search or category filter.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
          ),
        ],
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    required this.owned,
    required this.equipped,
    required this.onBuy,
    required this.onEquip,
  });

  final ShopItem item;
  final bool owned;
  final bool equipped;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final actionLabel = equipped ? 'Equipped' : owned ? 'Equip' : item.price == 0 ? 'Free' : 'Buy';

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: item.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Center(
              child: Icon(item.icon, size: 40, color: MamaColors.text),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                item.price == 0 ? 'Owned' : '${item.price} coins',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.price == 0 ? MamaColors.primary : MamaColors.text,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: equipped
                    ? null
                    : owned
                        ? onEquip
                        : onBuy,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MamaColors.border),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? MamaColors.primary.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? MamaColors.primary : MamaColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class IngredientDropdown extends StatelessWidget {
  const IngredientDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MamaColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          items: ingredientOptions
              .map(
                (ingredient) => DropdownMenuItem<String>(
                  value: ingredient,
                  child: Text(
                    ingredient,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
      ),
    );
  }
}

class ReportMiniTile extends StatelessWidget {
  const ReportMiniTile({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MamaColors.muted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MamaColors.text,
                ),
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MamaColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: MamaColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: MamaColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgePill extends StatelessWidget {
  const BadgePill({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = MamaColors.muted,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MamaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MamaColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class CircularStatRing extends StatelessWidget {
  const CircularStatRing({
    super.key,
    required this.value,
    required this.centerLabel,
    required this.accent,
    this.size = 94,
  });

  final double value;
  final String centerLabel;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 800),
            builder: (context, animated, _) {
              return CircularProgressIndicator(
                value: animated,
                strokeWidth: 9,
                backgroundColor: accent.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              );
            },
          ),
          Text(
            centerLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class ArticleCallout extends StatelessWidget {
  const ArticleCallout({super.key, required this.block});

  final ArticleBlock block;

  @override
  Widget build(BuildContext context) {
    final (Color accent, IconData icon) = switch (block.type) {
      ArticleBlockType.tip => (MamaColors.primary, Icons.lightbulb_rounded),
      ArticleBlockType.warning => (MamaColors.coral, Icons.warning_rounded),
      ArticleBlockType.note => (MamaColors.sky, Icons.note_alt_rounded),
    };

    return SoftCard(
      color: accent.withValues(alpha: 0.10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  block.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                        color: MamaColors.muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallRelatedArticleCard extends StatelessWidget {
  const SmallRelatedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: article.heroStops),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MamaColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.readTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
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

class TargetRangeStrip extends StatelessWidget {
  const TargetRangeStrip({
    super.key,
    required this.currentValue,
    required this.minSafe,
    required this.maxSafe,
  });

  final double currentValue;
  final double minSafe;
  final double maxSafe;

  @override
  Widget build(BuildContext context) {
    final range = maxSafe - minSafe;
    final marker = ((currentValue - minSafe) / range).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Safe target range',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
            ),
            Text(
              '${minSafe.toInt()} - ${maxSafe.toInt()} mg/dL',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MamaColors.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 30,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF1D6D9), Color(0xFFF0EABF), Color(0xFFDDECC0)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * marker - 7,
                    top: 1,
                    child: Container(
                      width: 14,
                      height: 28,
                      decoration: BoxDecoration(
                        color: MamaColors.text,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: CustomPaint(
        painter: _MiniLineChartPainter(values, lineColor, fillColor),
      ),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  _MiniLineChartPainter(this.values, this.lineColor, this.fillColor);

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(maxValue - minValue, 1.0);
    final horizontalPadding = 10.0;
    final points = <Offset>[];

    for (var index = 0; index < values.length; index++) {
      final x = horizontalPadding +
          (values.length == 1 ? 0 : (size.width - horizontalPadding * 2) * index / (values.length - 1));
      final normalized = (values[index] - minValue) / range;
      final y = size.height - 14 - normalized * (size.height - 34);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points) {
      linePath.lineTo(point.dx, point.dy);
    }
    fillPath.addPolygon(points, false);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [fillColor.withValues(alpha: 0.78), fillColor.withValues(alpha: 0.04)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final gridPaint = Paint()
      ..color = MamaColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor;
  }
}

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.barColor,
  });

  final List<double> values;
  final List<String> labels;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final heightFactor = values[index].clamp(0.05, 1.0).toDouble();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 92 * heightFactor,
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NetworkHeroImage extends StatelessWidget {
  const _NetworkHeroImage({
    required this.url,
    required this.fallback,
  });

  final String url;
  final List<Color> fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: fallback, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: fallback, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -12,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Center(
                child: Icon(Icons.restaurant_rounded, size: 68, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Mood sheet

Future<void> showMoodSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const MoodCheckInSheet();
    },
  );
}

class MoodCheckInSheet extends ConsumerStatefulWidget {
  const MoodCheckInSheet({super.key});

  @override
  ConsumerState<MoodCheckInSheet> createState() => _MoodCheckInSheetState();
}

class _MoodCheckInSheetState extends ConsumerState<MoodCheckInSheet> {
  String? selectedMoodId;

  @override
  Widget build(BuildContext context) {
    final selected = moods.firstWhere((mood) => mood.id == selectedMoodId, orElse: () => moods.first);
    final hasSelection = selectedMoodId != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.72,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: MamaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MamaColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Check-in time:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: MamaColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you today?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moods.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.02,
                      ),
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final selectedMood = mood.id == selectedMoodId;
                        return MoodTile(
                          mood: mood,
                          selected: selectedMood,
                          onTap: () => setState(() => selectedMoodId = mood.id),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      color: const Color(0xFFEFF8E4),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard_rounded, color: MamaColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check-in to earn +20 Gold Coins',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: MamaColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (hasSelection)
                      SoftCard(
                        color: selected.color.withValues(alpha: 0.32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.label,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selected.advice,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: MamaColors.muted,
                                    height: 1.55,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: hasSelection
                          ? () {
                              final coinsNotifier = ref.read(coinWalletProvider.notifier);
                              coinsNotifier.state += 20;
                              ref.read(selectedMoodProvider.notifier).state = selected.label;
                              ref.read(completedChallengeIdsProvider.notifier).state = <String>{
                                ...ref.read(completedChallengeIdsProvider),
                                'mood-check',
                              };
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${selected.label} logged  |  +20 coins')),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text('Log Mood'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final MoodChoice mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: mood.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? MamaColors.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mood.icon, color: MamaColors.text, size: 22),
            const SizedBox(height: 6),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility and routing helpers

void openArticleDetail(BuildContext context, Article article) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => KnowledgeDetailPage(article: article),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(begin: const Offset(0.05, 0.02), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    ),
  );
}

void buyShopItem(BuildContext context, WidgetRef ref, ShopItem item) {
  final coins = ref.read(coinWalletProvider);
  if (coins < item.price) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not enough coins yet.')),
    );
    return;
  }
  final owned = ref.read(ownedShopItemsProvider.notifier);
  final next = <String>{...owned.state, item.id};
  owned.state = next;
  ref.read(coinWalletProvider.notifier).state = coins - item.price;
  equipShopItem(ref, item);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${item.name} purchased and equipped.')),
  );
}

void equipShopItem(WidgetRef ref, ShopItem item) {
  switch (item.slot) {
    case ShopSlot.character:
      ref.read(equippedCharacterIdProvider.notifier).state = item.id;
      break;
    case ShopSlot.outfit:
      ref.read(equippedOutfitIdProvider.notifier).state = item.id;
      break;
    case ShopSlot.furniture:
      ref.read(equippedFurnitureIdProvider.notifier).state = item.id;
      break;
  }
}

bool isEquipped(WidgetRef ref, ShopItem item) {
  return switch (item.slot) {
    ShopSlot.character => ref.watch(equippedCharacterIdProvider) == item.id,
    ShopSlot.outfit => ref.watch(equippedOutfitIdProvider) == item.id,
    ShopSlot.furniture => ref.watch(equippedFurnitureIdProvider) == item.id,
  };
}

ShopItem? _findShopItemById(String id) {
  for (final items in shopItemsBySlot.values) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
  }
  return null;
}

BlendOutcome evaluateBlend(List<String> ingredients) {
  final gValues = ingredients.map((ingredient) => ingredientGi[ingredient] ?? 45).toList();
  final average = gValues.reduce((a, b) => a + b) / gValues.length;

  if (average <= 35) {
    return const BlendOutcome(
      label: 'Low GI recipe',
      message: 'Buddy becomes happy and the blend feels gentle on glucose.',
      rewardCoins: 200,
      happinessDelta: 8,
      isHealthy: true,
    );
  }

  if (average <= 50) {
    return const BlendOutcome(
      label: 'Balanced recipe',
      message: 'A reasonable blend with a steady glucose impact.',
      rewardCoins: 120,
      happinessDelta: 4,
      isHealthy: true,
    );
  }

  return const BlendOutcome(
    label: 'High GI recipe',
    message: 'Buddy looks dizzy. This blend may spike glucose too quickly.',
    rewardCoins: 20,
    happinessDelta: -3,
    isHealthy: false,
  );
}

const ingredientOptions = <String>[
  'Green Apple',
  'Milk',
  'Spinach',
  'Chia',
  'Avocado',
  'Greek Yogurt',
  'Banana',
  'Mango',
  'Honey',
  'Peanut Butter',
];

const ingredientGi = <String, int>{
  'Green Apple': 38,
  'Milk': 34,
  'Spinach': 15,
  'Chia': 10,
  'Avocado': 15,
  'Greek Yogurt': 35,
  'Banana': 51,
  'Mango': 60,
  'Honey': 58,
  'Peanut Butter': 30,
};

String weekdayShort(int weekday) {
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return labels[(weekday - 1).clamp(0, 6)];
}

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning!';
  }
  if (hour < 17) {
    return 'Good afternoon!';
  }
  return 'Good evening!';
}

String _weekLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

void _showExportSnack(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label export is ready for later integration.')),
  );
}


