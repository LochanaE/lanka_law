import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String title;
  final String category;
  final String? subCategory;
  final String fileType;
  final String? sourceName;
  final String? sourceUrl;
  final Color color;
  final IconData icon;
  final String? sourceAcronym; // e.g., 'ROC', 'IRD', 'CMC'
  final String? downloads;

  const TemplateModel({
    required this.id,
    required this.title,
    required this.category,
    this.subCategory,
    required this.fileType,
    this.sourceName,
    this.sourceUrl,
    required this.color,
    required this.icon,
    this.sourceAcronym,
    this.downloads,
  });
}
