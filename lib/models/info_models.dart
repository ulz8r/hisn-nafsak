import 'package:flutter/material.dart';

/// نموذج دليل أو حديث مرتبط بموضوع في قسم المعلومات
class InfoEvidence {
  final String? hadithNumber;
  final String hadithText;
  final String? narrator;
  final String? source;
  final String? ruling;

  const InfoEvidence({
    this.hadithNumber,
    required this.hadithText,
    this.narrator,
    this.source,
    this.ruling,
  });
}

/// نموذج موضوع ديني مستقل في قسم المعلومات
class InfoTopic {
  final String id;
  final String categoryId;
  final String title;
  final String? subtitle;
  final String? question;
  final String? answerOrBody;
  final String? imagePath;
  final String? imageCaption;
  final String? rulingSummary;
  final List<InfoEvidence> evidences;
  final String? footerNote;

  const InfoTopic({
    required this.id,
    required this.categoryId,
    required this.title,
    this.subtitle,
    this.question,
    this.answerOrBody,
    this.imagePath,
    this.imageCaption,
    this.rulingSummary,
    this.evidences = const [],
    this.footerNote,
  });
}

/// نموذج تصنيف في قسم المعلومات
class InfoCategory {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color primaryColor;
  final List<Color> gradientColors;
  final List<InfoTopic> topics;

  const InfoCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.primaryColor,
    required this.gradientColors,
    required this.topics,
  });
}
