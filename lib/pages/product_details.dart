import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse, parseFragment;
import 'package:html/dom.dart' as dom;
import '../const.dart';
import '../utils/shopify_cart_apis.dart';
import '../../utils/fav_product_storage.dart';

class ProductDetails extends StatefulWidget {
  final String productId;

  ProductDetails({required this.productId});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Map<String, dynamic>? productDetails;
  String selectedSize = 'Small'; // Default selected size
  int quantity = 1; // Selected quantity
  List<String> favoriteProducts = []; // List to store favorite product IDs

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
   
  }

 

  // Fetch product details
  Future<void> fetchProductDetails() async {
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;
    final String productId = widget.productId; // The selected product ID

    final String query = '''
    {
      product(id: "$productId") {
        id
        title
        descriptionHtml
        priceRange {
          minVariantPrice {
            amount
          }
        }
        images(first: 1) {
          edges {
            node {
              originalSrc
            }
          }
        }
        options {
          name
          values
        }
        variants(first: 1) {
          edges {
            node {
              id
            }
          }
        }
      }
    }
  ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Shopify-Storefront-Access-Token': storefrontApiAccessToken,
        },
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dynamic productData = data['data']['product'];
        setState(() {
          productDetails = productData;
        });

        String variantId = productData['variants']['edges'][0]['node']['id'];
        print('Variant ID: $variantId');
      } else {
        print('Failed to fetch product details: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Failed to fetch product details: $error');
    }
  }

  bool isProductFavorite(String productId) {
    return favoriteProducts.contains(productId);
  }

  void toggleFavorite(String productId) {
    setState(() {
      if (isProductFavorite(productId)) {
        favoriteProducts.remove(productId);
      } else {
        favoriteProducts.add(productId);
      }
    });
  }

  bool _isLoading = false;
  Future<void> _performAsyncTask() async {
    // Simulate a delay of 2 seconds
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    if (productDetails == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    } else {
      final title = productDetails!['title'];

      final price =
          productDetails!['priceRange']?['minVariantPrice']?['amount'] ?? '';
      final imageEdges = productDetails!['images']?['edges'] ?? [];
      final imageSrc = imageEdges[0]?['node']
          ?['originalSrc']; // Replace with a placeholder image URL

      final descriptionHtml = productDetails!['descriptionHtml'];
      final parsedDescription = parseFragment(descriptionHtml);

      final plainTextDescription = parsedDescription.text;
      final options = productDetails!['options'] ?? [];

      final dom.Document parsedDescriptionD = parse(descriptionHtml);

      final String plainTextDescriptionA = parsedDescriptionD.body!.text;
      final String productDescription =
          plainTextDescriptionA.split('\n')[1].trim();
      final variantId = productDetails!['variants']['edges'][0]['node']['id'];

      // Calculate total price
      double totalPrice = quantity * double.parse(price);

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 20),
                      color: Colors.white,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios_rounded),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            imageSrc,
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 45,
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} RS',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Karla',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Karla',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        productDescription,
                        style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 16,
                            color: Colors.grey.shade600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (options != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              options[0]['name'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              children: options[0]['values'] != null
                                  ? List<Widget>.generate(
                                      options[0]['values'].length,
                                      (index) {
                                        final optionValue =
                                            options[0]['values'][index];
                                        return ChoiceChip(
                                          label: Text(
                                            optionValue,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Karla',
                                                fontSize: 16),
                                          ),
                                          selected: selectedSize == optionValue,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              selectedSize =
                                                  selected ? optionValue : '';
                                            });
                                          },
                                        );
                                      },
                                    )
                                  : [], // Empty list if values are undefined or null
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'QUANTITY:  $quantity',
                            style: TextStyle(
                                fontFamily: 'Karla',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 1) {
                                      quantity--;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  toggleFavorite(widget
                                      .productId); // Toggle favorite status
                                  await FavoriteProductStorage
                                      .addFavoriteProductID(widget.productId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Product added to favorites'),
                                    ),
                                  );
                                },
                                child: isProductFavorite(widget.productId)
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.black,
                                        size: 30,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        print(
                                            'Variant ID on adding in cart: $variantId');

                                        // Start loading
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await ShopifyAPI.addToCart(
                                          variantId,
                                          quantity,
                                          selectedSize,
                                          totalPrice,
                                          context,
                                        );

                                        final itemCount =
                                            await ShopifyAPI.getCartItemCount(
                                                context);
                                        print(
                                            'item count in cart is: $itemCount');

                                        // Add a delay of 1 second before stopping the loading state
                                        // await Future.delayed(
                                        //     Duration(seconds: 1));

                                        // Stop loading
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        // color: Colors.white,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : Text(
                                        'ADD TO CART',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Karla',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),

                             
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
