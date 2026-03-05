import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/screen_widgets/gazette/gazettes_view.dart';

class DocumentLibraryScreen extends StatefulWidget {
  const DocumentLibraryScreen({super.key});

  @override
  State<DocumentLibraryScreen> createState() => _DocumentLibraryScreenState();
}

class _DocumentLibraryScreenState extends State<DocumentLibraryScreen> {
  final List<String> categories = [
    "All",
    "Contracts",
    "Court Forms",
    "Gazettes",
    "Acts",
    "Circulars"
  ];
  int selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> documents = [
    {
      "title": "Employment Contract Template",
      "type": "PDF",
      "size": "2.4 MB",
      "date": "12 Dec 2024",
      "category": "Contracts",
      "icon": Icons.description_outlined,
      "color": Colors.blue,
    },
    {
      "title": "Vehicle Sale Agreement",
      "type": "DOCX",
      "size": "1.1 MB",
      "date": "10 Dec 2024",
      "category": "Contracts",
      "icon": Icons.handshake_outlined,
      "color": Colors.green,
    },
    {
      "title": "Supreme Court Rules 2023",
      "type": "PDF",
      "size": "5.8 MB",
      "date": "05 Dec 2024",
      "category": "Court Forms",
      "icon": Icons.gavel_outlined,
      "color": Colors.purple,
    },
    {
      "title": "Gazette Extraordinary No. 2345/12",
      "type": "PDF",
      "size": "800 KB",
      "date": "01 Dec 2024",
      "category": "Gazettes",
      "icon": Icons.article_outlined,
      "color": Colors.orange,
    },
    {
      "title": "Affidavit for Lost Identity Card",
      "type": "PDF",
      "size": "1.5 MB",
      "date": "28 Nov 2024",
      "category": "Court Forms",
      "icon": Icons.fingerprint_rounded,
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Document Library",
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
      body: Column(
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
                  decoration: InputDecoration(
                    hintText: "Search documents, acts, forms...",
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppTheme.primaryLight,
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
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
                      borderSide: const BorderSide(color: AppTheme.accentColor, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  
                  // Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final isSelected = selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                categories[index],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Content switching logic
                  if (categories[selectedCategoryIndex] == "Gazettes")
                    const GazettesView()
                  else ...[
                    // Recent Documents Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Documents",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: Text(
                              "See All",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Documents List (Generic)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        // Filter logic (simple)
                        if (selectedCategoryIndex != 0 &&
                            categories[selectedCategoryIndex] != doc['category']) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: (doc['color'] as Color).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        doc['icon'],
                                        color: doc['color'],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['title'],
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                doc['category'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Container(
                                                width: 3,
                                                height: 3,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                doc['size'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Container(
                                                width: 3,
                                                height: 3,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                doc['date'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  
                  // Ensure space at bottom
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper for IconButton to ensure consistent sizing/styling if needed
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
    return IconButton(
      icon: icon,
      color: color,
      onPressed: onPressed,
    );
  }
}
