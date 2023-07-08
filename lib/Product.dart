class Product {
  final String name;
  final String description;
  final int startBid;
  final int currentBid;
  final String sellerId;
  final List<String> imageUrls;

  Product({
    required this.name,
    required this.description,
    required this.startBid,
    required this.currentBid,
    required this.sellerId,
    required this.imageUrls,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    List<dynamic> imageUrls = map['image_urls'] ?? [];

    return Product(
      name: map['name'],
      description: map['description'],
      startBid: map['start_bid'],
      currentBid: map['current_bid'],
      sellerId: map['seller_id'],
      imageUrls: imageUrls.map((url) => url.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'start_bid': startBid,
      'current_bid': currentBid,
      'seller_id': sellerId,
      'image_urls': imageUrls,
    };
  }
}
