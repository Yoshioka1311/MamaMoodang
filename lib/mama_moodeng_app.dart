import 'dart:math' as math;

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void mainApp() {}

final shellIndexProvider = StateProvider<int>((ref) => 0);
final selectedMoodProvider = StateProvider<String?>((ref) => null);
final selectedMoodIdProvider = StateProvider<String?>((ref) => null);
final weeklyStreakProvider = StateProvider<int>((ref) => 7);
final coinWalletProvider = StateProvider<int>((ref) => 1280);
final latestGlucoseProvider = StateProvider<int>((ref) => 104);
final petHappinessProvider = StateProvider<int>((ref) => 82);
final buddyFoodProvider = StateProvider<int>((ref) => 82);
final buddyWaterProvider = StateProvider<int>((ref) => 67);
final buddyStatusMessageProvider = StateProvider<String>((ref) => 'Ready to blend?');
final buddyAnimationProvider = StateProvider<String>((ref) => 'idle');
final selectedShopTabProvider = StateProvider<int>((ref) => 0);
final selectedInventoryTabProvider = StateProvider<int>((ref) => 0);
final selectedLibraryCategoryProvider = StateProvider<int>((ref) => 0);
final selectedProfileGoalProvider = StateProvider<String>((ref) => profileGoals.first);
final selectedDashboardDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dashboardMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});
final calendarExpandedProvider = StateProvider<bool>((ref) => false);
final bookmarkedArticleIdsProvider = StateProvider<Set<String>>((ref) => <String>{'gdm-basics'});
final completedChallengeIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
final buddyInteractionCountProvider = StateProvider<int>((ref) => 0);
final readMedicalArticleIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
final moodHistoryProvider = StateProvider<Map<String, String>>((ref) {
  final now = DateTime.now();
  return <String, String>{
    _dateKey(now.subtract(const Duration(days: 3))): '🙂',
    _dateKey(now.subtract(const Duration(days: 2))): '😌',
    _dateKey(now.subtract(const Duration(days: 1))): '💛',
    _dateKey(now): '🌷',
  };
});
const dailySugarGoalGrams = 25.0;
final ownedShopItemsProvider = StateProvider<Set<String>>(
  (ref) => <String>{'character-aurora', 'outfit-cloud', 'furniture-willow', 'food-apple'},
);
final equippedCharacterIdProvider = StateProvider<String>((ref) => 'character-aurora');
final equippedOutfitIdProvider = StateProvider<String>((ref) => 'outfit-cloud');
final equippedFurnitureIdProvider = StateProvider<String>((ref) => 'furniture-willow');
final equippedFoodIdProvider = StateProvider<String?>((ref) => 'food-apple');
final selectedBlendIngredientsProvider = StateProvider<List<String>>(
  (ref) => <String>['Green Apple', 'Milk', 'Spinach'],
);
final mealLogsProvider = StateProvider<List<MealLogEntry>>((ref) {
  final now = DateTime.now();
  return <MealLogEntry>[
    MealLogEntry(
      id: 'meal-breakfast',
      foodName: 'Greek yogurt with berries',
      foodCategory: 'Breakfast bowl',
      mealType: MealType.breakfast,
      sugarGrams: 11,
      carbohydratesGrams: 24,
      mealTime: DateTime(now.year, now.month, now.day, 7, 40),
      notes: 'Added chia seeds and a small handful of almonds.',
    ),
    MealLogEntry(
      id: 'meal-lunch',
      foodName: 'Brown rice with grilled chicken',
      foodCategory: 'Home meal',
      mealType: MealType.lunch,
      sugarGrams: 4,
      carbohydratesGrams: 34,
      mealTime: DateTime(now.year, now.month, now.day, 12, 25),
      notes: 'Half plate vegetables first.',
    ),
    MealLogEntry(
      id: 'meal-snack',
      foodName: 'Guava slices',
      foodCategory: 'Fruit snack',
      mealType: MealType.snack,
      sugarGrams: 7,
      carbohydratesGrams: 12,
      mealTime: DateTime(now.year, now.month, now.day, 15, 10),
    ),
    MealLogEntry(
      id: 'meal-yesterday',
      foodName: 'Egg wrap with spinach',
      foodCategory: 'Breakfast bowl',
      mealType: MealType.breakfast,
      sugarGrams: 5,
      carbohydratesGrams: 19,
      mealTime: DateTime(now.year, now.month, now.day - 1, 8, 5),
      notes: 'Comfortable start with water first.',
    ),
  ];
});
final glucoseReadingsProvider = StateProvider<List<GlucoseReading>>((ref) {
  final now = DateTime.now();
  return <GlucoseReading>[
    GlucoseReading(
      id: 'glucose-1',
      value: 92,
      readingType: GlucoseReadingType.fasting,
      recordedAt: DateTime(now.year, now.month, now.day, 6, 45),
    ),
    GlucoseReading(
      id: 'glucose-2',
      value: 118,
      readingType: GlucoseReadingType.postBreakfast,
      recordedAt: DateTime(now.year, now.month, now.day, 9, 10),
    ),
    GlucoseReading(
      id: 'glucose-3',
      value: 104,
      readingType: GlucoseReadingType.postLunch,
      recordedAt: DateTime(now.year, now.month, now.day, 14, 5),
    ),
    GlucoseReading(
      id: 'glucose-4',
      value: 99,
      readingType: GlucoseReadingType.fasting,
      recordedAt: DateTime(now.year, now.month, now.day - 1, 6, 50),
    ),
    GlucoseReading(
      id: 'glucose-5',
      value: 143,
      readingType: GlucoseReadingType.postDinner,
      recordedAt: DateTime(now.year, now.month, now.day - 1, 20, 35),
    ),
    GlucoseReading(
      id: 'glucose-6',
      value: 146,
      readingType: GlucoseReadingType.postBreakfast,
      recordedAt: DateTime(now.year, now.month, now.day - 2, 9, 0),
    ),
  ];
});
final glucoseTargetsProvider = StateProvider<GlucoseTargets>((ref) => const GlucoseTargets());
final environmentalSnapshotProvider =
    AsyncNotifierProvider<EnvironmentalSnapshotNotifier, EnvironmentalSnapshot>(EnvironmentalSnapshotNotifier.new);
final autoCompletedChallengeIdsProvider = Provider<Set<String>>((ref) {
  final now = DateTime.now();
  final mealsToday = mealsForDate(ref.watch(mealLogsProvider), now);
  final moodHistory = ref.watch(moodHistoryProvider);
  final buddyInteractions = ref.watch(buddyInteractionCountProvider);
  final readArticles = ref.watch(readMedicalArticleIdsProvider);
  final totalSugarToday = mealsToday.fold<double>(0, (sum, meal) => sum + meal.sugarGrams);

  return <String>{
    if (mealsToday.isNotEmpty) 'meal-log',
    if (moodHistory.containsKey(_dateKey(now))) 'mood-check',
    if (mealsToday.isNotEmpty && totalSugarToday <= dailySugarGoalGrams) 'sugar-goal',
    if (buddyInteractions > 0) 'buddy-play',
    if (readArticles.isNotEmpty) 'library-read',
  };
});
final visibleCompletedChallengeIdsProvider = Provider<Set<String>>((ref) {
  return <String>{
    ...ref.watch(completedChallengeIdsProvider),
    ...ref.watch(autoCompletedChallengeIdsProvider),
  };
});
final profileDataProvider = StateProvider<ProfileData>((ref) => const ProfileData());
final profileNotificationSettingsProvider = StateProvider<Map<String, bool>>(
  (ref) => <String, bool>{
    'Glucose reminders': true,
    'Meal reminders': true,
    'Mood reminders': false,
    'Water reminders': true,
    'Walking reminders': true,
  },
);
final profilePrivacySettingsProvider = StateProvider<Map<String, bool>>(
  (ref) => <String, bool>{
    'Face ID / Fingerprint': true,
    'Data privacy mode': true,
  },
);
final profileAppearanceProvider = StateProvider<ProfileAppearance>((ref) => const ProfileAppearance());

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
      indicatorColor: MamaColors.primary.withValues(alpha: 0.14),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF1B2027) : const Color(0xFFF6F6F2),
      selectedColor: MamaColors.primary.withValues(alpha: 0.16),
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
      const InsightsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: pages),
      ),
      floatingActionButton: index == 4
          ? null
          : FloatingActionButton(
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
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ProviderSubscription<Set<String>>? _challengeSubscription;

  @override
  void initState() {
    super.initState();
    _challengeSubscription = ref.listenManual<Set<String>>(
      autoCompletedChallengeIdsProvider,
      (previous, next) {
        final claimed = ref.read(completedChallengeIdsProvider);
        final newlyCompleted = next.difference(claimed);
        if (newlyCompleted.isEmpty) {
          return;
        }

        final rewardTotal = homeChallenges
            .where((challenge) => newlyCompleted.contains(challenge.id))
            .fold<int>(0, (sum, challenge) => sum + challenge.rewardCoins);

        ref.read(completedChallengeIdsProvider.notifier).state = {
          ...claimed,
          ...newlyCompleted,
        };
        ref.read(coinWalletProvider.notifier).state += rewardTotal;

        if (!mounted || rewardTotal <= 0) {
          return;
        }

        final rewardTitles = homeChallenges
            .where((challenge) => newlyCompleted.contains(challenge.id))
            .map((challenge) => challenge.title)
            .join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$rewardTitles completed  |  +$rewardTotal coins'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _challengeSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final coins = ref.watch(coinWalletProvider);
    final streak = ref.watch(weeklyStreakProvider);
    final selectedMood = ref.watch(selectedMoodProvider);
    final challengeIds = ref.watch(visibleCompletedChallengeIdsProvider);
    final buddy = _findShopItemById(ref.watch(equippedCharacterIdProvider));
    final dashboardMonth = ref.watch(dashboardMonthProvider);
    final mealLogs = ref.watch(mealLogsProvider);
    final environmentalAsync = ref.watch(environmentalSnapshotProvider);

    return RefreshIndicator(
      onRefresh: () async {
        final nextGlucose = 96 + math.Random().nextInt(16);
        ref.read(latestGlucoseProvider.notifier).state = nextGlucose;
        await ref.read(environmentalSnapshotProvider.notifier).refresh();
        await Future<void>.delayed(const Duration(milliseconds: 350));
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;
                    final metricCard = MetricCard(
                      icon: Icons.casino_rounded,
                      iconColor: MamaColors.primary,
                      title: 'My Gold Coins',
                      value: '$coins',
                      subtitle: 'Reward wallet',
                    );
                    final glucoseCard = DailyGlucoseAnalysisCard(
                      selectedDate: today,
                      meals: mealsForDate(mealLogs, today),
                      onTap: () => openDailyNutritionPage(context, today),
                    );

                    return compact
                        ? Column(
                            children: [
                              metricCard,
                              const SizedBox(height: 12),
                              glucoseCard,
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: metricCard),
                              const SizedBox(width: 12),
                              Expanded(child: glucoseCard),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Environmental Alerts',
                  subtitle: 'Real-time guidance for air quality and heat',
                  trailing: TextButton(
                    onPressed: () => ref.read(shellIndexProvider.notifier).state = 3,
                    child: const Text('Open report'),
                  ),
                ),
                const SizedBox(height: 10),
                EnvironmentalAlertsPanel(
                  environmentalAsync: environmentalAsync,
                  onRetry: () => ref.read(environmentalSnapshotProvider.notifier).refresh(),
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Weekly Calendar',
                  subtitle: 'Tap to expand into a full month view with mood, meal, and glucose markers.',
                  trailing: Text(
                    _weekLabel(dashboardMonth),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: MamaColors.muted,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                const WeeklyCalendarStrip(),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Daily Challenges',
                  subtitle: 'Complete tasks to grow Buddy and earn coins',
                  trailing: Text(
                    'Auto-tracked',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: MamaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final challenge in homeChallenges)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChallengeCard(
                      challenge: challenge,
                      completed: challengeIds.contains(challenge.id),
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
    final savedArticles = articles.where((article) => bookmarkedIds.contains(article.id)).toList();

    final filtered = articles.where((article) {
      final matchesCategory = selectedCategory == 0 || article.category == libraryCategories[selectedCategory];
      final matchesQuery = articleMatchesQuery(article, _query);
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
                if (savedArticles.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Saved Articles',
                    subtitle: 'Your bookmarked medical reads stay here for quick return visits.',
                    trailing: Text(
                      '${savedArticles.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: MamaColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final article in savedArticles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ArticleListCard(
                        article: article,
                        bookmarked: true,
                        onBookmarkTap: () {
                          final state = ref.read(bookmarkedArticleIdsProvider.notifier);
                          final next = <String>{...state.state};
                          next.remove(article.id);
                          state.state = next;
                        },
                        onTap: () => openArticleDetail(context, article),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Recommended for You',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: appMutedColor(context),
                      ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filtered.isEmpty
                      ? EmptyArticlesState(key: ValueKey<String>('empty-$_query-$selectedCategory'), query: _query)
                      : Column(
                          key: ValueKey<String>('results-$_query-$selectedCategory'),
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
  const PetCafeGamePage({
    super.key,
    this.openShopOnEntry = false,
  });

  final bool openShopOnEntry;

  @override
  ConsumerState<PetCafeGamePage> createState() => _PetCafeGamePageState();
}

class _PetCafeGamePageState extends ConsumerState<PetCafeGamePage> {
  String _status = 'Ready to blend?';
  int _rewardPreview = 0;
  bool _didOpenEntryShop = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.openShopOnEntry && !_didOpenEntryShop) {
      _didOpenEntryShop = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        showBuddyShopSheet(context, ref);
      });
    }
  }

  Future<void> _openBuddyShop() async {
    await showBuddyShopSheet(context, ref);
  }

  void _tapBuddy() {
    final nextAnimation = switch (ref.read(buddyAnimationProvider)) {
      'idle' => 'wave',
      'wave' => 'jump',
      'jump' => 'dance',
      'dance' => 'idle',
      'hug' => 'wave',
      'eat' => 'dance',
      'drink' => 'wave',
      _ => 'wave',
    };
    ref.read(buddyAnimationProvider.notifier).state = nextAnimation;
    ref.read(buddyInteractionCountProvider.notifier).state++;
    ref.read(buddyStatusMessageProvider.notifier).state = switch (nextAnimation) {
      'wave' => 'Buddy waves back at you.',
      'jump' => 'Buddy jumps with excitement.',
      'dance' => 'Buddy starts a tiny dance.',
      _ => 'Buddy looks cozy and calm.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final coinBalance = ref.watch(coinWalletProvider);
    final glucose = ref.watch(latestGlucoseProvider);
    final happiness = ref.watch(petHappinessProvider);
    final food = ref.watch(buddyFoodProvider);
    final water = ref.watch(buddyWaterProvider);
    final currentMoodId = ref.watch(selectedMoodIdProvider);
    final buddyStatusMessage = ref.watch(buddyStatusMessageProvider);
    final buddyAnimation = ref.watch(buddyAnimationProvider);
    final moodLoggedToday = ref.watch(moodHistoryProvider).containsKey(_dateKey(DateTime.now()));
    final selectedTab = ref.watch(petCafeTabProvider);
    final ingredientChoices = ref.watch(selectedBlendIngredientsProvider);
    final result = evaluateBlend(ingredientChoices);
    final expressionAccent = buddyExpressionColor(currentMoodId, buddyAnimation);
    final expressionIcon = buddyExpressionIcon(currentMoodId, buddyAnimation);
    final expressionLabel = buddyExpressionLabel(currentMoodId, buddyAnimation);
    final ownedInventory = ref.watch(ownedShopItemsProvider);
    final selectedInventoryTab = ref.watch(selectedInventoryTabProvider);
    final inventoryItems = buddyCafeShopItemsForIndex(selectedInventoryTab)
        .where((item) => ownedInventory.contains(item.id))
        .toList();
    final equippedFood = ref.watch(equippedFoodIdProvider);
    final equippedFurniture = _findShopItemById(ref.watch(equippedFurnitureIdProvider));
    final equippedOutfit = _findShopItemById(ref.watch(equippedOutfitIdProvider));
    final activeSnack = equippedFood == null ? null : _findShopItemById(equippedFood);

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
                                color: appMutedColor(context),
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
                            StatPill(icon: Icons.casino_rounded, label: '$coinBalance coins'),
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
                            color: equippedFurniture?.colors.last.withValues(alpha: 0.38) ?? Colors.white.withValues(alpha: 0.24),
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
                            GestureDetector(
                              onTap: _tapBuddy,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  color: MamaColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: expressionAccent.withValues(alpha: 0.24),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  expressionIcon,
                                  size: 56,
                                  color: expressionAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              expressionLabel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF313645),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              buddyStatusMessage,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF565E70),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            if (equippedOutfit != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  equippedOutfit.name,
                                  style: const TextStyle(
                                    color: Color(0xFF303542),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 24,
                        child: FloatingActionButton.small(
                          heroTag: widget.openShopOnEntry ? 'buddy-shop-entry-fab' : 'buddy-shop-fab',
                          backgroundColor: MamaColors.primary,
                          foregroundColor: Colors.white,
                          onPressed: _openBuddyShop,
                          child: const Icon(Icons.storefront_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: BuddyNeedBar(
                      label: 'Food',
                      value: food,
                      accent: MamaColors.sun,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BuddyNeedBar(
                      label: 'Water',
                      value: water,
                      accent: MamaColors.sky,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BuddyNeedBar(
                      label: 'Happiness',
                      value: happiness,
                      accent: MamaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!moodLoggedToday)
                SoftCard(
                  color: const Color(0xFFFFF7FA),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: MamaColors.primary.withValues(alpha: 0.14),
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: MamaColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buddy asks: How are you feeling today?',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2F3441),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A quick mood check-in helps Buddy respond more personally.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF687184),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () => showMoodSheet(context, ref),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Open'),
                      ),
                    ],
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
                                    color: const Color(0xFF676D7C),
                                    fontWeight: FontWeight.w700,
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
                                    color: const Color(0xFF676D7C),
                                    height: 1.4,
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
                          ref.read(buddyInteractionCountProvider.notifier).state++;
                          ref.read(buddyFoodProvider.notifier).state = (ref.read(buddyFoodProvider) + 8).clamp(0, 100).toInt();
                          ref.read(buddyAnimationProvider.notifier).state = outcome.isHealthy ? 'dance' : 'wave';
                          ref.read(buddyStatusMessageProvider.notifier).state =
                              outcome.isHealthy ? 'Buddy dances after a healthy blend.' : 'Buddy still enjoyed the cafe moment.';
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
                                color: appMutedColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox.shrink(),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: appMutedColor(context)),
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Inventory',
                  subtitle: 'Switch between the items Buddy already owns and use them instantly here.',
                ),
                const SizedBox(height: 12),
                SegmentTabs(
                  labels: buddyCafeShopLabels,
                  selectedIndex: selectedInventoryTab,
                  onChanged: (value) => ref.read(selectedInventoryTabProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                if (activeSnack != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      color: const Color(0xFFFFF7FA),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: MamaColors.sun.withValues(alpha: 0.18),
                            child: Icon(activeSnack.icon, color: MamaColors.sun),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buddy\'s active snack',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: appMutedColor(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeSnack.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: const Color(0xFF2E3441),
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (inventoryItems.isEmpty)
                  SoftCard(
                    child: Text(
                      'Only purchased items appear here. Open the Buddy Shop bubble to collect more items.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appMutedColor(context),
                            height: 1.45,
                          ),
                    ),
                  )
                else
                  for (final item in inventoryItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BuddyInventoryCard(
                        item: item,
                        equipped: isEquipped(ref, item),
                        onUse: () => equipShopItem(ref, item),
                      ),
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
                          color: appTextColor(context),
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
                          childAspectRatio: constraints.maxWidth > 560 ? 0.82 : 0.72,
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
                          childAspectRatio: constraints.maxWidth > 560 ? 0.82 : 0.72,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: appMutedColor(context)),
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

class DailyNutritionPage extends ConsumerWidget {
  const DailyNutritionPage({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMeals = ref.watch(mealLogsProvider);
    final meals = mealsForDate(allMeals, initialDate);
    final totalSugar = meals.fold<double>(0, (sum, meal) => sum + meal.sugarGrams);
    final totalCarbs = meals.fold<double>(0, (sum, meal) => sum + meal.carbohydratesGrams);
    final status = estimateNutritionStatus(meals);
    final consistentHighTrend = hasConsistentlyHighNutritionTrend(allMeals);
    final guidance = nutritionGuidance(status);
    final statusColor = nutritionStatusColor(status);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Daily Nutrition',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'History',
                        onPressed: () => openFoodHistoryPage(context, initialDate),
                        icon: const Icon(Icons.history_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _calendarHeaderLabel(initialDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: appMutedColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Daily Summary',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _NutritionSummaryTile(label: 'Total Sugar', value: '${totalSugar.toStringAsFixed(totalSugar % 1 == 0 ? 0 : 1)} g'),
                            _NutritionSummaryTile(
                              label: 'Total Carbs',
                              value: '${totalCarbs.toStringAsFixed(totalCarbs % 1 == 0 ? 0 : 1)} g',
                            ),
                            _NutritionSummaryTile(label: 'Total Meals', value: '${meals.length}'),
                            _NutritionSummaryTile(
                              label: 'Estimated Status',
                              value: nutritionStatusLabel(status),
                              accent: statusColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    color: statusColor.withValues(alpha: 0.09),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Daily Glucose Status',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nutritionStatusLabel(status),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                        ),
                        const SizedBox(height: 10),
                        for (final line in guidance)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(Icons.circle, size: 7, color: MamaColors.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    line,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: appMutedColor(context),
                                          height: 1.45,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (consistentHighTrend) ...[
                          const SizedBox(height: 6),
                          Text(
                            'This pattern has looked high across recent days. Consider contacting your healthcare provider for further guidance.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: MamaColors.coral,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => showMealLogSheet(context, ref, initialDate: DateTime.now()),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Food Entry'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'Today\'s Meals',
                    subtitle: meals.isEmpty ? 'No meals logged yet.' : 'A simple food diary for the day.',
                    trailing: TextButton(
                      onPressed: () => openFoodHistoryPage(context, initialDate),
                      child: const Text('History'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (meals.isEmpty)
                    SoftCard(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1F27)
                          : const Color(0xFFF9F8F2),
                      child: Text(
                        'Add your first food entry to start building today\'s nutrition summary.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appMutedColor(context),
                              height: 1.45,
                            ),
                      ),
                    )
                  else
                    for (final meal in meals.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MealHistoryCard(meal: meal),
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

class FoodHistoryPage extends ConsumerStatefulWidget {
  const FoodHistoryPage({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  ConsumerState<FoodHistoryPage> createState() => _FoodHistoryPageState();
}

class _FoodHistoryPageState extends ConsumerState<FoodHistoryPage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2026, 7, 16),
    );
    if (picked == null) return;
    setState(() {
      selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allMeals = ref.watch(mealLogsProvider);
    final meals = mealsForDate(allMeals, selectedDate);
    final totalSugar = meals.fold<double>(0, (sum, meal) => sum + meal.sugarGrams);
    final totalCarbs = meals.fold<double>(0, (sum, meal) => sum + meal.carbohydratesGrams);
    final status = estimateNutritionStatus(meals);
    final statusColor = nutritionStatusColor(status);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Food History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(_calendarHeaderLabel(selectedDate)),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _NutritionSummaryTile(label: 'Total Sugar', value: '${totalSugar.toStringAsFixed(totalSugar % 1 == 0 ? 0 : 1)} g'),
                        _NutritionSummaryTile(label: 'Total Carbs', value: '${totalCarbs.toStringAsFixed(totalCarbs % 1 == 0 ? 0 : 1)} g'),
                        _NutritionSummaryTile(label: 'Meal Count', value: '${meals.length}'),
                        _NutritionSummaryTile(
                          label: 'Estimated Status',
                          value: nutritionStatusLabel(status),
                          accent: statusColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'Meals',
                    subtitle: meals.isEmpty ? 'No meals were logged for this day.' : 'Meals, notes, and optional photos for the selected day.',
                  ),
                  const SizedBox(height: 12),
                  if (meals.isEmpty)
                    SoftCard(
                      child: Text(
                        'No food entries were found for this day.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appMutedColor(context),
                            ),
                      ),
                    )
                  else
                    for (final meal in meals.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MealHistoryCard(meal: meal),
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

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileDataProvider);
    final coins = ref.watch(coinWalletProvider);
    final glucose = ref.watch(latestGlucoseProvider);
    final happiness = ref.watch(petHappinessProvider);
    final streak = ref.watch(weeklyStreakProvider);
    final completedTasks = ref.watch(visibleCompletedChallengeIdsProvider).length;
    final selectedGoal = ref.watch(selectedProfileGoalProvider);

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
                'My Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'A calm place for your goals, care preferences, and trusted health settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted),
              ),
              const SizedBox(height: 18),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 18),
                      child: child,
                    ),
                  );
                },
                child: ProfileHeaderCard(
                  profile: profile,
                  onEditTap: () => Navigator.of(context).push(
                    _buildProfileRoute(
                      ProfileEditableFormPage(
                        title: 'Personal Information',
                        description: 'Update the essentials so Buddy can personalize your experience.',
                        initialValues: profile.personalInformation,
                        icon: Icons.badge_rounded,
                        onSave: (values) {
                          ref.read(profileDataProvider.notifier).state = profile.copyWith(
                            fullName: values['Name'] ?? profile.fullName,
                            birthday: values['Birthday'] ?? profile.birthday,
                            pregnancyWeek: values['Pregnancy week'] ?? profile.pregnancyWeek,
                            dueDate: values['Due date'] ?? profile.dueDate,
                            height: values['Height'] ?? profile.height,
                            weight: values['Weight'] ?? profile.weight,
                            emergencyContact: values['Emergency contact'] ?? profile.emergencyContact,
                          );
                        },
                      ),
                    ),
                  ),
                  onUpgradeTap: () {
                    ref.read(profileDataProvider.notifier).state = profile.copyWith(isPremium: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Premium preview enabled for your profile.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Health Snapshot',
                subtitle: 'A quick glance at the details that matter most this week.',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ProfileStatCard(
                        width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                        icon: Icons.local_fire_department_rounded,
                        accent: MamaColors.coral,
                        title: 'Current streak',
                        value: '$streak days',
                        subtitle: 'Steady momentum',
                      ),
                      ProfileStatCard(
                        width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                        icon: Icons.favorite_rounded,
                        accent: MamaColors.primary,
                        title: 'Buddy Happiness',
                        value: '$happiness%',
                        subtitle: 'Warm and supported',
                      ),
                      ProfileStatCard(
                        width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                        icon: Icons.casino_rounded,
                        accent: MamaColors.sun,
                        title: 'Gold Coins',
                        value: '$coins',
                        subtitle: 'Reward wallet',
                      ),
                      ProfileStatCard(
                        width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                        icon: Icons.opacity_rounded,
                        accent: MamaColors.sky,
                        title: 'Avg glucose',
                        value: '$glucose mg/dL',
                        subtitle: 'This week',
                      ),
                      ProfileStatCard(
                        width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                        icon: Icons.task_alt_rounded,
                        accent: MamaColors.lavender,
                        title: 'Tasks completed',
                        value: '$completedTasks',
                        subtitle: 'Daily wins',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'My Goal Focus',
                subtitle: 'Choose the one theme you want Buddy to prioritize right now.',
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final goal in profileGoals)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GoalChoiceChip(
                          label: goal,
                          selected: goal == selectedGoal,
                          onTap: () => ref.read(selectedProfileGoalProvider.notifier).state = goal,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Account & Wellness',
                subtitle: 'Everything important lives here, organized with a lighter touch.',
              ),
              const SizedBox(height: 12),
              ProfileSectionCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    subtitle: 'Name, birthday, pregnancy week, due date, height, weight, and emergency contact',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(
                        ProfileEditableFormPage(
                          title: 'Personal Information',
                          description: 'Keep your profile details current so the experience stays relevant.',
                          initialValues: profile.personalInformation,
                          icon: Icons.person_outline_rounded,
                          heroTag: 'profile-avatar',
                          onSave: (values) {
                            ref.read(profileDataProvider.notifier).state = profile.copyWith(
                              fullName: values['Name'] ?? profile.fullName,
                              birthday: values['Birthday'] ?? profile.birthday,
                              pregnancyWeek: values['Pregnancy week'] ?? profile.pregnancyWeek,
                              dueDate: values['Due date'] ?? profile.dueDate,
                              height: values['Height'] ?? profile.height,
                              weight: values['Weight'] ?? profile.weight,
                              emergencyContact: values['Emergency contact'] ?? profile.emergencyContact,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.medical_information_outlined,
                    title: 'Medical Information',
                    subtitle: 'Diabetes history, medication, glucose targets, and doctor information',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(
                        ProfileEditableFormPage(
                          title: 'Medical Information',
                          description: 'These details help the app stay medically grounded and more helpful.',
                          initialValues: profile.medicalInformation,
                          icon: Icons.medical_information_outlined,
                          onSave: (values) {
                            ref.read(profileDataProvider.notifier).state = profile.copyWith(
                              diabetesHistory: values['Diabetes history'] ?? profile.diabetesHistory,
                              medication: values['Medication'] ?? profile.medication,
                              glucoseTargets: values['Blood glucose targets'] ?? profile.glucoseTargets,
                              doctorInformation: values['Doctor information'] ?? profile.doctorInformation,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Settings',
                    subtitle: 'Glucose, meal, mood, water, and walking reminders',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const ProfileToggleSettingsPage()),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy & Security',
                    subtitle: 'Password, biometrics, privacy mode, and account controls',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const ProfilePrivacyPage()),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Theme, font size, and language preferences',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const ProfileAppearancePage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProfileSectionCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.insights_rounded,
                    title: 'Health Report',
                    subtitle: 'Jump to medical analytics and your doctor-friendly summaries',
                    onTap: () => ref.read(shellIndexProvider.notifier).state = 3,
                  ),
                  ProfileMenuTile(
                    icon: Icons.timelapse_rounded,
                    title: 'Pregnancy Timeline',
                    subtitle: 'Review milestones and upcoming gentle reminders',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const PregnancyTimelinePage()),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.pets_rounded,
                    title: 'Buddy Customization',
                    subtitle: 'Open the shop to style your Buddy, outfit, and furniture',
                    onTap: () => ref.read(shellIndexProvider.notifier).state = 2,
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Achievements',
                    subtitle: 'Celebrate earned badges, streaks, and healthy milestones',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const AchievementsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PremiumMembershipCard(
                isPremium: profile.isPremium,
                onTap: () {
                  ref.read(profileDataProvider.notifier).state = profile.copyWith(isPremium: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Premium preview has been unlocked.')),
                  );
                },
              ),
              const SizedBox(height: 12),
              ProfileSectionCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact support, terms, privacy policy, and about',
                    onTap: () => Navigator.of(context).push(
                      _buildProfileRoute(const ProfileSupportPage()),
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out safely from this device',
                    danger: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout flow is ready for secure backend integration.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileEditableFormPage extends StatefulWidget {
  const ProfileEditableFormPage({
    super.key,
    required this.title,
    required this.description,
    required this.initialValues,
    required this.icon,
    required this.onSave,
    this.heroTag,
  });

  final String title;
  final String description;
  final Map<String, String> initialValues;
  final IconData icon;
  final ValueChanged<Map<String, String>> onSave;
  final String? heroTag;

  @override
  State<ProfileEditableFormPage> createState() => _ProfileEditableFormPageState();
}

class _ProfileEditableFormPageState extends State<ProfileEditableFormPage> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      for (final entry in widget.initialValues.entries) entry.key: TextEditingController(text: entry.value),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    color: const Color(0xFFFFF8FB),
                    child: Row(
                      children: [
                        if (widget.heroTag != null)
                          Hero(
                            tag: widget.heroTag!,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: MamaColors.primary.withValues(alpha: 0.12),
                              child: Icon(widget.icon, color: MamaColors.primary),
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: MamaColors.primary.withValues(alpha: 0.12),
                            child: Icon(widget.icon, color: MamaColors.primary),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: MamaColors.muted,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final entry in _controllers.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: entry.key,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      widget.onSave(
                        <String, String>{
                          for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
                        },
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.title} updated.')),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save Changes'),
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

class ProfileToggleSettingsPage extends ConsumerWidget {
  const ProfileToggleSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileNotificationSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Notification Settings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    color: const Color(0xFFFFF8FB),
                    child: Text(
                      'Keep reminders soft, timely, and helpful so your daily routine feels supported instead of noisy.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileSectionCard(
                    children: [
                      for (final entry in settings.entries)
                        Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            value: entry.value,
                            onChanged: (value) {
                              final next = <String, bool>{...settings, entry.key: value};
                              ref.read(profileNotificationSettingsProvider.notifier).state = next;
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: MamaColors.primary,
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              'Gentle reminders for ${entry.key.toLowerCase()}.',
                              style: const TextStyle(color: MamaColors.muted),
                            ),
                          ),
                        ),
                    ],
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

class ProfilePrivacyPage extends ConsumerWidget {
  const ProfilePrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggles = ref.watch(profilePrivacySettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Privacy & Security',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProfileSectionCard(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.password_rounded,
                        title: 'Change password',
                        subtitle: 'Prepare a stronger password for your account',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password flow is ready for secure backend integration.')),
                          );
                        },
                      ),
                      for (final entry in toggles.entries)
                        Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            value: entry.value,
                            onChanged: (value) {
                              ref.read(profilePrivacySettingsProvider.notifier).state = <String, bool>{
                                ...toggles,
                                entry.key: value,
                              };
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: MamaColors.primary,
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: const Text(
                              'Keep your personal health information protected on this device.',
                              style: TextStyle(color: MamaColors.muted),
                            ),
                          ),
                        ),
                      ProfileMenuTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete account',
                        subtitle: 'A protected action that should always require confirmation',
                        danger: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delete account requires secure confirmation in a future backend flow.')),
                          );
                        },
                      ),
                    ],
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

class ProfileAppearancePage extends ConsumerWidget {
  const ProfileAppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(profileAppearanceProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    color: const Color(0xFFFFF8FB),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final option in appearanceThemeOptions)
                              GoalChoiceChip(
                                label: option,
                                selected: option == appearance.themeLabel,
                                onTap: () => ref.read(profileAppearanceProvider.notifier).state = appearance.copyWith(themeLabel: option),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Font size',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Slider(
                          min: 0.9,
                          max: 1.2,
                          divisions: 3,
                          activeColor: MamaColors.primary,
                          value: appearance.fontScale,
                          onChanged: (value) {
                            ref.read(profileAppearanceProvider.notifier).state = appearance.copyWith(fontScale: value);
                          },
                        ),
                        Text(
                          'Current scale: ${appearance.fontScale.toStringAsFixed(2)}x',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Language',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final option in appearanceLanguageOptions)
                              GoalChoiceChip(
                                label: option,
                                selected: option == appearance.languageLabel,
                                onTap: () => ref.read(profileAppearanceProvider.notifier).state = appearance.copyWith(languageLabel: option),
                              ),
                          ],
                        ),
                      ],
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

class PregnancyTimelinePage extends StatelessWidget {
  const PregnancyTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Pregnancy Timeline',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final milestone in pregnancyMilestones)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        color: milestone.color.withValues(alpha: 0.16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: milestone.color.withValues(alpha: 0.22),
                              child: Icon(milestone.icon, color: milestone.color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestone.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestone.subtitle,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.primary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    milestone.body,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MamaColors.muted, height: 1.45),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Achievements',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 520 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profileAchievements.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.92,
                        ),
                        itemBuilder: (context, index) {
                          final achievement = profileAchievements[index];
                          return SoftCard(
                            color: achievement.color.withValues(alpha: 0.14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: achievement.color.withValues(alpha: 0.20),
                                  child: Icon(achievement.icon, color: achievement.color),
                                ),
                                const Spacer(),
                                Text(
                                  achievement.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  achievement.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted, height: 1.4),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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

class ProfileSupportPage extends StatelessWidget {
  const ProfileSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
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
                      Expanded(
                        child: Text(
                          'Help & Support',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProfileSectionCard(
                    children: [
                      for (final item in supportMenuItems)
                        ProfileMenuTile(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.title} is ready for content or API integration.')),
                            );
                          },
                        ),
                    ],
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

PageRouteBuilder<void> _buildProfileRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(begin: const Offset(0.03, 0.02), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}

class KnowledgeDetailPage extends ConsumerStatefulWidget {
  const KnowledgeDetailPage({super.key, required this.article});

  final Article article;

  @override
  ConsumerState<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends ConsumerState<KnowledgeDetailPage> {
  Timer? _readTimer;

  @override
  void initState() {
    super.initState();
    _readTimer = Timer(const Duration(minutes: 3), () {
      if (!mounted) {
        return;
      }
      final readIds = ref.read(readMedicalArticleIdsProvider);
      if (readIds.contains(widget.article.id)) {
        return;
      }
      ref.read(readMedicalArticleIdsProvider.notifier).state = {
        ...readIds,
        widget.article.id,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading milestone reached: 3 minutes completed.')),
      );
    });
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarked = ref.watch(bookmarkedArticleIdsProvider).contains(widget.article.id);

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
                          if (next.contains(widget.article.id)) {
                            next.remove(widget.article.id);
                          } else {
                            next.add(widget.article.id);
                          }
                          state.state = next;
                        },
                        icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Hero(
                    tag: 'article-hero-${widget.article.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 260,
                            width: double.infinity,
                            child: _NetworkHeroImage(
                              url: widget.article.heroImageUrl,
                              fallback: widget.article.heroStops,
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
                                widget.article.title,
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
                    widget.article.title,
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
                        label: estimatedReadTime(widget.article),
                      ),
                      BadgePill(
                        icon: Icons.verified_rounded,
                        label: 'Medically Reviewed',
                        iconColor: MamaColors.primary,
                      ),
                      BadgePill(
                        icon: Icons.bookmark_rounded,
                        label: widget.article.category,
                        iconColor: MamaColors.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.article.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.65,
                          color: appMutedColor(context),
                        ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1F28) : const Color(0xFFFFF7FA),
                    child: Text(
                      'This guide is educational support for everyday decision-making. It should not replace personalized advice from your doctor, diabetes educator, or maternity care team.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appMutedColor(context),
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final block in widget.article.blocks) ...[
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
                  for (final related in articles.where((item) => item.id != widget.article.id && item.category == widget.article.category).take(3))
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
  static const background = Color(0xFFFBF6F8);
  static const surface = Color(0xFFFFFCFD);
  static const text = Color(0xFF202225);
  static const muted = Color(0xFF7A8394);
  static const border = Color(0xFFF0E5EA);
  static const primary = Color(0xFFFF8FAB);
  static const mint = Color(0xFFFFEAF0);
  static const blush = Color(0xFFFFD8E4);
  static const coral = Color(0xFFF46C97);
  static const peach = Color(0xFFFFE1D2);
  static const sky = Color(0xFFD9ECFB);
  static const lavender = Color(0xFFEEE3FB);
  static const sun = Color(0xFFFFC96B);
}

enum ShopSlot { food, character, outfit, furniture }

enum ArticleBlockType { tip, warning, note }

class ProfileData {
  const ProfileData({
    this.fullName = 'Nisa K.',
    this.birthday = 'June 12, 1995',
    this.pregnancyWeek = 'Week 28',
    this.dueDate = 'October 5, 2026',
    this.height = '162 cm',
    this.weight = '66 kg',
    this.emergencyContact = 'Arthit  |  +66 89 000 0000',
    this.diabetesHistory = 'Gestational diabetes diagnosed this trimester',
    this.medication = 'Prenatal vitamins and doctor-advised insulin monitoring',
    this.glucoseTargets = 'Fasting < 95 mg/dL, 1-hour post meal < 140 mg/dL',
    this.doctorInformation = 'Dr. Pimchanok  |  Bangkok Women Care Clinic',
    this.motivation = "You're doing amazing today, Mom.",
    this.isPremium = false,
  });

  final String fullName;
  final String birthday;
  final String pregnancyWeek;
  final String dueDate;
  final String height;
  final String weight;
  final String emergencyContact;
  final String diabetesHistory;
  final String medication;
  final String glucoseTargets;
  final String doctorInformation;
  final String motivation;
  final bool isPremium;

  Map<String, String> get personalInformation => <String, String>{
        'Name': fullName,
        'Birthday': birthday,
        'Pregnancy week': pregnancyWeek,
        'Due date': dueDate,
        'Height': height,
        'Weight': weight,
        'Emergency contact': emergencyContact,
      };

  Map<String, String> get medicalInformation => <String, String>{
        'Diabetes history': diabetesHistory,
        'Medication': medication,
        'Blood glucose targets': glucoseTargets,
        'Doctor information': doctorInformation,
      };

  ProfileData copyWith({
    String? fullName,
    String? birthday,
    String? pregnancyWeek,
    String? dueDate,
    String? height,
    String? weight,
    String? emergencyContact,
    String? diabetesHistory,
    String? medication,
    String? glucoseTargets,
    String? doctorInformation,
    String? motivation,
    bool? isPremium,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      birthday: birthday ?? this.birthday,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      dueDate: dueDate ?? this.dueDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      diabetesHistory: diabetesHistory ?? this.diabetesHistory,
      medication: medication ?? this.medication,
      glucoseTargets: glucoseTargets ?? this.glucoseTargets,
      doctorInformation: doctorInformation ?? this.doctorInformation,
      motivation: motivation ?? this.motivation,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class ProfileAppearance {
  const ProfileAppearance({
    this.themeLabel = 'System',
    this.languageLabel = 'English',
    this.fontScale = 1.0,
  });

  final String themeLabel;
  final String languageLabel;
  final double fontScale;

  ProfileAppearance copyWith({
    String? themeLabel,
    String? languageLabel,
    double? fontScale,
  }) {
    return ProfileAppearance(
      themeLabel: themeLabel ?? this.themeLabel,
      languageLabel: languageLabel ?? this.languageLabel,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

class PregnancyMilestone {
  const PregnancyMilestone({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final Color color;
}

class AchievementBadge {
  const AchievementBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class SupportMenuItem {
  const SupportMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

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
    required this.reviewed,
    required this.heroImageUrl,
    required this.heroStops,
    required this.keywords,
    required this.body,
    required this.blocks,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final bool reviewed;
  final String heroImageUrl;
  final List<Color> heroStops;
  final List<String> keywords;
  final String body;
  final List<ArticleBlock> blocks;
}

enum MealType { breakfast, lunch, dinner, snack }

enum GlucoseReadingType { fasting, postBreakfast, postLunch, postDinner, bedtime }

enum GlucoseBand { withinTarget, slightlyAboveTarget, aboveTarget, significantlyAboveTarget }

enum NutritionStatus { normal, slightlyHigh, high, veryHigh }

class MealLogEntry {
  const MealLogEntry({
    required this.id,
    required this.foodName,
    required this.foodCategory,
    required this.mealType,
    required this.sugarGrams,
    required this.carbohydratesGrams,
    required this.mealTime,
    this.photoUrl,
    this.notes,
    this.linkedGlucoseReading,
  });

  final String id;
  final String foodName;
  final String foodCategory;
  final MealType mealType;
  final double sugarGrams;
  final double carbohydratesGrams;
  final DateTime mealTime;
  final String? photoUrl;
  final String? notes;
  final double? linkedGlucoseReading;
}

class GlucoseReading {
  const GlucoseReading({
    required this.id,
    required this.value,
    required this.readingType,
    required this.recordedAt,
  });

  final String id;
  final int value;
  final GlucoseReadingType readingType;
  final DateTime recordedAt;
}

class GlucoseTargets {
  const GlucoseTargets({
    this.fastingUpper = 95,
    this.postMealUpper = 140,
    this.slightlyAboveMargin = 10,
    this.significantAboveMargin = 25,
  });

  final int fastingUpper;
  final int postMealUpper;
  final int slightlyAboveMargin;
  final int significantAboveMargin;
}

class EnvironmentalSnapshot {
  const EnvironmentalSnapshot({
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.heatIndexC,
    required this.uvIndex,
    required this.pm25,
    required this.aqi,
    required this.weatherLabel,
    required this.pmCategory,
    required this.summaryMessage,
    required this.recommendation,
    required this.updatedAt,
    required this.locationLabel,
    this.permissionMessage,
  });

  final double latitude;
  final double longitude;
  final double temperatureC;
  final double feelsLikeC;
  final double humidity;
  final double heatIndexC;
  final double uvIndex;
  final double pm25;
  final int aqi;
  final String weatherLabel;
  final String pmCategory;
  final String summaryMessage;
  final String recommendation;
  final DateTime updatedAt;
  final String locationLabel;
  final String? permissionMessage;

  factory EnvironmentalSnapshot.fallback({String? message}) {
    return EnvironmentalSnapshot(
      latitude: 13.7563,
      longitude: 100.5018,
      temperatureC: 31.7,
      feelsLikeC: 36.1,
      humidity: 71,
      heatIndexC: 38.2,
      uvIndex: 8.4,
      pm25: 42.8,
      aqi: 112,
      weatherLabel: 'Warm and humid',
      pmCategory: 'Unhealthy for Sensitive Groups',
      summaryMessage: 'Location access or network is unavailable right now, so the app is showing the latest safe cached guidance.',
      recommendation:
          'Drink water regularly, prefer cooler indoor spaces, and consider contacting your care team if you feel dizzy, short of breath, or unusually weak.',
      updatedAt: DateTime.now(),
      locationLabel: 'Cached guidance',
      permissionMessage: message,
    );
  }

  EnvironmentalSnapshot copyWith({
    String? recommendation,
    String? summaryMessage,
    String? permissionMessage,
    String? locationLabel,
    DateTime? updatedAt,
  }) {
    return EnvironmentalSnapshot(
      latitude: latitude,
      longitude: longitude,
      temperatureC: temperatureC,
      feelsLikeC: feelsLikeC,
      humidity: humidity,
      heatIndexC: heatIndexC,
      uvIndex: uvIndex,
      pm25: pm25,
      aqi: aqi,
      weatherLabel: weatherLabel,
      pmCategory: pmCategory,
      summaryMessage: summaryMessage ?? this.summaryMessage,
      recommendation: recommendation ?? this.recommendation,
      updatedAt: updatedAt ?? this.updatedAt,
      locationLabel: locationLabel ?? this.locationLabel,
      permissionMessage: permissionMessage ?? this.permissionMessage,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'latitude': latitude,
      'longitude': longitude,
      'temperatureC': temperatureC,
      'feelsLikeC': feelsLikeC,
      'humidity': humidity,
      'heatIndexC': heatIndexC,
      'uvIndex': uvIndex,
      'pm25': pm25,
      'aqi': aqi,
      'weatherLabel': weatherLabel,
      'pmCategory': pmCategory,
      'summaryMessage': summaryMessage,
      'recommendation': recommendation,
      'updatedAt': updatedAt.toIso8601String(),
      'locationLabel': locationLabel,
      'permissionMessage': permissionMessage,
    };
  }

  factory EnvironmentalSnapshot.fromJson(Map<String, dynamic> json) {
    return EnvironmentalSnapshot(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperatureC: (json['temperatureC'] as num).toDouble(),
      feelsLikeC: (json['feelsLikeC'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      heatIndexC: (json['heatIndexC'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      pm25: (json['pm25'] as num).toDouble(),
      aqi: (json['aqi'] as num).toInt(),
      weatherLabel: json['weatherLabel'] as String,
      pmCategory: json['pmCategory'] as String,
      summaryMessage: json['summaryMessage'] as String,
      recommendation: json['recommendation'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      locationLabel: json['locationLabel'] as String,
      permissionMessage: json['permissionMessage'] as String?,
    );
  }
}

class EnvironmentalSnapshotNotifier extends AsyncNotifier<EnvironmentalSnapshot> {
  static const _cacheKey = 'dashboard_environment_snapshot_v1';

  @override
  Future<EnvironmentalSnapshot> build() async {
    return _loadSnapshot(useCacheOnFailure: true);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadSnapshot(useCacheOnFailure: true));
  }

  Future<EnvironmentalSnapshot> _loadSnapshot({required bool useCacheOnFailure}) async {
    final prefs = await SharedPreferences.getInstance();
    EnvironmentalSnapshot? cached;

    final cachedRaw = prefs.getString(_cacheKey);
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        cached = EnvironmentalSnapshot.fromJson(jsonDecode(cachedRaw) as Map<String, dynamic>);
      } catch (_) {
        cached = null;
      }
    }

    try {
      final position = await _resolveCurrentPosition();
      final snapshot = await _fetchEnvironmentalSnapshot(position);
      await prefs.setString(_cacheKey, jsonEncode(snapshot.toJson()));
      return snapshot;
    } catch (error) {
      final friendlyMessage = friendlyEnvironmentMessage(error);
      if (cached != null && useCacheOnFailure) {
        return cached.copyWith(
          summaryMessage: 'Showing the latest cached environmental guidance because live data could not be refreshed just now.',
          permissionMessage: friendlyMessage,
          updatedAt: cached.updatedAt,
        );
      }
      return EnvironmentalSnapshot.fallback(message: friendlyMessage);
    }
  }
}

Color appTextColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF4F6F8) : MamaColors.text;
}

Color appMutedColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB8C0CF) : MamaColors.muted;
}

String estimatedReadTime(Article article) {
  final segments = <String>[
    article.title,
    article.category,
    article.summary,
    article.body,
    ...article.keywords,
    for (final block in article.blocks) block.title,
    for (final block in article.blocks) block.body,
  ];
  final words = segments
      .join(' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.trim().isNotEmpty)
      .length;
  final minutes = math.max(1, (words / 200).ceil());
  return '$minutes min read';
}

bool articleMatchesQuery(Article article, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }

  final haystack = <String>[
    article.title,
    article.category,
    article.summary,
    article.body,
    ...article.keywords,
    for (final block in article.blocks) block.title,
    for (final block in article.blocks) block.body,
  ].join(' ').toLowerCase();

  return haystack.contains(normalized);
}

String mealTypeLabel(MealType type) {
  return switch (type) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
  };
}

NutritionStatus? estimateNutritionStatus(List<MealLogEntry> meals) {
  if (meals.isEmpty) {
    return null;
  }

  final totalSugar = meals.fold<double>(0, (sum, meal) => sum + meal.sugarGrams);
  final totalCarbs = meals.fold<double>(0, (sum, meal) => sum + meal.carbohydratesGrams);
  final score = totalSugar + (totalCarbs * 0.22) + math.max(0, meals.length - 3) * 4;

  if (score < 28) return NutritionStatus.normal;
  if (score < 48) return NutritionStatus.slightlyHigh;
  if (score < 72) return NutritionStatus.high;
  return NutritionStatus.veryHigh;
}

String nutritionStatusLabel(NutritionStatus? status) {
  return switch (status) {
    NutritionStatus.normal => 'Normal',
    NutritionStatus.slightlyHigh => 'Slightly High',
    NutritionStatus.high => 'High',
    NutritionStatus.veryHigh => 'Very High',
    null => 'No entries yet',
  };
}

Color nutritionStatusColor(NutritionStatus? status) {
  return switch (status) {
    NutritionStatus.normal => const Color(0xFF7DBB6D),
    NutritionStatus.slightlyHigh => MamaColors.sun,
    NutritionStatus.high => MamaColors.coral,
    NutritionStatus.veryHigh => const Color(0xFFE14D73),
    null => const Color(0xFF8A94A8),
  };
}

List<String> nutritionGuidance(NutritionStatus? status) {
  if (status == null) {
    return const <String>[
      'Start by logging meals to build your daily food picture.',
      'A simple sugar and carbohydrate record is enough to begin.',
    ];
  }

  return switch (status) {
    NutritionStatus.normal => const <String>[
        'Keep meals balanced with steady portions.',
        'Pair carbohydrates with protein to support smoother energy.',
      ],
    NutritionStatus.slightlyHigh => const <String>[
        'Reduce sugary drinks where possible.',
        'Increase fiber with vegetables, beans, or whole grains.',
      ],
    NutritionStatus.high => const <String>[
        'Pair carbohydrates with protein at each meal.',
        'Consider a light walk after meals if appropriate for you.',
      ],
    NutritionStatus.veryHigh => const <String>[
        'Choose smaller portions of fast-acting carbohydrates.',
        'Keep hydration steady and review patterns with your care team if this continues.',
      ],
  };
}

bool hasConsistentlyHighNutritionTrend(List<MealLogEntry> allMeals, {int days = 3}) {
  final now = DateTime.now();
  var highDays = 0;
  for (var index = 0; index < days; index++) {
    final day = DateTime(now.year, now.month, now.day - index);
    final dayMeals = mealsForDate(allMeals, day);
    final status = estimateNutritionStatus(dayMeals);
    if (status == NutritionStatus.high || status == NutritionStatus.veryHigh) {
      highDays++;
    }
  }
  return highDays >= 2;
}

String glucoseReadingTypeLabel(GlucoseReadingType type) {
  return switch (type) {
    GlucoseReadingType.fasting => 'Fasting',
    GlucoseReadingType.postBreakfast => 'After breakfast',
    GlucoseReadingType.postLunch => 'After lunch',
    GlucoseReadingType.postDinner => 'After dinner',
    GlucoseReadingType.bedtime => 'Bedtime',
  };
}

String _dateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<DateTime> weekDatesFor(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final start = normalized.subtract(Duration(days: normalized.weekday - 1));
  return List<DateTime>.generate(7, (index) => start.add(Duration(days: index)));
}

List<DateTime> monthDatesForGrid(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final gridStart = first.subtract(Duration(days: first.weekday - 1));
  return List<DateTime>.generate(42, (index) => gridStart.add(Duration(days: index)));
}

bool isReadingWithinTarget(GlucoseReading reading, GlucoseTargets targets) {
  final threshold = reading.readingType == GlucoseReadingType.fasting ? targets.fastingUpper : targets.postMealUpper;
  return reading.value <= threshold;
}

GlucoseBand glucoseBandForReading(GlucoseReading reading, GlucoseTargets targets) {
  final threshold = reading.readingType == GlucoseReadingType.fasting ? targets.fastingUpper : targets.postMealUpper;
  final delta = reading.value - threshold;
  if (delta <= 0) return GlucoseBand.withinTarget;
  if (delta <= targets.slightlyAboveMargin) return GlucoseBand.slightlyAboveTarget;
  if (delta <= targets.significantAboveMargin) return GlucoseBand.aboveTarget;
  return GlucoseBand.significantlyAboveTarget;
}

GlucoseBand glucoseBandForAverage(double average, GlucoseTargets targets) {
  final delta = average - targets.postMealUpper;
  if (average <= targets.postMealUpper) return GlucoseBand.withinTarget;
  if (delta <= targets.slightlyAboveMargin) return GlucoseBand.slightlyAboveTarget;
  if (delta <= targets.significantAboveMargin) return GlucoseBand.aboveTarget;
  return GlucoseBand.significantlyAboveTarget;
}

String glucoseBandLabel(GlucoseBand band) {
  return switch (band) {
    GlucoseBand.withinTarget => 'Within target',
    GlucoseBand.slightlyAboveTarget => 'Slightly above target',
    GlucoseBand.aboveTarget => 'Above target',
    GlucoseBand.significantlyAboveTarget => 'Significantly above target',
  };
}

Color glucoseBandColor(GlucoseBand band) {
  return switch (band) {
    GlucoseBand.withinTarget => const Color(0xFF7DBB6D),
    GlucoseBand.slightlyAboveTarget => MamaColors.sun,
    GlucoseBand.aboveTarget => MamaColors.coral,
    GlucoseBand.significantlyAboveTarget => const Color(0xFFE14D73),
  };
}

String glucoseSupportMessage(GlucoseBand band, {required bool repeatedAboveTarget}) {
  if (repeatedAboveTarget) {
    return 'Your blood glucose readings have been above your target range several times. Please contact your obstetrician or diabetes care team for further evaluation.';
  }

  return switch (band) {
    GlucoseBand.withinTarget => 'Today looks steady. Keep pairing carbohydrates with protein, hydrating well, and following the plan that is already working for you.',
    GlucoseBand.slightlyAboveTarget => 'A few readings are a little above target. Consider reducing sugary drinks, choosing more fiber, and checking whether your carbohydrate portion felt larger than usual.',
    GlucoseBand.aboveTarget => 'Several values are above target today. Try pairing carbohydrates with protein, slowing down the meal pace, and taking a short walk after meals if your maternity team says it is safe.',
    GlucoseBand.significantlyAboveTarget => 'Today\'s readings are clearly above target. Stay hydrated, keep meals balanced, and contact your healthcare team sooner if this pattern continues.',
  };
}

double dailyAverageGlucose(List<GlucoseReading> readings, DateTime date) {
  final matches = readings.where((reading) => isSameDate(reading.recordedAt, date)).toList();
  if (matches.isEmpty) return 0;
  final total = matches.fold<int>(0, (sum, reading) => sum + reading.value);
  return total / matches.length;
}

int repeatedAboveTargetDays(List<GlucoseReading> readings, GlucoseTargets targets, {int days = 3}) {
  final now = DateTime.now();
  var count = 0;
  for (var index = 0; index < days; index++) {
    final day = DateTime(now.year, now.month, now.day - index);
    final dayReadings = readings.where((reading) => isSameDate(reading.recordedAt, day)).toList();
    if (dayReadings.isEmpty) continue;
    final allWithin = dayReadings.every((reading) => isReadingWithinTarget(reading, targets));
    if (!allWithin) {
      count++;
    }
  }
  return count;
}

List<MealLogEntry> mealsForDate(List<MealLogEntry> meals, DateTime date) {
  return meals.where((meal) => isSameDate(meal.mealTime, date)).toList()
    ..sort((a, b) => a.mealTime.compareTo(b.mealTime));
}

List<GlucoseReading> readingsForDate(List<GlucoseReading> readings, DateTime date) {
  return readings.where((reading) => isSameDate(reading.recordedAt, date)).toList()
    ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
}

Future<Position> _resolveCurrentPosition() async {
  final servicesEnabled = await Geolocator.isLocationServiceEnabled();
  if (!servicesEnabled) {
    throw Exception('Location services are turned off on this device.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    throw Exception('Location permission was denied.');
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission is permanently denied. Please enable it in system settings.');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
  );
}

Future<EnvironmentalSnapshot> _fetchEnvironmentalSnapshot(Position position) async {
  final weatherUri = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,uv_index&timezone=auto',
  );
  final airUri = Uri.parse(
    'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${position.latitude}&longitude=${position.longitude}&current=pm2_5,us_aqi&timezone=auto',
  );

  final weatherResponse = await http.get(weatherUri);
  final airResponse = await http.get(airUri);

  if (weatherResponse.statusCode != 200 || airResponse.statusCode != 200) {
    throw Exception('The weather service could not be reached right now.');
  }

  final weatherJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
  final airJson = jsonDecode(airResponse.body) as Map<String, dynamic>;
  final weatherCurrent = weatherJson['current'] as Map<String, dynamic>;
  final airCurrent = airJson['current'] as Map<String, dynamic>;

  final temperature = (weatherCurrent['temperature_2m'] as num?)?.toDouble() ?? 0;
  final feelsLike = (weatherCurrent['apparent_temperature'] as num?)?.toDouble() ?? temperature;
  final humidity = (weatherCurrent['relative_humidity_2m'] as num?)?.toDouble() ?? 0;
  final uvIndex = (weatherCurrent['uv_index'] as num?)?.toDouble() ?? 0;
  final pm25 = (airCurrent['pm2_5'] as num?)?.toDouble() ?? 0;
  final aqi = (airCurrent['us_aqi'] as num?)?.round() ?? 0;
  final heatIndex = _calculateHeatIndexCelsius(temperature, humidity);
  final weatherLabel = _weatherLabelForCode((weatherCurrent['weather_code'] as num?)?.toInt() ?? 0);
  final pmCategory = _pmCategoryForValue(pm25);

  return EnvironmentalSnapshot(
    latitude: position.latitude,
    longitude: position.longitude,
    temperatureC: temperature,
    feelsLikeC: feelsLike,
    humidity: humidity,
    heatIndexC: heatIndex,
    uvIndex: uvIndex,
    pm25: pm25,
    aqi: aqi,
    weatherLabel: weatherLabel,
    pmCategory: pmCategory,
    summaryMessage: _environmentSummary(temperature, heatIndex, pm25, pmCategory),
    recommendation: _environmentRecommendation(temperature, heatIndex, pm25, pmCategory),
    updatedAt: DateTime.now(),
    locationLabel: 'Current GPS location',
    permissionMessage: null,
  );
}

double _calculateHeatIndexCelsius(double temperatureC, double humidity) {
  final fahrenheit = (temperatureC * 9 / 5) + 32;
  final heatIndexF = -42.379 +
      2.04901523 * fahrenheit +
      10.14333127 * humidity -
      0.22475541 * fahrenheit * humidity -
      0.00683783 * fahrenheit * fahrenheit -
      0.05481717 * humidity * humidity +
      0.00122874 * fahrenheit * fahrenheit * humidity +
      0.00085282 * fahrenheit * humidity * humidity -
      0.00000199 * fahrenheit * fahrenheit * humidity * humidity;

  final result = (heatIndexF - 32) * 5 / 9;
  if (temperatureC < 27 || humidity < 40) {
    return temperatureC;
  }
  return result;
}

String _weatherLabelForCode(int code) {
  return switch (code) {
    0 => 'Clear sky',
    1 || 2 => 'Mostly clear',
    3 => 'Cloudy',
    45 || 48 => 'Foggy',
    51 || 53 || 55 => 'Light drizzle',
    61 || 63 || 65 => 'Rain',
    71 || 73 || 75 => 'Snow',
    80 || 81 || 82 => 'Showers',
    95 || 96 || 99 => 'Thunderstorms',
    _ => 'Mixed weather',
  };
}

String _pmCategoryForValue(double pm25) {
  if (pm25 <= 9.0) return 'Good';
  if (pm25 <= 35.4) return 'Moderate';
  if (pm25 <= 55.4) return 'Unhealthy for Sensitive Groups';
  if (pm25 <= 125.4) return 'Unhealthy';
  if (pm25 <= 225.4) return 'Very Unhealthy';
  return 'Hazardous';
}

Color pmCategoryColor(String category) {
  return switch (category) {
    'Good' => const Color(0xFF6CB86F),
    'Moderate' => MamaColors.sun,
    'Unhealthy for Sensitive Groups' => const Color(0xFFF08B4A),
    'Unhealthy' => MamaColors.coral,
    'Very Unhealthy' => const Color(0xFF8D5AD7),
    _ => const Color(0xFF9C2E2E),
  };
}

String homePmRiskLabel(double pm25) {
  if (pm25 <= 9.0) return 'Good';
  if (pm25 <= 35.4) return 'Moderate';
  if (pm25 <= 55.4) return 'Unhealthy';
  if (pm25 <= 125.4) return 'Very Unhealthy';
  return 'Hazardous';
}

String pmShortSentence(double pm25) {
  final risk = homePmRiskLabel(pm25);
  return switch (risk) {
    'Good' => 'Air quality is safe today.',
    'Moderate' => 'Air quality is acceptable today.',
    'Unhealthy' => 'Air quality is unhealthy today.',
    'Very Unhealthy' => 'Air quality is very unhealthy today.',
    _ => 'Air quality is hazardous today.',
  };
}

String temperatureStatusLabel(double temperatureC) {
  if (temperatureC < 22) return 'Cool';
  if (temperatureC < 28) return 'Comfortable';
  if (temperatureC < 32) return 'Warm';
  if (temperatureC < 36) return 'Hot';
  return 'Very Hot';
}

String temperatureShortSentence(double temperatureC) {
  final status = temperatureStatusLabel(temperatureC).toLowerCase();
  if (temperatureC >= 32) {
    return 'Today\'s weather is $status. Stay hydrated.';
  }
  return 'Today\'s weather feels $status.';
}

String friendlyEnvironmentMessage(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('permanently denied')) {
    return 'Location access is turned off, so cached guidance is being shown.';
  }
  if (message.contains('permission was denied')) {
    return 'Location access was denied, so cached guidance is being shown.';
  }
  if (message.contains('services are turned off')) {
    return 'Location services are off, so cached guidance is being shown.';
  }
  return 'Live local conditions are unavailable right now, so cached guidance is being shown.';
}

String _environmentSummary(double temperature, double heatIndex, double pm25, String pmCategory) {
  if (pmCategory == 'Unhealthy' || pmCategory == 'Very Unhealthy' || pmCategory == 'Hazardous') {
    return 'Air quality is a stronger concern than outdoor activity right now. Indoor movement and cleaner air are safer choices.';
  }
  if (heatIndex >= 35) {
    return 'The heat burden is high today. Pregnancy and gestational diabetes can both make dehydration feel stronger and faster.';
  }
  if (pm25 > 35.4) {
    return 'Fine particle pollution is elevated. Sensitive groups, including pregnant people, benefit from lower outdoor exposure.';
  }
  return 'Conditions are relatively manageable, but regular hydration and timing outdoor walks for cooler hours still matter.';
}

String _environmentRecommendation(double temperature, double heatIndex, double pm25, String pmCategory) {
  if (pmCategory == 'Unhealthy' || pmCategory == 'Very Unhealthy' || pmCategory == 'Hazardous') {
    return 'Keep windows closed if outdoor air feels heavy, choose indoor exercise, and consider a mask if you must go out. If you feel short of breath, unusually tired, or dizzy, contact your care team.';
  }
  if (heatIndex >= 35) {
    return 'Drink water before you feel thirsty, avoid the hottest part of the day, wear loose clothing, and keep walks short and gentle. If you have repeated dizziness or a pounding heart, contact your care team.';
  }
  if (pm25 > 35.4) {
    return 'Limit prolonged outdoor activity, especially near traffic or smoke. Gentle indoor movement is a safer option today.';
  }
  return 'This is a reasonable day for light movement, but keep water nearby and pair activity with planned meals to support glucose stability.';
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

const profileGoals = <String>[
  'Manage GDM',
  'Healthy Pregnancy',
  'Exercise Routine',
  'Nutrition',
  'Emotional Wellness',
  'Baby Growth',
];

const appearanceThemeOptions = <String>['System', 'Light', 'Dark'];
const appearanceLanguageOptions = <String>['English', 'Thai'];

const pregnancyMilestones = <PregnancyMilestone>[
  PregnancyMilestone(
    title: 'Week 28 Check-in',
    subtitle: 'Third trimester support',
    body: 'A gentle time to review glucose routines, hydration, and movement while keeping energy steady.',
    icon: Icons.favorite_rounded,
    color: MamaColors.primary,
  ),
  PregnancyMilestone(
    title: 'Week 30 Nutrition Focus',
    subtitle: 'Steady meals matter',
    body: 'Balanced snacks and meal timing can help you feel more comfortable and keep readings predictable.',
    icon: Icons.restaurant_rounded,
    color: MamaColors.peach,
  ),
  PregnancyMilestone(
    title: 'Week 32 Walking Rhythm',
    subtitle: 'Light daily movement',
    body: 'Short walks after meals can support glucose balance and make daily routines feel more manageable.',
    icon: Icons.directions_walk_rounded,
    color: MamaColors.sky,
  ),
  PregnancyMilestone(
    title: 'Week 36 Hospital Prep',
    subtitle: 'Care plan confidence',
    body: 'This is a good window to review your care team, delivery preferences, and emergency contacts.',
    icon: Icons.local_hospital_rounded,
    color: MamaColors.lavender,
  ),
];

const profileAchievements = <AchievementBadge>[
  AchievementBadge(
    title: '7-Day Streak',
    subtitle: 'Logged health routines every day this week.',
    icon: Icons.local_fire_department_rounded,
    color: MamaColors.coral,
  ),
  AchievementBadge(
    title: 'Hydration Star',
    subtitle: 'Stayed consistent with water reminders.',
    icon: Icons.water_drop_rounded,
    color: MamaColors.sky,
  ),
  AchievementBadge(
    title: 'Mood Listener',
    subtitle: 'Checked in with your emotions with care.',
    icon: Icons.mood_rounded,
    color: MamaColors.primary,
  ),
  AchievementBadge(
    title: 'Meal Balance',
    subtitle: 'Built low GI meals with better daily balance.',
    icon: Icons.lunch_dining_rounded,
    color: MamaColors.peach,
  ),
  AchievementBadge(
    title: 'Buddy Favorite',
    subtitle: 'Kept Buddy happy with steady routines.',
    icon: Icons.pets_rounded,
    color: MamaColors.lavender,
  ),
  AchievementBadge(
    title: 'Report Ready',
    subtitle: 'Prepared a clean summary for care conversations.',
    icon: Icons.insights_rounded,
    color: MamaColors.sun,
  ),
];

const supportMenuItems = <SupportMenuItem>[
  SupportMenuItem(
    title: 'FAQ',
    subtitle: 'Quick answers for common questions',
    icon: Icons.quiz_outlined,
  ),
  SupportMenuItem(
    title: 'Contact Support',
    subtitle: 'Reach the care and product support team',
    icon: Icons.support_agent_rounded,
  ),
  SupportMenuItem(
    title: 'Terms of Service',
    subtitle: 'Review usage terms and service coverage',
    icon: Icons.description_outlined,
  ),
  SupportMenuItem(
    title: 'Privacy Policy',
    subtitle: 'Learn how your health data is protected',
    icon: Icons.privacy_tip_outlined,
  ),
  SupportMenuItem(
    title: 'About',
    subtitle: 'Product version, mission, and acknowledgements',
    icon: Icons.info_outline_rounded,
  ),
];

const homeChallenges = <Challenge>[
  Challenge(
    id: 'meal-log',
    title: 'Food Diary Entry',
    subtitle: 'Automatically completes after you log today\'s meal.',
    rewardCoins: 50,
    icon: Icons.restaurant_rounded,
    accent: MamaColors.peach,
  ),
  Challenge(
    id: 'mood-check',
    title: 'Mood Check-in',
    subtitle: 'Automatically completes after today\'s mood check-in.',
    rewardCoins: 20,
    icon: Icons.favorite_rounded,
    accent: MamaColors.blush,
  ),
  Challenge(
    id: 'sugar-goal',
    title: 'Sugar Goal',
    subtitle: 'Completes when today stays at or below 25 g sugar.',
    rewardCoins: 80,
    icon: Icons.icecream_rounded,
    accent: MamaColors.sun,
  ),
  Challenge(
    id: 'buddy-play',
    title: 'Play With Buddy',
    subtitle: 'Completes after you feed or play with Buddy in the cafe.',
    rewardCoins: 80,
    icon: Icons.pets_rounded,
    accent: MamaColors.sky,
  ),
  Challenge(
    id: 'library-read',
    title: 'Read Medical Dictionary',
    subtitle: 'Completes after reading one article for at least 3 minutes.',
    rewardCoins: 100,
    icon: Icons.menu_book_rounded,
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
    label: 'Happy',
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
    id: 'sad',
    label: 'Sad',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: Color(0xFFE7ECF7),
    advice: 'Sad days need softness. Try water, rest, and one small supportive step at a time.',
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
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFF6E9CE), Color(0xFFD9EBE2), Color(0xFFF8D6C4)],
    keywords: [
      'glycemic index',
      'low GI',
      'carbohydrates',
      'blood sugar',
      'gestational diabetes',
      'meal balance',
      'post-meal glucose',
    ],
    body: '''
The glycemic index, often shortened to GI, describes how quickly a carbohydrate-containing food can raise blood glucose compared with a reference food. It is not a score for whether a food is "good" or "bad." Instead, it is one tool that can help you understand why some foods feel steadier in your body while others cause a quicker spike followed by hunger or tiredness.

During pregnancy with gestational diabetes, the goal is usually not to remove all carbohydrates. Your body still needs them for energy, daily function, and fetal growth. The more useful question is how to choose carbohydrate foods in portions and combinations that help glucose rise more gently. That is why GI matters. Lower-GI choices often digest more slowly, especially when they are paired with protein, fiber, and healthy fat.

GI is still only one part of the picture. Portion size, how the food is cooked, what you eat with it, and how your own body responds can all change the result. A simple food diary plus your glucose logs often teaches you more than a label alone. Use GI as a guide, then confirm what works with your actual readings and your care team's advice.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Why it matters during pregnancy',
        body: '''
Hormonal changes in pregnancy make it harder for insulin to move glucose from the blood into the cells. That means the same bowl of rice, toast, or fruit that felt easy before pregnancy may cause a different reading now. Choosing lower-GI foods or balancing moderate-GI foods with protein and fiber may help reduce sharp swings, which can make daily management feel calmer and more predictable.

ACOG and ADA guidance both emphasize steady glucose management during pregnancy because repeated high readings can increase the chance of complications such as larger fetal size, difficult delivery, neonatal hypoglycemia, and the need for more intensive follow-up. GI is not the only strategy, but it can support more stable choices across the day.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'How GI affects gestational diabetes',
        body: '''
High-GI foods tend to break down quickly, so glucose enters the bloodstream faster. In some people this can lead to a larger post-meal rise. Lower-GI foods often digest more slowly, which may produce a gentler curve. Even so, a very large portion of a low-GI food can still raise glucose more than a small portion of a higher-GI food. That is why many clinicians talk about both food quality and portion awareness.

For real-life meals, glycemic load may be more practical than GI alone because it considers both the type of carbohydrate and the amount eaten. If you eat fruit, yogurt, or grains in balanced portions and combine them with protein, vegetables, or nuts, your response may be steadier than if the same carbohydrate is eaten alone.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Foods that often raise glucose faster',
        body: '''
Common examples include sweet drinks, juice, white bread, sweet cereal, large servings of white rice, pastries, and desserts made mostly from refined flour and sugar. Some fruits can also raise glucose faster if the portion is large or if they are blended into smoothies or juices.

This does not mean you failed if you eat one of these foods. It only means they often need more planning. A smaller portion, slower eating pace, and adding protein or fiber may change the result. Your meter or CGM, if you use one, is the best reality check.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Safer ways to build a plate',
        body: '''
Start with non-starchy vegetables when possible, then add protein such as eggs, fish, tofu, chicken, yogurt, or beans. After that, include a moderate carbohydrate portion such as brown rice, berries, whole-grain toast, or milk, depending on your plan. This order can help some people feel fuller and may reduce fast overeating.

If you are unsure where to begin, keep breakfast especially simple. Many women with gestational diabetes notice breakfast is the meal where glucose rises most easily, so a calmer morning pattern often sets up the day well.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Common mistakes',
        body: '''
One common mistake is focusing on GI while ignoring total quantity. Another is assuming every "healthy" food is automatically gentle on glucose. Oats, fruit, smoothies, granola, and even whole grains may still need portion control. A third mistake is judging yourself by one reading. Glucose is influenced by sleep, illness, stress, timing, and daily hormones as well as food.

If a meal surprises you, use that reading as information instead of a reason to panic. Repeat patterns matter more than one imperfect meal.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy Pro Tip',
        body: '''
If breakfast gives you the highest readings, try a 10-minute light walk after eating if your pregnancy team says it is safe. Walking can help muscles use some of the glucose from the meal, and many women find this routine easier to repeat than making a dramatic diet change all at once.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
American College of Obstetricians and Gynecologists (ACOG): Gestational Diabetes FAQ.
American Diabetes Association (ADA) Standards of Care in Diabetes, 2026: Management of Diabetes in Pregnancy.
National Institute for Health and Care Excellence (NICE) NG3: Diabetes in pregnancy.
''',
      ),
    ],
  ),
  Article(
    id: 'meal-swaps',
    category: 'Nutrition Guide',
    title: 'Safe Breakfast Swaps',
    summary: 'Better combinations that still feel filling and comforting.',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2fdfd?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFFCE7D8), Color(0xFFFFF4DF), Color(0xFFDCEEE5)],
    keywords: [
      'breakfast',
      'meal swaps',
      'protein',
      'fiber',
      'morning glucose',
      'diabetic-friendly breakfast',
      'gestational diabetes meal plan',
    ],
    body: '''
Breakfast often feels like the most frustrating meal in gestational diabetes because hormones in the morning can make the body more resistant to insulin. A breakfast that looked small may still produce a higher-than-expected reading. The good news is that breakfast usually responds well to practical swaps rather than strict restriction.

The goal of a breakfast swap is not to remove comfort, culture, or convenience. It is to keep the meal more balanced so you feel satisfied without a big rise followed by hunger. Most breakfasts work better when protein leads the meal and the carbohydrate portion is chosen more carefully. Yogurt with seeds, eggs with toast, tofu with vegetables, or peanut butter with controlled fruit portions are often more stable than sweet drinks, cereal, or pastries eaten alone.

Every person responds differently. You may tolerate milk well but not oats, or whole-grain toast may work better for you than fruit first thing in the morning. Think of breakfast as a small experiment you repeat and refine. If the same meal gives you a pattern of high readings, that is a useful signal to adjust.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Why breakfast deserves special attention',
        body: '''
Morning hormones, including cortisol and other pregnancy-related changes, can make it easier for glucose to rise after breakfast than after lunch or dinner. That is why a breakfast routine that looks "healthy" on paper may still need adjustment in real life. A reading that is higher after breakfast does not mean you are doing something wrong. It usually means your body needs a slightly different mix.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Reliable swap ideas',
        body: '''
Instead of sweet cereal, try plain Greek yogurt with a spoon of chia seeds and a small portion of berries. Instead of a bakery breakfast, try eggs with sautéed vegetables and one slice of whole-grain toast. Instead of a smoothie, try eating the fruit whole and adding a protein source on the side. Instead of sweet coffee plus toast alone, pair your drink with eggs, nuts, cheese, or unsweetened yogurt.

These swaps work because they usually lower the amount of fast-absorbing carbohydrate while raising protein and fiber. That often improves fullness as well as glucose stability.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Foods to choose more often',
        body: '''
Options that often fit breakfast planning include eggs, tofu, unsweetened yogurt, cottage cheese, avocado, nut butter, seeds, berries, small fruit portions, whole-grain toast in measured amounts, and vegetables such as spinach, tomatoes, cucumbers, or mushrooms. Local foods can work well too when portions are steady and meals include protein.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Foods to approach more carefully',
        body: '''
Juices, sweetened coffee drinks, sweet cereal, pastries, white toast with jam, flavored yogurt, and large fruit bowls often raise glucose faster because they combine refined carbohydrate with low protein. Even foods marketed as wholesome, such as granola or acai bowls, can be surprisingly concentrated in sugar and starch.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Common mistakes',
        body: '''
A common mistake is eating too little protein because the meal looks lighter or faster. Another is choosing "no sugar added" foods that are still high in total carbohydrate. A third is skipping breakfast entirely and then feeling extremely hungry later. Skipping can be okay for some people only if it is part of a plan from their clinician, but many women feel better with a steady morning meal.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy Pro Tip',
        body: '''
If you only have five minutes, keep one emergency breakfast ready in the fridge. Plain yogurt, boiled eggs, nuts, a measured piece of fruit, or a pre-portioned sandwich can be much kinder to glucose than grabbing a sweet drink on the way out.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
ACOG: Gestational Diabetes FAQ.
ADA Standards of Care in Diabetes, 2026: Management of Diabetes in Pregnancy.
NICE NG3: Diabetes in pregnancy.
''',
      ),
    ],
  ),
  Article(
    id: 'heat-warning',
    category: 'Climate Warnings',
    title: 'High Heat Index and Hydration',
    summary: 'Why very hot days need extra water and lighter activity.',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFFFE6C3), Color(0xFFF8D7B8), Color(0xFFFCE8D4)],
    keywords: [
      'heat index',
      'hydration',
      'dehydration',
      'pregnancy weather',
      'hot season',
      'water intake',
      'exercise safety',
    ],
    body: '''
Hot weather can feel more draining during pregnancy, and gestational diabetes can make hydration planning even more important. When the heat index rises, the body works harder to stay cool through sweating and blood flow changes. If fluid intake does not keep up, dehydration may develop more quickly, especially when nausea, vomiting, walking outdoors, or long travel are involved.

Hydration matters because it affects comfort, circulation, and sometimes appetite patterns. Severe heat stress or dehydration may also make you feel weak, dizzy, or headachy, which can disrupt meals, glucose checks, and normal daily routines. This article is not about fear. It is about noticing early signs and making small changes before the day becomes exhausting.

Most women do not need to stay indoors all season, but they may need to shift timing, slow intensity, dress lighter, and drink more consistently. The safest plan is usually the boring plan: shade, water, earlier hours, and shorter activity blocks.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Why heat deserves respect in pregnancy',
        body: '''
Pregnancy already increases demands on the heart, circulation, and temperature regulation. In hot conditions you may sweat more, tire more easily, or feel short of breath sooner. If you also have gestational diabetes, a missed meal or delayed hydration pattern may make the day feel even less stable. That does not mean heat is automatically dangerous, but it does mean your body may need a gentler pace.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Early warning signs',
        body: '''
Watch for thirst that does not improve, darker urine, dry mouth, dizziness, headache, weakness, fast heartbeat, cramping, or feeling suddenly overheated. Some symptoms overlap with normal fatigue, which is why context matters. If it is a hot day and you have been outside, dehydrated or overheated is worth considering early rather than waiting until you feel truly unwell.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Simple routines that help',
        body: '''
Drink water regularly across the day instead of waiting until you feel very thirsty. If you are going out, bring water with you. Choose the cooler hours of the morning or evening for walking when possible. Light clothing, frequent breaks, indoor errands, and shaded routes often make more difference than people expect.

If your clinician has given you fluid limits or has concerns about blood pressure, swelling, or kidney issues, follow their advice over general guidance.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'How heat can affect glucose routines',
        body: '''
Hot weather may change appetite, meal timing, and activity level. Some women skip meals because they feel uncomfortable in the heat, then become overly hungry later. Others choose cold sweet drinks that raise glucose faster. It can help to keep easy options ready, such as cold water, unsweetened yogurt, sliced fruit in planned portions, nuts, or a balanced refrigerated snack.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'When to call your care team urgently',
        body: '''
Seek medical help promptly if you cannot keep fluids down, have ongoing vomiting, feel faint, have confusion, chest pain, fewer fetal movements than usual for your stage of pregnancy, contractions that concern you, or symptoms that do not improve after rest and hydration. If something feels wrong, it is reasonable to call early.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
ACOG patient education on pregnancy and medical problems.
WHO guidance on physical activity and pregnancy.
NICE guidance on diabetes in pregnancy and self-management support.
''',
      ),
    ],
  ),
  Article(
    id: 'walk-routine',
    category: 'Maternal Routines',
    title: 'Walking After Meals',
    summary: 'A tiny routine that can make glucose feel easier to manage.',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1517483000871-1db4f7d2d6c3?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFE7F2DE), Color(0xFFD6E9F3), Color(0xFFF1E3C7)],
    keywords: [
      'walking',
      'post-meal walk',
      'exercise',
      'blood sugar',
      'pregnancy movement',
      'light activity',
      'daily routine',
    ],
    body: '''
Walking after meals is one of the most practical routines for many women with gestational diabetes because it is simple, low cost, and easy to adapt. You do not need perfect weather, gym clothes, or a long time window. Even a short walk can help your muscles use some of the glucose from the meal while also improving mood, digestion, and routine.

The most important word here is gentle. Pregnancy is not the time to chase punishing exercise or force a plan that leaves you dizzy or breathless. Most women do best with a comfortable pace where talking still feels possible. What matters more than intensity is consistency. A calm 10-minute walk after meals repeated many days often beats an unrealistic plan you only do once.

Walking is not a replacement for meal planning or medication if your care team has prescribed it. It is one helpful support that may make numbers easier to manage and may help you feel more in control.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Why it helps',
        body: '''
After a meal, muscles can use glucose for energy. Light movement may encourage this process and may reduce how sharply glucose rises for some people. Walking also supports circulation and can lower the feeling of heaviness that sometimes follows a larger meal. Not every reading changes dramatically, but many women find it helpful enough to keep as part of their routine.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'How to start safely',
        body: '''
Begin with a short and realistic goal. Five to ten minutes after breakfast or lunch is enough to start. If outdoor walking feels uncomfortable, a hallway, apartment corridor, home treadmill, or gentle in-place walking also counts. Supportive shoes, water nearby, and a cooler time of day can make the habit easier to repeat.

If you already exercise regularly, you may continue within your clinician's advice. If you are new to exercise, increase gradually instead of trying to make up for earlier inactive days.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'When to slow down or stop',
        body: '''
Stop and seek advice if you have chest pain, dizziness, vaginal bleeding, painful contractions, leaking fluid, severe shortness of breath, or any pregnancy warning sign your clinician has discussed with you. Do not push through symptoms because a walk is supposed to be "healthy." Safe movement should still feel safe.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'How to make the habit stick',
        body: '''
Tie the walk to something that already happens every day, such as putting away your plate, calling a family member, or listening to one song playlist. If one long walk feels unrealistic, split it into two shorter rounds. Routine design matters more than motivation alone.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy Pro Tip',
        body: '''
If you feel tired after dinner, make breakfast or lunch your walking moment instead. Many women get the most benefit from attaching the routine to the meal they can control best, rather than forcing it at the hardest time of day.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
WHO physical activity recommendations for pregnant and postpartum women.
ACOG patient resources on exercise and medical problems in pregnancy.
ADA Standards of Care in Diabetes, 2026.
''',
      ),
    ],
  ),
  Article(
    id: 'medication-faq',
    category: 'Medication',
    title: 'Medication Questions for GDM',
    summary: 'How to think about medication timing and follow-up safely.',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFE9E1F7), Color(0xFFD7ECF8), Color(0xFFF8E2E9)],
    keywords: [
      'insulin',
      'medication',
      'glucose targets',
      'doctor advice',
      'hypoglycemia',
      'blood sugar monitoring',
      'gestational diabetes treatment',
    ],
    body: '''
Hearing that you may need medication during pregnancy can feel emotional. Many women worry it means they failed with food, movement, or effort. That is not what it means. Gestational diabetes happens because pregnancy hormones change how the body responds to insulin. Some women can meet their targets with food planning and activity alone, and others need medication support even when they are doing everything carefully.

Medication is used because it may help protect both mother and baby when glucose stays above target. The specific medicine, timing, and dose should always come from your own clinician because recommendations depend on your readings, meal pattern, pregnancy stage, and medical history. The safest mindset is not "medication versus lifestyle." It is "whatever combination keeps me and my baby safer."

This article gives general education, not personal treatment instructions. Never start, stop, skip, or double a medication dose based on an article alone.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Why medication may be recommended',
        body: '''
If fasting readings or post-meal values stay above target despite consistent routine changes, your clinician may recommend medication. In many care settings insulin is commonly used in pregnancy because it does not cross the placenta in the same way that some oral medications can, although treatment plans vary by country, clinician preference, and patient needs. The main point is that untreated ongoing high glucose also carries risk, so medication can be part of good pregnancy care.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Questions to ask your care team',
        body: '''
Useful questions include: What is this medication for? What targets are we trying to reach? When should I take it? What should I do if I forget a dose? What symptoms of low blood sugar should I watch for? When should I send you my readings? These questions are not a burden. They are part of safe treatment.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Do not change doses on your own',
        body: '''
It can be tempting to skip medicine after one lower reading or to take more after a high reading, but self-adjusting can be risky. A single number does not always explain the full picture. Your clinician looks for patterns across days, meals, sleep, illness, and timing. If you are worried about a trend, report it rather than experimenting alone.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'What about low blood sugar?',
        body: '''
Not every gestational diabetes treatment causes low blood sugar, but some can. If your clinician says you are at risk, learn the symptoms they want you to watch for, such as shakiness, sweating, sudden hunger, dizziness, or confusion. Ask exactly how they want you to treat a low and what number should prompt urgent help.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Follow-up matters',
        body: '''
Bring your glucose logs, questions, meal notes, and symptom patterns to visits. Treatment works best when your care team can see what is happening in real life. It is also important to ask about postpartum follow-up because women who had gestational diabetes have a higher future risk of type 2 diabetes and benefit from later testing.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
ADA Standards of Care in Diabetes, 2026: Management of Diabetes in Pregnancy.
ACOG: Gestational Diabetes FAQ and diabetes in pregnancy resources.
NICE NG3: Diabetes in pregnancy.
''',
      ),
    ],
  ),
  Article(
    id: 'durian-faq',
    category: 'FAQ',
    title: 'Can I Eat Durian?',
    summary: 'A gentle answer with portion awareness and swaps.',
    reviewed: true,
    heroImageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80',
    heroStops: [Color(0xFFF5E7CC), Color(0xFFE5F0DD), Color(0xFFF8DDE4)],
    keywords: [
      'durian',
      'fruit',
      'portion control',
      'sugar spike',
      'snacks',
      'glycemic load',
      'fruit during pregnancy',
    ],
    body: '''
The honest answer is "maybe, but carefully." Durian is not poisonous or forbidden in gestational diabetes, but it is a fruit that can deliver a fairly concentrated carbohydrate load in a small serving. That means it may raise glucose faster than some other fruit options, especially if it is eaten alone or in a large portion.

This is where portion and context matter more than emotion. If you love durian, the safest approach is usually to treat it as an occasional taste rather than a free snack. A few bites may fit more easily than a full serving, and pairing it with protein may be gentler than eating it by itself. Your own readings are what determine whether it is workable for you.

The goal is not fear around fruit. Fruit can absolutely fit into gestational diabetes care. It is just helpful to know that some fruits are easier to portion and easier to predict than others.
''',
    blocks: [
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Why durian can be tricky',
        body: '''
Durian is energy-dense and can contain a substantial amount of carbohydrate in a portion that does not feel very large. Because it tastes rich and sweet, it is also easy to eat more than planned. For someone tracking post-meal glucose, that combination can make readings harder to predict.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'A safer way to think about portions',
        body: '''
If you want to try durian, keep the portion small and avoid combining it with another large carbohydrate source in the same snack or dessert. Consider eating it after a balanced meal rather than on an empty stomach, or pair a very small amount with protein if that fits your plan. Large portions are much more likely to push the snack beyond what your body can manage comfortably.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'Fruits that are often easier to work with',
        body: '''
Many women find guava, berries, green apple, kiwi, or pear easier to portion than tropical fruits that feel dessert-like. These options may still need moderation, but they often fit more smoothly into planned meals and snacks. Whole fruit is usually a better choice than juice because it contains more fiber and is eaten more slowly.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.warning,
        title: 'Common mistake',
        body: '''
The most common mistake is treating fruit as "free" because it is natural. Natural sugar can still raise glucose. Another mistake is using fruit to replace a full meal when you are rushed, which often leaves you hungry later. Fruit usually works best as part of a balanced pattern rather than as a large stand-alone fix.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.tip,
        title: 'Buddy says',
        body: '''
If you are craving something sweet, try asking whether you want sweetness, texture, or comfort. Sometimes a small serving of yogurt with cinnamon, a few berries, or sliced apple with nut butter can meet the same need with a steadier result.
''',
      ),
      ArticleBlock(
        type: ArticleBlockType.note,
        title: 'References',
        body: '''
ACOG: Gestational Diabetes FAQ.
ADA Standards of Care in Diabetes, 2026.
NICE NG3: Diabetes in pregnancy.
''',
      ),
    ],
  ),
];

const shopItemsBySlot = <ShopSlot, List<ShopItem>>{
  ShopSlot.food: [
    ShopItem(
      id: 'food-apple',
      slot: ShopSlot.food,
      name: 'Apple Slices',
      price: 0,
      description: 'A light starter snack for Buddy.',
      colors: [Color(0xFFFFE2D0), Color(0xFFFFF6EF)],
      icon: Icons.apple_rounded,
    ),
    ShopItem(
      id: 'food-banana',
      slot: ShopSlot.food,
      name: 'Banana Bites',
      price: 90,
      description: 'Soft fruit energy for a cozy afternoon.',
      colors: [Color(0xFFFFF0B6), Color(0xFFFFFBDF)],
      icon: Icons.emoji_food_beverage_rounded,
    ),
    ShopItem(
      id: 'food-water',
      slot: ShopSlot.food,
      name: 'Fresh Water',
      price: 60,
      description: 'A simple water refill for Buddy.',
      colors: [Color(0xFFD7ECF8), Color(0xFFF4FBFF)],
      icon: Icons.water_drop_rounded,
    ),
    ShopItem(
      id: 'food-garden-salad',
      slot: ShopSlot.food,
      name: 'Garden Salad',
      price: 120,
      description: 'A crisp bowl with leafy greens.',
      colors: [Color(0xFFDDF2C0), Color(0xFFF4FBEA)],
      icon: Icons.eco_rounded,
    ),
    ShopItem(
      id: 'food-juice',
      slot: ShopSlot.food,
      name: 'Fruit Juice',
      price: 95,
      description: 'A bright little sip for Buddy.',
      colors: [Color(0xFFFFE4C6), Color(0xFFFFF6E7)],
      icon: Icons.local_drink_rounded,
    ),
    ShopItem(
      id: 'food-snack',
      slot: ShopSlot.food,
      name: 'Healthy Snack Box',
      price: 135,
      description: 'Tiny portions of calm cafe treats.',
      colors: [Color(0xFFF5DDE8), Color(0xFFFFF5F8)],
      icon: Icons.lunch_dining_rounded,
    ),
  ],
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

const buddyCafeShopLabels = <String>['Food', 'Furniture', 'Outfits'];

List<ShopItem> buddyCafeShopItemsForIndex(int index) {
  return switch (index) {
    0 => shopItemsBySlot[ShopSlot.food] ?? const <ShopItem>[],
    1 => shopItemsBySlot[ShopSlot.furniture] ?? const <ShopItem>[],
    _ => <ShopItem>[
        ...(shopItemsBySlot[ShopSlot.character] ?? const <ShopItem>[]),
        ...(shopItemsBySlot[ShopSlot.outfit] ?? const <ShopItem>[]),
      ],
  };
}

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
                        color: appMutedColor(context),
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
            color: selected ? MamaColors.primary : appTextColor(context),
          ),
        ),
      ),
    );
  }
}

class GoalChoiceChip extends StatelessWidget {
  const GoalChoiceChip({
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
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? MamaColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: MamaColors.primary.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : appTextColor(context),
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.onEditTap,
    required this.onUpgradeTap,
  });

  final ProfileData profile;
  final VoidCallback onEditTap;
  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -24,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MamaColors.primary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFF5E6D91),
                          child: const Icon(Icons.pets_rounded, color: Colors.white, size: 34),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            onTap: onEditTap,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.edit_rounded, size: 16, color: MamaColors.muted),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.fullName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            if (profile.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: MamaColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Premium',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: MamaColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.pregnancyWeek,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: MamaColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.motivation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MamaColors.muted,
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SoftCard(
                color: MamaColors.primary.withValues(alpha: 0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: MamaColors.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Buddy says your small routines are building something beautiful.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MamaColors.text,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!profile.isPremium) ...[
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onUpgradeTap,
                  child: const Text('Upgrade to Premium'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.width,
    required this.icon,
    required this.accent,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final double width;
  final IconData icon;
  final Color accent;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accent.withValues(alpha: 0.14),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MamaColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(children: children),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? MamaColors.coral : MamaColors.text;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(icon, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MamaColors.muted,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: danger ? MamaColors.coral : MamaColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (title != 'Logout' && title != 'Delete account')
          Divider(
            height: 1,
            color: MamaColors.border.withValues(alpha: 0.8),
          ),
      ],
    );
  }
}

class PremiumMembershipCard extends StatelessWidget {
  const PremiumMembershipCard({
    super.key,
    required this.isPremium,
    required this.onTap,
  });

  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9DB8), Color(0xFFFFC1CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MamaColors.primary.withValues(alpha: 0.30),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPremium ? 'Premium Active' : 'Premium Membership',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isPremium
                ? 'Your profile now includes premium styling, advanced insights, and a more personalized experience.'
                : 'Unlock deeper support with premium tools designed for a calmer, more personalized pregnancy journey.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.94),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final benefit in const [
                'Unlimited AI Chat',
                'Advanced Medical Reports',
                'Personalized Meal Plans',
                'Cloud Backup',
                'Exclusive Buddy Skins',
                'Premium Badge',
              ])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    benefit,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          if (!isPremium) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MamaColors.primary,
              ),
              child: const Text('Try Premium Preview'),
            ),
          ],
        ],
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
                        color: const Color(0xFF5A6275),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Level Up Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF232733),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF677086),
                        fontWeight: FontWeight.w600,
                      ),
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

class DailyGlucoseAnalysisCard extends StatelessWidget {
  const DailyGlucoseAnalysisCard({
    super.key,
    required this.selectedDate,
    required this.meals,
    required this.onTap,
  });

  final DateTime selectedDate;
  final List<MealLogEntry> meals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalSugar = meals.fold<double>(0, (sum, meal) => sum + meal.sugarGrams);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Intake',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calendarCompactLabel(selectedDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: appMutedColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: MamaColors.primary.withValues(alpha: 0.9)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CompactNutritionMetric(
                    label: 'Sugar',
                    value: '${totalSugar.toStringAsFixed(totalSugar % 1 == 0 ? 0 : 1)} g',
                    accent: MamaColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompactNutritionMetric(
                    label: 'Meals',
                    value: '${meals.length}',
                    accent: MamaColors.sky,
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

class _CompactNutritionMetric extends StatelessWidget {
  const _CompactNutritionMetric({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appMutedColor(context),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSummaryTile extends StatelessWidget {
  const _NutritionSummaryTile({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? MamaColors.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: appMutedColor(context),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accent == null ? appTextColor(context) : tone,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class MealHistoryCard extends StatelessWidget {
  const MealHistoryCard({
    super.key,
    required this.meal,
  });

  final MealLogEntry meal;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meal.photoUrl != null && meal.photoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Image.network(
                  meal.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _MealPhotoFallback(mealType: meal.mealType),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _MealPhotoFallback(mealType: meal.mealType);
                  },
                ),
              ),
            )
          else
            _MealPhotoFallback(mealType: meal.mealType),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.foodName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Text(
                      _formatClockTime(meal.mealTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: appMutedColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mealTypeLabel(meal.mealType),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MamaColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MealMetaPill(label: 'Sugar', value: '${meal.sugarGrams.toStringAsFixed(meal.sugarGrams % 1 == 0 ? 0 : 1)} g'),
                    _MealMetaPill(
                      label: 'Carbs',
                      value: '${meal.carbohydratesGrams.toStringAsFixed(meal.carbohydratesGrams % 1 == 0 ? 0 : 1)} g',
                    ),
                  ],
                ),
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    meal.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appMutedColor(context),
                          height: 1.45,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealMetaPill extends StatelessWidget {
  const _MealMetaPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1F27)
            : const Color(0xFFF9F8F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label  $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MealPhotoFallback extends StatelessWidget {
  const _MealPhotoFallback({
    required this.mealType,
  });

  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    final accent = switch (mealType) {
      MealType.breakfast => MamaColors.sun,
      MealType.lunch => MamaColors.primary,
      MealType.dinner => MamaColors.sky,
      MealType.snack => MamaColors.mint,
    };

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.restaurant_rounded, color: accent),
    );
  }
}

class EnvironmentalAlertsPanel extends StatelessWidget {
  const EnvironmentalAlertsPanel({
    super.key,
    required this.environmentalAsync,
    required this.onRetry,
  });

  final AsyncValue<EnvironmentalSnapshot> environmentalAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return environmentalAsync.when(
      data: (snapshot) => _EnvironmentalAlertContent(snapshot: snapshot, onRetry: onRetry),
      loading: () => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 380;
          final cards = [
            _EnvironmentalSkeletonCard(accent: MamaColors.sun),
            _EnvironmentalSkeletonCard(accent: MamaColors.primary),
          ];
          return wide
              ? Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                )
              : Column(
                  children: [
                    cards[0],
                    const SizedBox(height: 12),
                    cards[1],
                  ],
                );
        },
      ),
      error: (error, _) => SoftCard(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF231920)
            : const Color(0xFFFFF6F8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live environment check is unavailable right now.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Location, weather, or air-quality data could not be refreshed. You can retry without losing any of your local app data.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appMutedColor(context),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry live update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentalAlertContent extends StatelessWidget {
  const _EnvironmentalAlertContent({
    required this.snapshot,
    required this.onRetry,
  });

  final EnvironmentalSnapshot snapshot;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final temperatureStatus = temperatureStatusLabel(snapshot.temperatureC);
    final pmRisk = homePmRiskLabel(snapshot.pm25);
    final heatAccent = nutritionStatusColor(
      snapshot.temperatureC >= 36
          ? NutritionStatus.veryHigh
          : snapshot.temperatureC >= 32
              ? NutritionStatus.high
              : snapshot.temperatureC >= 28
                  ? NutritionStatus.slightlyHigh
                  : NutritionStatus.normal,
    );
    final airAccent = pmCategoryColor(pmRisk);

    return Column(
      children: [
        SoftCard(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1F27)
              : const Color(0xFFF9F8F2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.locationLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${_formatUpdatedTime(snapshot.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: appMutedColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (snapshot.permissionMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        snapshot.permissionMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MamaColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh live conditions',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 380;
            final airCard = EnvironmentAlertCard(
              icon: Icons.air_rounded,
              label: 'PM2.5',
              value: '${snapshot.pm25.toStringAsFixed(1)} ug/m3',
              status: pmRisk,
              advice: pmShortSentence(snapshot.pm25),
              accent: airAccent,
            );
            final heatCard = EnvironmentAlertCard(
              icon: Icons.thermostat_rounded,
              label: 'Temperature',
              value: '${snapshot.temperatureC.toStringAsFixed(1)}°C',
              status: temperatureStatus,
              advice: temperatureShortSentence(snapshot.temperatureC),
              accent: heatAccent,
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: airCard),
                      const SizedBox(width: 12),
                      Expanded(child: heatCard),
                    ],
                  )
                : Column(
                    children: [
                      airCard,
                      const SizedBox(height: 12),
                      heatCard,
                    ],
                  );
          },
        ),
      ],
    );
  }
}

class EnvironmentAlertCard extends StatelessWidget {
  const EnvironmentAlertCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.advice,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String status;
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
                radius: 18,
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
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: appTextColor(context),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            advice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appMutedColor(context),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class WeeklyCalendarStrip extends ConsumerWidget {
  const WeeklyCalendarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final visibleMonth = ref.watch(dashboardMonthProvider);
    final expanded = ref.watch(calendarExpandedProvider);
    final moodHistory = ref.watch(moodHistoryProvider);
    final meals = ref.watch(mealLogsProvider);
    final readings = ref.watch(glucoseReadingsProvider);
    final challengeIds = ref.watch(visibleCompletedChallengeIdsProvider);

    final dates = expanded ? monthDatesForGrid(visibleMonth) : weekDatesFor(selectedDate);
    final hasChallengeMomentum = challengeIds.isNotEmpty;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  expanded ? _weekLabel(visibleMonth) : 'Week of ${_calendarCompactLabel(dates.first)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (expanded) ...[
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () {
                    final previous = DateTime(visibleMonth.year, visibleMonth.month - 1);
                    ref.read(dashboardMonthProvider.notifier).state = previous;
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () {
                    final next = DateTime(visibleMonth.year, visibleMonth.month + 1);
                    ref.read(dashboardMonthProvider.notifier).state = next;
                  },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
              IconButton(
                tooltip: expanded ? 'Collapse calendar' : 'Expand calendar',
                onPressed: () => ref.read(calendarExpandedProvider.notifier).state = !expanded,
                icon: Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            expanded
                ? 'Tap a day to review meals, glucose readings, and mood markers.'
                : 'Tap to choose a day or expand for the full month.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appMutedColor(context),
                ),
          ),
          const SizedBox(height: 14),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Column(
                    children: [
                      Row(
                        children: List.generate(7, (index) {
                          final weekday = index + 1;
                          return Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  weekdayShort(weekday),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: appMutedColor(context),
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dates.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.08,
                        ),
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          return _CalendarDayCell(
                            date: date,
                            selected: isSameDate(date, selectedDate),
                            inVisibleMonth: date.month == visibleMonth.month,
                            mood: moodHistory[_dateKey(date)],
                            hasMeal: meals.any((meal) => isSameDate(meal.mealTime, date)),
                            hasReading: readings.any((reading) => isSameDate(reading.recordedAt, date)),
                            highlightTask: hasChallengeMomentum && isSameDate(date, DateTime.now()),
                            compact: true,
                            onTap: () {
                              ref.read(selectedDashboardDateProvider.notifier).state = date;
                              ref.read(dashboardMonthProvider.notifier).state = DateTime(date.year, date.month);
                            },
                          );
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      for (final date in dates) ...[
                        Expanded(
                          child: _CalendarDayCell(
                            date: date,
                            selected: isSameDate(date, selectedDate),
                            inVisibleMonth: true,
                            mood: moodHistory[_dateKey(date)],
                            hasMeal: meals.any((meal) => isSameDate(meal.mealTime, date)),
                            hasReading: readings.any((reading) => isSameDate(reading.recordedAt, date)),
                            highlightTask: hasChallengeMomentum && isSameDate(date, DateTime.now()),
                            compact: false,
                            onTap: () {
                              ref.read(selectedDashboardDateProvider.notifier).state = date;
                              ref.read(dashboardMonthProvider.notifier).state = DateTime(date.year, date.month);
                            },
                          ),
                        ),
                        if (date != dates.last) const SizedBox(width: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.selected,
    required this.inVisibleMonth,
    required this.mood,
    required this.hasMeal,
    required this.hasReading,
    required this.highlightTask,
    required this.compact,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool inVisibleMonth;
  final String? mood;
  final bool hasMeal;
  final bool hasReading;
  final bool highlightTask;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDate(date, DateTime.now());
    final baseTextColor = inVisibleMonth ? appTextColor(context) : appMutedColor(context).withValues(alpha: 0.55);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: selected
              ? MamaColors.primary.withValues(alpha: 0.14)
              : isToday
                  ? MamaColors.sun.withValues(alpha: 0.10)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? MamaColors.primary.withValues(alpha: 0.42)
                : isToday
                    ? MamaColors.sun.withValues(alpha: 0.28)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!compact) ...[
              Text(
                weekdayShort(date.weekday),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: baseTextColor.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: compact ? 28 : 34,
              height: compact ? 28 : 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? MamaColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? Colors.white : baseTextColor,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 13 : null,
                    ),
              ),
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              mood ?? ' ',
              style: TextStyle(fontSize: compact ? 12 : 14),
            ),
            SizedBox(height: compact ? 2 : 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CalendarMarker(active: hasMeal, color: MamaColors.sky),
                const SizedBox(width: 4),
                _CalendarMarker(active: hasReading, color: MamaColors.primary),
                const SizedBox(width: 4),
                _CalendarMarker(active: highlightTask, color: MamaColors.sun),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarMarker extends StatelessWidget {
  const _CalendarMarker({
    required this.active,
    required this.color,
  });

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EnvironmentalSkeletonCard extends StatelessWidget {
  const _EnvironmentalSkeletonCard({
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: accent.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 160,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 220,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.completed,
  });

  final Challenge challenge;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final cardIsLight = completed;
    final titleColor = cardIsLight ? const Color(0xFF252B35) : appTextColor(context);
    final subtitleColor = cardIsLight ? const Color(0xFF657184) : appMutedColor(context);
    final rewardColor = cardIsLight ? const Color(0xFFE85F89) : appMutedColor(context);

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
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  challenge.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  completed ? 'Completed automatically  |  +${challenge.rewardCoins} coins' : 'Auto-tracked  |  +${challenge.rewardCoins} coins',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: rewardColor,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? MamaColors.primary : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: completed ? MamaColors.primary : MamaColors.border),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.schedule_rounded,
              color: completed ? Colors.white : MamaColors.text,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  width: 104,
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetworkHeroImage(
                        url: article.heroImageUrl,
                        fallback: article.heroStops,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.04),
                              Colors.black.withValues(alpha: 0.20),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
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
                          color: appMutedColor(context),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: appMutedColor(context)),
                      const SizedBox(width: 4),
                      Text(
                        estimatedReadTime(article),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: appMutedColor(context),
                              fontWeight: FontWeight.w600,
                            ),
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
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1F28) : const Color(0xFFF9FAFC),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: appMutedColor(context)),
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
    final actionLabel = equipped
        ? item.slot == ShopSlot.food
            ? 'Using'
            : 'Equipped'
        : owned
            ? item.slot == ShopSlot.food
                ? 'Use'
                : 'Equip'
            : item.price == 0
                ? 'Free'
                : 'Buy';

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: item.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Center(
              child: Icon(item.icon, size: 36, color: MamaColors.text),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: appTextColor(context),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appMutedColor(context),
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.price == 0 ? 'Owned' : '${item.price} coins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: item.price == 0 ? MamaColors.primary : appTextColor(context),
                      ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: equipped
                    ? null
                    : owned
                        ? onEquip
                        : onBuy,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  disabledBackgroundColor: const Color(0xFF444B58),
                  disabledForegroundColor: Colors.white,
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
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF47505C) : MamaColors.border),
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
                    color: selected ? MamaColors.primary : appTextColor(context),
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
                  color: const Color(0xFF2E3340),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class BuddyInventoryCard extends StatelessWidget {
  const BuddyInventoryCard({
    super.key,
    required this.item,
    required this.equipped,
    required this.onUse,
  });

  final ShopItem item;
  final bool equipped;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final actionLabel = item.slot == ShopSlot.food
        ? (equipped ? 'Using' : 'Use Now')
        : equipped
            ? 'Equipped'
            : 'Equip';

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: item.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(item.icon, size: 28, color: const Color(0xFF2E3340)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appMutedColor(context),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: equipped ? null : onUse,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              disabledBackgroundColor: const Color(0xFF444B58),
              disabledForegroundColor: Colors.white,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class BuddyNeedBar extends StatelessWidget {
  const BuddyNeedBar({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appMutedColor(context),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0, 100) / 100,
              minHeight: 10,
              backgroundColor: accent.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
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
                  fontSize: size * 0.18,
                  color: appTextColor(context),
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
                        color: appMutedColor(context),
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
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: _NetworkHeroImage(
                url: article.heroImageUrl,
                fallback: article.heroStops,
              ),
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
                    estimatedReadTime(article),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appMutedColor(context),
                          fontWeight: FontWeight.w600,
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

Future<void> showMealLogSheet(BuildContext context, WidgetRef ref, {required DateTime initialDate}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MealLogSheet(initialDate: initialDate);
    },
  );
}

Future<void> showBuddyShopSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const BuddyShopSheet(),
  );
}

class BuddyShopSheet extends ConsumerWidget {
  const BuddyShopSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetSurface = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF171B22) : MamaColors.surface;
    final selectedTab = ref.watch(selectedShopTabProvider);
    final items = buddyCafeShopItemsForIndex(selectedTab);
    final ownedItems = ref.watch(ownedShopItemsProvider);
    final coins = ref.watch(coinWalletProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.62,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MamaColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Buddy Shop',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: MamaColors.sun.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.casino_rounded, size: 16, color: MamaColors.sun),
                            const SizedBox(width: 6),
                            Text(
                              '$coins coins',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF2E3340),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Shop for Buddy without leaving the cafe. Purchased items become available right away.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appMutedColor(context),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SegmentTabs(
                    labels: const ['Food', 'Furniture', 'Outfits'],
                    selectedIndex: selectedTab,
                    onChanged: (value) => ref.read(selectedShopTabProvider.notifier).state = value,
                  ),
                  const SizedBox(height: 16),
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShopItemCard(
                        item: item,
                        owned: ownedItems.contains(item.id),
                        equipped: isEquipped(ref, item),
                        onBuy: () => buyShopItem(context, ref, item),
                        onEquip: () => equipShopItem(ref, item),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MealLogSheet extends ConsumerStatefulWidget {
  const MealLogSheet({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  ConsumerState<MealLogSheet> createState() => _MealLogSheetState();
}

class _MealLogSheetState extends ConsumerState<MealLogSheet> {
  late final TextEditingController foodController;
  late final TextEditingController sugarController;
  late final TextEditingController carbsController;
  late final TextEditingController photoController;
  late final TextEditingController notesController;
  MealType selectedMealType = MealType.breakfast;
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    foodController = TextEditingController();
    sugarController = TextEditingController();
    carbsController = TextEditingController();
    photoController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    foodController.dispose();
    sugarController.dispose();
    carbsController.dispose();
    photoController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (picked == null) return;
    setState(() {
      selectedDateTime = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _save() {
    final foodName = foodController.text.trim();
    final sugar = double.tryParse(sugarController.text.trim()) ?? 0;
    final carbs = double.tryParse(carbsController.text.trim()) ?? 0;

    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a meal name first.')),
      );
      return;
    }

    final mealEntry = MealLogEntry(
      id: 'meal-${DateTime.now().microsecondsSinceEpoch}',
      foodName: foodName,
      foodCategory: 'Meal log',
      mealType: selectedMealType,
      sugarGrams: sugar,
      carbohydratesGrams: carbs,
      mealTime: selectedDateTime,
      photoUrl: photoController.text.trim().isEmpty ? null : photoController.text.trim(),
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
    );

    ref.read(mealLogsProvider.notifier).state = [
      ...ref.read(mealLogsProvider),
      mealEntry,
    ]..sort((a, b) => a.mealTime.compareTo(b.mealTime));
    ref.read(buddyFoodProvider.notifier).state = (ref.read(buddyFoodProvider) + 12).clamp(0, 100).toInt();
    ref.read(buddyAnimationProvider.notifier).state = 'eat';
    ref.read(buddyStatusMessageProvider.notifier).state = 'Buddy enjoyed your meal log update.';

    final today = DateTime.now();
    ref.read(selectedDashboardDateProvider.notifier).state = today;
    ref.read(dashboardMonthProvider.notifier).state = DateTime(today.year, today.month);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal saved to your daily food diary.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sheetSurface = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF171B22) : MamaColors.surface;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.74,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(16, 10, 16, 20 + MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MamaColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Meal Log',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Save today\'s meal with sugar, carbohydrates, time, and optional notes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appMutedColor(context),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        label: Text(_calendarHeaderLabel(selectedDateTime)),
                        avatar: const Icon(Icons.calendar_today_rounded, size: 18),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(_formatClockTime(selectedDateTime)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: foodController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Meal Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MealType>(
                    initialValue: selectedMealType,
                    decoration: const InputDecoration(labelText: 'Meal type'),
                    items: MealType.values
                        .map(
                          (type) => DropdownMenuItem<MealType>(
                            value: type,
                            child: Text(mealTypeLabel(type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedMealType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sugarController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Sugar (g)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: carbsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Carbohydrates (g)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: photoController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Photo URL (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save daily entry'),
                  ),
                ],
              ),
            ),
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

  Future<void> _submitMood(MoodChoice mood) async {
    final navigator = Navigator.of(context);
    final hostContext = navigator.context;
    final negativeMood = isNegativeMoodId(mood.id);
    final moodAlreadyRewarded = ref.read(visibleCompletedChallengeIdsProvider).contains('mood-check');

    void rewardMoodCheckIfNeeded() {
      if (moodAlreadyRewarded) {
        return;
      }
      ref.read(coinWalletProvider.notifier).state += 20;
      ref.read(completedChallengeIdsProvider.notifier).state = {
        ...ref.read(completedChallengeIdsProvider),
        'mood-check',
      };
    }

    if (!negativeMood) {
      rewardMoodCheckIfNeeded();
      applyMoodMemory(
        ref,
        mood,
        happinessDelta: 10,
        animation: 'dance',
        statusMessage: buddyPositiveMessage(mood),
      );
      if (mounted) {
        navigator.pop();
      }
      ScaffoldMessenger.of(hostContext).showSnackBar(
        SnackBar(
          content: Text('${buddyPositiveMessage(mood)}  |  Happiness +10  |  Coins +20'),
          duration: const Duration(milliseconds: 1600),
        ),
      );
      return;
    }

    ref.read(selectedMoodProvider.notifier).state = mood.label;
    ref.read(selectedMoodIdProvider.notifier).state = mood.id;

    if (mounted) {
      navigator.pop();
    }

    final careDecision = await showBuddyCareSheet(hostContext, ref, mood: mood);
    if (!hostContext.mounted) {
      return;
    }

    if (careDecision == BuddyCareDecision.chat) {
      await openBuddyCareChatPage(hostContext, mood);
      if (!hostContext.mounted) {
        return;
      }
    }

    rewardMoodCheckIfNeeded();
    applyMoodMemory(
      ref,
      mood,
      happinessDelta: 5,
      animation: 'hug',
      statusMessage: 'Buddy is here for you today.',
    );
    ScaffoldMessenger.of(hostContext).showSnackBar(
      SnackBar(
        content: Text('Buddy is here for you today.  |  Virtual hug  |  Happiness +5  |  Coins +20'),
        duration: const Duration(milliseconds: 1700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetSurface = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF171B22) : MamaColors.surface;
    final selected = moods.firstWhere((mood) => mood.id == selectedMoodId, orElse: () => moods.first);
    final hasSelection = selectedMoodId != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.72,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                            color: appMutedColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you today?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: appTextColor(context),
                            fontSize: 30,
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
                                    color: appMutedColor(context),
                                    height: 1.55,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: hasSelection
                          ? () => _submitMood(selected)
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
            Icon(mood.icon, color: const Color(0xFF2A2D34), size: 22),
            const SizedBox(height: 6),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2D34),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<BuddyCareDecision> showBuddyCareSheet(BuildContext context, WidgetRef ref, {required MoodChoice mood}) async {
  final result = await showModalBottomSheet<BuddyCareDecision>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BuddyCareSheet(mood: mood),
  );
  return result ?? BuddyCareDecision.close;
}

class BuddyCareSheet extends StatelessWidget {
  const BuddyCareSheet({
    super.key,
    required this.mood,
  });

  final MoodChoice mood;

  @override
  Widget build(BuildContext context) {
    final sheetSurface = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF171B22) : MamaColors.surface;
    final accent = buddyExpressionColor(mood.id, 'hug');
    final suggestions = buddySupportSuggestions(mood.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.74,
      minChildSize: 0.58,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: MamaColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: accent.withValues(alpha: 0.14),
                        child: Icon(buddyExpressionIcon(mood.id, 'hug'), color: accent, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buddy Care',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              buddyNegativeGreeting(mood),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: appMutedColor(context),
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    color: accent.withValues(alpha: 0.10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buddy says',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I\'m here for you today. Let\'s take this one gentle step at a time.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Buddy can offer simple pregnancy-friendly support, but it cannot diagnose anything or replace your healthcare team.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: appMutedColor(context),
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Gentle ideas for right now',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (final suggestion in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.favorite_rounded, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: appMutedColor(context),
                                    height: 1.45,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(BuddyCareDecision.close),
                          child: const Text('Thanks Buddy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(BuddyCareDecision.chat),
                          child: const Text('Chat with Buddy'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BuddyCareChatPage extends StatelessWidget {
  const BuddyCareChatPage({
    super.key,
    required this.mood,
  });

  final MoodChoice mood;

  @override
  Widget build(BuildContext context) {
    final accent = buddyExpressionColor(mood.id, 'hug');
    final suggestions = buddySupportSuggestions(mood.id);

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
                      Expanded(
                        child: Text(
                          'Buddy Care Chat',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    color: accent.withValues(alpha: 0.10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: accent.withValues(alpha: 0.14),
                          child: Icon(buddyExpressionIcon(mood.id, 'hug'), color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buddy',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${buddyNegativeGreeting(mood)} I\'m staying with you for a moment.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: appMutedColor(context),
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final suggestion in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1F27)
                            : const Color(0xFFFFF7FA),
                        child: Text(
                          suggestion,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-ready space',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This full chat page is ready for later AI integration. For now, Buddy keeps the conversation supportive, gentle, and pregnancy-friendly.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: appMutedColor(context),
                                height: 1.45,
                              ),
                        ),
                      ],
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

// Utility and routing helpers

void openDailyNutritionPage(BuildContext context, DateTime date) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => DailyNutritionPage(initialDate: date),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(begin: const Offset(0.04, 0.02), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    ),
  );
}

Future<void> openBuddyCareChatPage(BuildContext context, MoodChoice mood) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => BuddyCareChatPage(mood: mood),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(begin: const Offset(0.04, 0.02), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    ),
  );
}

void openFoodHistoryPage(BuildContext context, DateTime date) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => FoodHistoryPage(initialDate: date),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(begin: const Offset(0.04, 0.02), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    ),
  );
}

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
    SnackBar(content: Text('${item.name} purchased and ready in Buddy Cafe.')),
  );
}

void equipShopItem(WidgetRef ref, ShopItem item) {
  switch (item.slot) {
    case ShopSlot.food:
      ref.read(equippedFoodIdProvider.notifier).state = item.id;
      final waterItem = item.id.contains('water') || item.id.contains('juice');
      if (waterItem) {
        ref.read(buddyWaterProvider.notifier).state = (ref.read(buddyWaterProvider) + 18).clamp(0, 100).toInt();
        ref.read(buddyAnimationProvider.notifier).state = 'drink';
        ref.read(buddyStatusMessageProvider.notifier).state = 'Buddy enjoyed a refreshing drink.';
      } else {
        ref.read(buddyFoodProvider.notifier).state = (ref.read(buddyFoodProvider) + 16).clamp(0, 100).toInt();
        ref.read(buddyAnimationProvider.notifier).state = 'eat';
        ref.read(buddyStatusMessageProvider.notifier).state = 'Buddy happily enjoyed ${item.name.toLowerCase()}.';
      }
      break;
    case ShopSlot.character:
      ref.read(equippedCharacterIdProvider.notifier).state = item.id;
      ref.read(buddyStatusMessageProvider.notifier).state = '${item.name} is now visiting the cafe.';
      break;
    case ShopSlot.outfit:
      ref.read(equippedOutfitIdProvider.notifier).state = item.id;
      ref.read(buddyStatusMessageProvider.notifier).state = 'Buddy changed into ${item.name.toLowerCase()}.';
      break;
    case ShopSlot.furniture:
      ref.read(equippedFurnitureIdProvider.notifier).state = item.id;
      ref.read(buddyStatusMessageProvider.notifier).state = '${item.name} refreshed Buddy\'s home instantly.';
      break;
  }
}

bool isEquipped(WidgetRef ref, ShopItem item) {
  return switch (item.slot) {
    ShopSlot.food => ref.watch(equippedFoodIdProvider) == item.id,
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

String _monthShortLabel(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _calendarCompactLabel(DateTime date) {
  return '${_monthShortLabel(date.month)} ${date.day}';
}

String _calendarHeaderLabel(DateTime date) {
  return '${_weekLabel(date)} • ${date.day} ${_monthShortLabel(date.month)}';
}

String _formatClockTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _formatUpdatedTime(DateTime date) {
  return '${_calendarCompactLabel(date)} at ${_formatClockTime(date)}';
}

String moodEmojiForId(String moodId) {
  return switch (moodId) {
    'excited' => '🎉',
    'joyful' => '😊',
    'grateful' => '💛',
    'energized' => '⚡',
    'sensitive' => '🌊',
    'confused' => '🌀',
    'calm' => '🙂',
    'stressed' => '❗',
    'angry' => '😠',
    'insecure' => '🛡️',
    'hurt' => '💔',
    'guilty' => '🚫',
    _ => '🌷',
  };
}

bool isNegativeMoodId(String moodId) {
  return const <String>{
    'stressed',
    'sad',
    'angry',
    'guilty',
    'lonely',
    'tired',
    'confused',
    'hurt',
    'anxious',
    'sensitive',
    'insecure',
  }.contains(moodId);
}

bool isPositiveMoodId(String moodId) {
  return const <String>{
    'joyful',
    'excited',
    'grateful',
    'energized',
    'relaxed',
  }.contains(moodId);
}

IconData buddyExpressionIcon(String? moodId, String animation) {
  if (animation == 'dance') return Icons.celebration_rounded;
  if (animation == 'hug') return Icons.favorite_rounded;
  if (animation == 'wave') return Icons.waving_hand_rounded;
  if (animation == 'sleep') return Icons.bedtime_rounded;
  if (animation == 'eat') return Icons.restaurant_rounded;
  if (animation == 'drink') return Icons.local_drink_rounded;

  return switch (moodId) {
    'joyful' || 'excited' || 'grateful' || 'energized' => Icons.sentiment_very_satisfied_rounded,
    'stressed' || 'angry' => Icons.mood_bad_rounded,
    'hurt' || 'guilty' || 'insecure' => Icons.favorite_border_rounded,
    'confused' || 'sensitive' => Icons.sentiment_neutral_rounded,
    _ => Icons.pets_rounded,
  };
}

String buddyExpressionLabel(String? moodId, String animation) {
  if (animation == 'dance') return 'Buddy dances for you';
  if (animation == 'hug') return 'Buddy sends a virtual hug';
  if (animation == 'wave') return 'Buddy waves hello';
  if (animation == 'sleep') return 'Buddy looks sleepy';
  if (animation == 'eat') return 'Buddy is happily eating';
  if (animation == 'drink') return 'Buddy takes a drink';

  return switch (moodId) {
    'joyful' || 'excited' || 'grateful' || 'energized' => 'Buddy is smiling today',
    'stressed' => 'Buddy looks gently worried',
    'angry' => 'Buddy looks a little nervous',
    'hurt' || 'guilty' || 'insecure' => 'Buddy stays close and soft',
    'confused' || 'sensitive' => 'Buddy is calm and listening',
    _ => 'Buddy is ready to support you',
  };
}

Color buddyExpressionColor(String? moodId, String animation) {
  if (animation == 'dance') return MamaColors.primary;
  if (animation == 'hug') return MamaColors.blush;
  if (animation == 'eat') return MamaColors.sun;
  if (animation == 'drink') return MamaColors.sky;
  return switch (moodId) {
    'joyful' || 'excited' || 'grateful' || 'energized' => MamaColors.primary,
    'stressed' || 'angry' => MamaColors.coral,
    'hurt' || 'guilty' || 'insecure' => const Color(0xFFB26A86),
    'confused' || 'sensitive' => const Color(0xFF7392A5),
    _ => MamaColors.primary,
  };
}

String buddyPositiveMessage(MoodChoice mood) {
  return switch (mood.id) {
    'joyful' => 'I\'m so happy you\'re feeling good today!',
    'excited' => 'Your excitement is contagious. Buddy is cheering with you!',
    'grateful' => 'That grateful heart feels so warm today.',
    'energized' => 'Buddy loves this bright energy. Let\'s keep it gentle and steady.',
    _ => 'Buddy is happy to see you feeling a little lighter today.',
  };
}

String buddyNegativeGreeting(MoodChoice mood) {
  return 'I noticed you\'re feeling ${mood.label.toLowerCase()} today.';
}

List<String> buddySupportSuggestions(String moodId) {
  return switch (moodId) {
    'stressed' => const <String>[
        'Take three slow breaths and release your shoulders.',
        'Sip some water before you do the next task.',
        'A short gentle walk can help if it feels okay today.',
      ],
    'angry' => const <String>[
        'Step away for a quiet minute before reacting.',
        'Try slower breathing to help your body settle.',
        'Text or call someone you trust if you want support.',
      ],
    'hurt' || 'guilty' || 'insecure' => const <String>[
        'Rest for a few minutes and be kind to yourself.',
        'One meal or one reading does not define your day.',
        'Talk with someone you trust if you need a softer space.',
      ],
    _ => const <String>[
        'Drink a little water and breathe slowly for a moment.',
        'Try calming music or a quiet stretch.',
        'Rest if your body feels heavy today.',
      ],
  };
}

void applyMoodMemory(
  WidgetRef ref,
  MoodChoice mood, {
  required int happinessDelta,
  required String animation,
  required String statusMessage,
  bool completeToday = true,
}) {
  ref.read(selectedMoodProvider.notifier).state = mood.label;
  ref.read(selectedMoodIdProvider.notifier).state = mood.id;
  if (completeToday) {
    ref.read(moodHistoryProvider.notifier).state = <String, String>{
      ...ref.read(moodHistoryProvider),
      _dateKey(DateTime.now()): moodEmojiForId(mood.id),
    };
  }
  ref.read(selectedDashboardDateProvider.notifier).state = DateTime.now();
  ref.read(dashboardMonthProvider.notifier).state = DateTime(DateTime.now().year, DateTime.now().month);
  ref.read(petHappinessProvider.notifier).state =
      (ref.read(petHappinessProvider) + happinessDelta).clamp(0, 100).toInt();
  ref.read(buddyAnimationProvider.notifier).state = animation;
  ref.read(buddyStatusMessageProvider.notifier).state = statusMessage;
}

enum BuddyCareDecision { close, chat }

void _showExportSnack(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label export is ready for later integration.')),
  );
}


