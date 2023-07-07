import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProductStorage {
  // Retrieve favorite product IDs from user session
  static Future<List<String>> getFavoriteProductIDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoriteProductIDs = prefs.getStringList('favoriteProductIDs') ?? [];
    print('Favorite Product IDs: $favoriteProductIDs');
    return favoriteProductIDs;
  }

  // fav products counts...
  static Future<int> printFavoriteProductCount(BuildContext context) async {
    List<String> favoriteProductIDs = await getFavoriteProductIDs();
    int count = favoriteProductIDs.length;
    return count;
  }

  // Add a new favorite product ID to user session
  static Future<void> addFavoriteProductID(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteProductIDs = await getFavoriteProductIDs();
    favoriteProductIDs.add(productId);
    await prefs.setStringList('favoriteProductIDs', favoriteProductIDs);
    print('Product ID added to favorites.');
  }

  // Delete a specific product from favorites
  static Future<void> deleteProductFromFavorites(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteProductIds =
        await getFavoriteProductIDs(); // Load the IDs from SharedPreferences

    favoriteProductIds.remove(productId); // Remove the specified ID

    await prefs.setStringList('favoriteProductIDs', favoriteProductIds);
    print('Product ID removed from favorites.');
  }

  // Clear all data stored in SharedPreferences
  static Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared.');
  }

  // Check if a product ID is present in favorites
  static Future<bool> isProductFavorite(String productId) async {
    List<String> favoriteProductIDs = await getFavoriteProductIDs();
    return favoriteProductIDs.contains(productId);
  }
}
