import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiral_app/utils/shopify_cart_apis.dart';
import 'pages/sign_up_page.dart';
import 'pages/splash_screen.dart';
import 'utils/firebase_services.dart';
import 'utils/singlenton.dart';
import 'widgets/bottom_nav.dart';

void main() async {
  // initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize SharedPreferences for fav product storage.
  await SharedPreferences.getInstance();

  // initialize sharedPreferance for storign current user.
  // final firebaseServices = FirebaseServices();
  // await firebaseServices.initSharedPreferences();

  // Initialize cart id
  dynamic cartid = await ShopifyAPI.createCart();
  print(cartid);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartItemCountProvider>(
          create: (_) => CartItemCountProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopify Integration',
      home: SplashScreen(),
    );
  }
}


// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'pages/sign_up_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp();

//     runApp(MyApp());
//   } catch (e) {
//     // Handle Firebase initialization errors
//     print('Error initializing Firebase: $e');
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Shopify Integration',
//       home: SignUpPage(),
//     );
//   }
// }
