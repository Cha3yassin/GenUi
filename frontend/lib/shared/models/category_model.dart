import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: _iconFromName(json['icon'] as String),
      accentColor: Color(json['accentColor'] as int),
    );
  }

  static IconData _iconFromName(String name) {
    return switch (name) {
      'directions_car' => Icons.directions_car_rounded,
      'home_work' => Icons.home_work_rounded,
      'business_center' => Icons.business_center_rounded,
      'badge' => Icons.badge_rounded,
      _ => Icons.article_rounded,
    };
  }
}
