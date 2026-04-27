class Alert {
  const Alert({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'] as int,
        title: json['title'] as String,
        completed: json['completed'] as bool,
      );

  final int id;
  final String title;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
      };
}
