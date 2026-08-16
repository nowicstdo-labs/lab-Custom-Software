import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/lab_test.dart';
import '../../../utils/dummy_data.dart';

class TestCatalogScreen extends StatefulWidget {
  const TestCatalogScreen({super.key});

  @override
  State<TestCatalogScreen> createState() => _TestCatalogScreenState();
}

class _TestCatalogScreenState extends State<TestCatalogScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Tests';
  int _bottomNavIndex = 0;
  final Set<String> _selectedTestIds = {};

  List<String> get _categories => [
        'All Tests',
        'Blood Tests',
        'Biochemistry',
        'Microbiology',
        'Hormones',
        'Urine',
      ];

  List<LabTest> get _filteredTests => demoLabTests.where((t) {
        final matchesSearch = _searchQuery.isEmpty ||
            t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'All Tests' ||
            t.category.toLowerCase() == _selectedCategory.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book a Test',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // ── Search & Filter Row ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search tests...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, color: AppColors.textPrimary, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Category Filter Chips ────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF00796B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00796B).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Test List (Complete Catalogue) ──────────────────────────────
          Expanded(
            child: _filteredTests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.biotech_outlined, size: 54, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No tests found', style: AppTextStyles.subtitle),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: _filteredTests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final test = _filteredTests[i];
                      final isSelected = _selectedTestIds.contains(test.id);
                      return _BookTestCard(
                        test: test,
                        isSelected: isSelected,
                        onSelect: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTestIds.remove(test.id);
                            } else {
                              _selectedTestIds.add(test.id);
                            }
                          });
                          context.push('/public/book-test');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── Bottom Navigation (4 items) ───────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            if (index == 0) {
              context.go('/patient');
            } else if (index == 1) {
              context.push('/public/my-tests');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00796B),
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech_rounded),
              label: 'My Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Test Card Component (Matching Right Reference Image) ─────────────────────

class _BookTestCard extends StatelessWidget {
  final LabTest test;
  final bool isSelected;
  final VoidCallback onSelect;

  const _BookTestCard({
    required this.test,
    required this.isSelected,
    required this.onSelect,
  });

  Widget _buildTestIcon() {
    IconData iconData;
    Color iconColor;

    if (test.name.contains('CBC') || test.category == 'Blood Tests') {
      iconData = Icons.water_drop_rounded;
      iconColor = const Color(0xFFE53935);
    } else if (test.name.contains('Liver')) {
      iconData = Icons.health_and_safety_rounded;
      iconColor = const Color(0xFFD84315);
    } else if (test.name.contains('Kidney')) {
      iconData = Icons.local_hospital_rounded;
      iconColor = const Color(0xFFC62828);
    } else if (test.name.contains('Thyroid') || test.category == 'Hormones') {
      iconData = Icons.medication_liquid_rounded;
      iconColor = const Color(0xFFE53935);
    } else {
      iconData = Icons.science_rounded;
      iconColor = const Color(0xFF00796B);
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Icon
              _buildTestIcon(),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            test.name,
                            style: AppTextStyles.headline3.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '₹${test.price.toInt()}',
                          style: AppTextStyles.headline3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      test.description,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sample & Reports Info Row + Select Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sample: ',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              test.sampleType,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Reports: ',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              test.turnaround,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: onSelect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF00796B)
                                : const Color(0xFFE0F2F1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(
                            isSelected ? 'Selected ✓' : 'Select',
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF00796B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
