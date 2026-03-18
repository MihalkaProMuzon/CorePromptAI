class AIModel {
  final String id;
  final String name;
  final double promptPrice;
  final double completionPrice;
  final int contextLength;

  AIModel({
    required this.id,
    required this.name,
    required this.promptPrice,
    required this.completionPrice,
    required this.contextLength,
  });

  factory AIModel.fromApi(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    int parseContext(dynamic value) {
      return int.tryParse(value.toString()) ?? 0;
    }

    return AIModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['id'] ?? '',
      promptPrice: parsePrice(json['pricing']?['prompt']),
      completionPrice: parsePrice(json['pricing']?['completion']),
      contextLength: parseContext(
        json['context_length'] ?? json['top_provider']?['context_length'],
      ),
    );
  }
}
