import 'package:flutter/material.dart';
import 'package:spiral_app/utils/shopify_cart_apis.dart';

import 'fav_product_storage.dart';

class CartItemCountProvider with ChangeNotifier {
  int _itemCount = 0;

  int get itemCount => _itemCount;

  void setItemCount(int count) {
    _itemCount = count;
    notifyListeners();
  }

  Future<void> updateCartItemCount(BuildContext context) async {
    int count = await ShopifyAPI.getCartItemCount(context);
    setItemCount(count);
  }
}

class ProductProvider with ChangeNotifier {
  int _itemCount = 0;

  int get itemCount => _itemCount;

  void setItemCount(int count) {
    _itemCount = count;
    notifyListeners();
  }

  Future<void> updateFavItemCount(BuildContext context) async {
    int count = await FavoriteProductStorage.printFavoriteProductCount(context);
    setItemCount(count);
  }
}
