// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:shopify_api_app/pages/cart_page.dart';
// import 'package:shopify_api_app/pages/categories_page.dart';
// import 'package:shopify_api_app/pages/fav_page.dart';
// import 'package:shopify_api_app/pages/home_page.dart';

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     HomePage(),
//     CategoriesPage(),
//     CartPage(),
//     FavPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: GNav(
//           gap: 8,
//           activeColor: Colors.white,
//           iconSize: 24,
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           duration: Duration(milliseconds: 800),
//           tabBackgroundColor: Colors.blue,
//           tabs: [
//             GButton(
//               icon: Icons.home,
//               text: 'Home',
//             ),
//             GButton(
//               icon: Icons.search,
//               text: 'Search',
//             ),
//             GButton(
//               icon: Icons.favorite,
//               text: 'Favorites',
//             ),
//             GButton(
//               icon: Icons.person,
//               text: 'Profile',
//             ),
//           ],
//           selectedIndex: _selectedIndex,
//           onTabChange: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Home Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// class SearchScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Search Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// class FavoritesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Favorites Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Profile Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }
