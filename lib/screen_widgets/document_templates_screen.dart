import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:provider/provider.dart';
import 'package:lanka_law/services/templates_provider.dart';
import 'package:lanka_law/models/template_item.dart';
import 'package:lanka_law/screen_widgets/template_preview_screen.dart';

class DocumentTemplatesScreen extends StatefulWidget {
  const DocumentTemplatesScreen({super.key});

  @override
  State<DocumentTemplatesScreen> createState() =>
      _DocumentTemplatesScreenState();
}

class _DocumentTemplatesScreenState extends State<DocumentTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data (defaults to Business) when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplatesProvider>().fetchTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Document Templates",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IOExceptionButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: Consumer<TemplatesProvider>(
        builder: (context, provider, child) {
          final categories = [
            "All",
            "Business",
            "Real Estate",
            "Personal",
            "Legal",
            "HR",
          ];
          // Since "All" is index 0 in the UI categories array, we'll map provider's string
          // backward to figure out the active visual index for the top pills.
          // By default the provider uses "Business" as active.
          final activeTabIndex = categories.indexOf(provider.selectedMainTab);

          return Column(
            children: [
              // Header & Search
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (val) => provider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: "Find your template...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppTheme.primaryLight,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.accentColor,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: GoogleFonts.inter(color: Colors.white),
                      cursorColor: AppTheme.accentColor,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Main Categories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: List.generate(categories.length, (index) {
                            // "All" tab in the UI hasn't been explicitly implemented for templates
                            // typically we just default to Business or the active tab name.
                            final catName = categories[index];
                            final isSelected = activeTabIndex == index;

                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  // Don't run logic if it's "All" mapping for now, or route to Business
                                  final targetTab = catName == "All"
                                      ? "Business"
                                      : catName;
                                  provider.setMainTab(targetTab);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade200,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    categories[index],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Dynamic Sub-Category Row
                      Builder(
                        builder: (context) {
                          final currentMainCat = provider.selectedMainTab;
                          final currentSubCats =
                              provider.categorySubcategoryMap[currentMainCat];

                          if (currentSubCats == null ||
                              currentSubCats.isEmpty) {
                            return const SizedBox.shrink(); // "All" doesn't have subcats usually, but we mapped it to nothing
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: List.generate(currentSubCats.length, (
                                  index,
                                ) {
                                  final isSelected =
                                      provider.selectedSubCategoryIndex ==
                                      index;
                                  return _buildSubCategoryChip(
                                    label: currentSubCats[index],
                                    isSelected: isSelected,
                                    onTap: () {
                                      provider.setSubCategoryIndex(index);
                                    },
                                  );
                                }),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Handle Loading/Error States globally for body contents
                      if (provider.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 80.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      else if (provider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "Error loading templates",
                                  style: GoogleFonts.inter(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => provider.fetchTemplates(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // Featured Section
                        if (provider.featuredTemplates.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Featured Templates",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.textDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: provider.featuredTemplates.length,
                              itemBuilder: (context, index) {
                                final template =
                                    provider.featuredTemplates[index];
                                final color = _getColorForCategory(
                                  template.mainCategory,
                                );
                                final icon = _getIconForCategory(
                                  template.mainCategory,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TemplatePreviewScreen(
                                              template: template,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 260,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [color, color.withOpacity(0.8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: -20,
                                          bottom: -20,
                                          child: Icon(
                                            icon,
                                            size: 120,
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          template.mainCategory ??
                                                              "Document",
                                                          style:
                                                              GoogleFonts.inter(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                      if (template.sourceName !=
                                                              null &&
                                                          template
                                                              .sourceName!
                                                              .isNotEmpty) ...[
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme
                                                                .accentColor
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            // Provide a shorter tag if sourceName is too long,
                                                            // logic normally handles this or backend supplies 'sourceAcronym'.
                                                            // We'll mimic the legacy acronym by using the first word temporarily if long.
                                                            (template
                                                                        .sourceName!
                                                                        .length >
                                                                    10)
                                                                ? template
                                                                      .sourceName!
                                                                      .split(
                                                                        ' ',
                                                                      )
                                                                      .first
                                                                : template
                                                                      .sourceName!,
                                                            style: GoogleFonts.inter(
                                                              color: AppTheme
                                                                  .primaryColor,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    template.title,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.download_rounded,
                                                    color: Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "1k+", // Dynamic default
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // All Templates Grid Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "All Templates",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Render filtered list
                        if (provider.filteredTemplates.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            child: Center(
                              child: Text(
                                "No templates found match your criteria.",
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.82,
                                ),
                            itemCount: provider.filteredTemplates.length,
                            itemBuilder: (context, index) {
                              final template =
                                  provider.filteredTemplates[index];
                              final color = _getColorForCategory(
                                template.mainCategory,
                              );
                              final icon = _getIconForCategory(
                                template.mainCategory,
                              );

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TemplatePreviewScreen(
                                                template: template,
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  icon,
                                                  color: color,
                                                  size: 24,
                                                ),
                                              ),
                                              // File type tag
                                              if (template.fileType != null)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    template.fileType ?? "DOC",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Text(
                                                template.mainCategory ?? "Doc",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (template.sourceName != null &&
                                                  template
                                                      .sourceName!
                                                      .isNotEmpty) ...[
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    "• ${(template.sourceName!.length > 10) ? template.sourceName!.split(' ').first : template.sourceName!}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      color:
                                                          AppTheme.accentColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            template.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(
                                                "Preview",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ], // End of Success States Body
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helpers for mapping colors and icons without relying on the hardcoded mock dataset classes
  Color _getColorForCategory(String? category) {
    switch (category) {
      case "Business":
        return Colors.indigo;
      case "Real Estate":
        return Colors.teal;
      case "Personal":
        return Colors.orange;
      case "Legal":
        return Colors.purple;
      case "HR":
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case "Business":
        return Icons.business_rounded;
      case "Real Estate":
        return Icons.real_estate_agent_rounded;
      case "Personal":
        return Icons.person_rounded;
      case "Legal":
        return Icons.gavel_rounded;
      case "HR":
        return Icons.people_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  // Helper to build a sub-category chip uniformly
  Widget _buildSubCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.accentColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// Wrapper to prevent issues
class IOExceptionButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final Color color;

  const IOExceptionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: icon, color: color, onPressed: onPressed);
  }
}
