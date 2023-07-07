import 'package:flutter/material.dart';
import '../utils/firebase_services.dart';
import '../utils/shopify_cart_apis.dart';
import '../widgets/cartItem.dart';
import 'sign_up_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 8, right: 8),
          child: Column(
            children: [
              Text(
                'My Cart',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Karla'),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: FutureBuilder<List<CartItem>>(
                  future: ShopifyAPI.fetchCartItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child:
                            Text('Error occurred while fetching cart items.'),
                      );
                    } else {
                      final cartItems = snapshot.data;

                      if (cartItems == null || cartItems.isEmpty) {
                        return Center(
                          child: Text(
                            'Cart is empty.',
                            style: TextStyle(
                                fontFamily: 'Karla',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];

                          return CartItemCard(cartItem: cartItem);
                        },
                      );
                    }
                  },
                ),
              ),
              CartTotalCard(),
              SizedBox(height: 8),
              CheckoutButton(),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;

  const CartItemCard({required this.cartItem});

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  int quantity = 1;

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image (You can replace the placeholder image with the actual product image)
            Container(
              width: 80,
              height: 80,
              color: Colors.white,
              child: Image.network(widget.cartItem.imageUrl),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  // Title
                  Text(
                    widget.cartItem.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Karla',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Size
                  Text(
                    'Size: ${widget.cartItem.selectedSize}',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey, fontFamily: 'Karla'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Quantity: ${widget.cartItem.quantity}',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey, fontFamily: 'Karla'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${widget.cartItem.priceValue} ${widget.cartItem.currencyCode}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Karla'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartTotalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Price:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Karla'),
            ),
            FutureBuilder<double>(
              future: ShopifyAPI.calculateCartTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: Colors.black,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error occurred while calculating total.');
                } else {
                  final total = snapshot.data ?? 0;

                  return Text(
                    '$total PKR',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Karla'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


class CheckoutButton extends StatefulWidget {
  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  final FirebaseServices firebaseServices = FirebaseServices();

  Future<bool> loggedInStatus() async {
    return await firebaseServices.getUserLoginState();
  }

  void finalCheckOut() async {
    // Implement checkout functionality
    List<Map<String, dynamic>> cartItems = await ShopifyAPI.getCartItems();
    await ShopifyAPI.initiateCheckout(cartItems);
    // Iterate over the cart items and access the variantId and quantity
    cartItems.forEach((item) {
      String variantId = item['variantId'];
      int quantity = item['quantity'];

      print('Variant ID: $variantId');
      print('Quantity: $quantity');
      print('-------------------------');
    });
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await Future.delayed(Duration(seconds: 1));
                  bool isLoggedIn = await loggedInStatus();
                  if (isLoggedIn == false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    );
                  } else {
                    finalCheckOut();
                  }
                  await Future.delayed(Duration(seconds: 1));
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                        // color: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Checkout',
                        style: TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
