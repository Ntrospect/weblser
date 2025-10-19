class Analysis {
  final String id;
  final String url;
  final String? title;
  final String? metaDescription;
  final String summary;
  final bool success;
  final DateTime createdAt;

  Analysis({
    required this.id,
    required this.url,
    this.title,
    this.metaDescription,
    required this.summary,
    required this.success,
    required this.createdAt,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      metaDescription: json['meta_description'] as String?,
      summary: json['summary'] as String,
      success: json['success'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
    'meta_description': metaDescription,
    'summary': summary,
    'success': success,
    'created_at': createdAt.toIso8601String(),
  };
}
