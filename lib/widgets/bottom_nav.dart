import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../const.dart';
import '../pages/cart_page.dart';
import '../pages/categories_page.dart';
import '../pages/fav_page.dart';
import '../pages/home_page.dart';
import '../utils/fav_product_storage.dart';
import '../utils/shopify_cart_apis.dart';
import '../utils/singlenton.dart';

class NavigationalBar extends StatefulWidget {
  // final dynamic itemCount;
  const NavigationalBar({
    Key? key,
  });
  @override
  _NavigationalBarState createState() => _NavigationalBarState();
}

class _NavigationalBarState extends State<NavigationalBar> {
  final List<Widget> _screens = [
    HomePage(),
    CategoriesPage(),
    CartPage(),
    FavPage(),
  ];

  int _selectedIndex = 0;
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int badge = 0;
  Future<void> badgeCount() async {
    final itemCount = await ShopifyAPI.getCartItemCount(context);
    setState(() {
      badge = itemCount;
    });
    print('Cart item count: $itemCount');
  }

  int badgeForFav = 0;
  Future<void> badgeCountForFav() async {
    final itemCountForFav =
        await FavoriteProductStorage.printFavoriteProductCount(context);
    setState(() {
      badgeForFav = itemCountForFav;
    });
    print('fav item count: $itemCountForFav');
  }

  @override
  void initState() {
    super.initState();
    badgeCount();
    badgeCountForFav();
    // _updateProductCount();
    // await ShopifyAPI.getCartItemCount(context);
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = context.watch<CartItemCountProvider>().itemCount;

    // product count
    final productProvider = Provider.of<ProductProvider>(context);
    final itemCountFav = productProvider.itemCount;
    productProvider.updateFavItemCount(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 0), // Adjust the offset if needed
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _navigateBottomBar,
            backgroundColor: Colors.white,
            iconSize: 20,
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            padding: EdgeInsets.all(12),
            gap: 8,
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
                textStyle: kBottomNavTextStyle,
                // onPressed: badgeCount,
              ),
              GButton(
                icon: Icons.category_outlined,
                text: 'Category',
                textStyle: kBottomNavTextStyle,
                // onPressed: badgeCount,
              ),
              GButton(
                icon: Icons.shopping_cart_checkout_outlined,
                text: 'Cart',
                textStyle: kBottomNavTextStyle,
                // onPressed: badgeCount,
                leading: badges.Badge(
                  showBadge: itemCount == 0 ? false : true,
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  badgeStyle: badges.BadgeStyle(
                      elevation: 0, badgeColor: Colors.grey.shade700),
                  badgeContent: Text(
                    '${itemCount.toString()}',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  child: Icon(
                    Icons.shopping_cart_checkout_outlined,
                    color: _selectedIndex == 2 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              GButton(
                icon: Icons.favorite_outline,
                text: 'Favorite',
                textStyle: kBottomNavTextStyle,
                // onPressed: badgeCount,
                leading: badges.Badge(
                  showBadge: itemCountFav == 0 ? false : true,
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  badgeStyle: badges.BadgeStyle(
                      elevation: 0, badgeColor: Colors.grey.shade700),
                  badgeContent: Text(
                    '$itemCountFav',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  child: Icon(
                    Icons.favorite_outline,
                    color: _selectedIndex == 3 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              // GButton(
              //   icon: Icons.favorite_outline,
              //   text: 'Favorite',
              //   // onPressed: badgeCount,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
