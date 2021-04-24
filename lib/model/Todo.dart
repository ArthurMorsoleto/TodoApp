class Todo {
  String title;
  String description;
  bool isFinished;

  Todo();

  Todo.from(String title, String description) {
    this.title = title;
    this.description = description;
    this.isFinished = false;
  }

  Todo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        isFinished = json['is_finished'];

  Map toJson() =>
      {'title': title, 'description': description, 'is_finished': isFinished};
}
