class AIInsight {
  final String summary;
  final String priority;
  final String recommendation;
  final bool warningFlag;

  AIInsight({
    required this.summary,
    required this.priority,
    required this.recommendation,
    required this.warningFlag,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'priority': priority,
      'recommendation': recommendation,
      'warningFlag': warningFlag,
    };
  }

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      summary: json['summary'],
      priority: json['priority'],
      recommendation: json['recommendation'],
      warningFlag: json['warningFlag'],
    );
  }
}
