class CartItem {
  final String id;
  final String variantId;
  final String title;
  final String imageUrl;
  final String selectedSize;
  final double itemPrice;
  final String currencyCode;
  final int quantity;
  final String priceValue;

  CartItem(
      {required this.id,
      required this.variantId,
      required this.title,
      required this.imageUrl,
      required this.selectedSize,
      required this.itemPrice,
      required this.currencyCode,
      required this.priceValue,
      required this.quantity});
}
