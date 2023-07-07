import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spiral_app/utils/singlenton.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';
import '../widgets/cartItem.dart';

class ShopifyAPI {
  static String storefrontApiAccessToken = kStorefrontApiAccessTokken;
  static String shopifyDomain = kShopifyDomain;
  static String? cartId; // Variable to store the cart ID

  // get list of collections which are displayin at home screen
  static Future<List<dynamic>> fetchCollectionsForHomeScreen(
      List<String> collectionIds) async {
    final url = shopifyDomain;
    final headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': storefrontApiAccessToken,
    };

    final collectionIdString = collectionIds.map((id) => '"$id"').join(',');

    final body = json.encode({
      'query': '''
    query {
      nodes(ids: [$collectionIdString]) {
        ... on Collection {
          id
          title
          image {
            originalSrc
          }
        }
      }
    }
    ''',
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final collections = data['data']['nodes'];

      return collections;
    } else {
      throw Exception('Failed to fetch collections');
    }
  }

  static Future<String> createCart() async {
    if (cartId != null) {
      return cartId!; // Return existing cart ID if available
    }

    final String createCartMutation = '''
      mutation {
        cartCreate {
          cart {
            id
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(shopifyDomain),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': storefrontApiAccessToken,
      },
      body: jsonEncode({'query': createCartMutation}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = data['data']['cartCreate']['cart'];
      final cartId = cart['id'];

      ShopifyAPI.cartId = cartId; // Store the cart ID for reuse
      return cartId;
    } else {
      throw Exception('Failed to create cart: ${response.reasonPhrase}');
    }
  }

  static Future<void> addToCart(
    String variantId,
    int quantity,
    String selectedSize,
    double price,
    BuildContext context,
  ) async {
    final String? cartId = ShopifyAPI.cartId;

    String checkQuantityQuery = '''
    query {
      node(id: "$variantId") {
        ... on ProductVariant {
          id
          title
          quantityAvailable
        }
      }
    }
  ''';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
    };

    final Map<String, dynamic> checkQuantityBody = {
      'query': checkQuantityQuery,
    };

    final checkQuantityResponse = await http.post(
      Uri.parse(kShopifyDomain),
      headers: headers,
      body: jsonEncode(checkQuantityBody),
    );

    if (checkQuantityResponse.statusCode == 200) {
      final Map<String, dynamic> quantityData =
          jsonDecode(checkQuantityResponse.body);
      final dynamic variant = quantityData['data']['node'];

      if (variant != null) {
        int quantityAvailable = variant['quantityAvailable'];

        if (quantityAvailable >= quantity) {
          String mutation = '''
          mutation {
            cartLinesAdd(
              cartId: "$cartId",
              lines: [
                {
                  merchandiseId: "$variantId",
                  quantity: $quantity,
                  attributes: [
                    {
                      key: "Size",
                      value: "$selectedSize"
                    },
                    {
                      key: "Price",
                      value: "${price.toStringAsFixed(2)}"
                    }
                  ]
                }
              ]
            ) {
              cart {
                id
                lines(first: 10) {
                  edges {
                    node {
                      id
                      merchandise {
                        ... on ProductVariant {
                          id
                          title
                          priceV2 {
                            amount
                            currencyCode
                          }
                          product {
                            id
                            title
                          }
                        }
                      }
                      attributes {
                        key
                        value
                      }
                    }
                  }
                }
              }
            }
          }
        ''';

          final Map<String, dynamic> addToCartBody = {
            'query': mutation,
          };

          final addToCartResponse = await http.post(
            Uri.parse(kShopifyDomain),
            headers: headers,
            body: jsonEncode(addToCartBody),
          );

          if (addToCartResponse.statusCode == 200) {
            final Map<String, dynamic> data =
                jsonDecode(addToCartResponse.body);
            final dynamic cart = data['data']['cartLinesAdd']['cart'];

            print('Cart ID: ${cart['id']}');

            final List<dynamic> lineItems = cart['lines']['edges'];

            lineItems.forEach((item) {
              String itemId = item['node']['id'];
              String title = item['node']['merchandise']['product']['title'];
              dynamic price = item['node']['merchandise']['priceV2'];
              String amount = price['amount'];
              String currencyCode = price['currencyCode'];
              List<dynamic> attributes = item['node']['attributes'];
              String selectedSize = '';
              String itemPrice = '';

              attributes.forEach((attribute) {
                if (attribute['key'] == 'Size') {
                  selectedSize = attribute['value'];
                } else if (attribute['key'] == 'Price') {
                  itemPrice = attribute['value'];
                }
              });

              print('Item ID: $itemId');
              print('Title: $title');
              print('Price: $amount $currencyCode');
              print('Selected Size: $selectedSize');
              print('Item Price while adding in cart: $itemPrice');
              print('-------------------------');
            });
            final snackBar = SnackBar(
              content: Text(
                'Product added to the cart.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              backgroundColor: Colors.black,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // Update the badge count
          } else {
            print(
                'Failed to add item to cart. Status Code: ${addToCartResponse.statusCode}');
          }
        } else {
          print('Product is out of stock.');
          final snackBar = SnackBar(
            content: Text(
              'Product is out of stock.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        print('Variant data is null.');
      }
    } else {
      print(
          'Failed to check product quantity. Status Code: ${checkQuantityResponse.statusCode}');
    }
  }

  // Fetch items from cart
  static Future<List<CartItem>> fetchCartItems() async {
    final String? cartId = ShopifyAPI.cartId;
    print('Cart ID: $cartId');

    String query = '''
    query {
      cart(id: "$cartId") {
        id
        lines(first: 10) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  image {
                    originalSrc
                  }
                  priceV2 {
                    amount
                    currencyCode
                  }
                  product {
                    title
                  }
                }
              }
              attributes {
                key
                value
              }
            }
          }
        }
      }
    }
  ''';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
    };

    var body = json.encode({
      'query': query,
    });

    final response = await http.post(
      Uri.parse(kShopifyDomain),
      headers: headers,
      body: body,
    );
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dynamic cart = data['data']['cart'];

      List<dynamic> lineItems = cart['lines']['edges'];
      List<CartItem> cartItems = [];

      lineItems.forEach((item) {
        String itemId = item['node']['id'];
        int quantity = item['node']['quantity'];
        String variantId = item['node']['merchandise']['id'];
        String title = item['node']['merchandise']['product']['title'];
        String imageUrl = item['node']['merchandise']['image']['originalSrc'];
        dynamic price = item['node']['merchandise']['priceV2'];
        String currencyCode = price['currencyCode'];
        String itemPrice = price['amount'];
        List<dynamic> attributes = item['node']['attributes'];
        String selectedSize = '';
        String priceValue =
            ''; // Added variable to store the "Price" attribute value

        attributes.forEach((attribute) {
          if (attribute['key'] == 'Size') {
            selectedSize = attribute['value'];
          } else if (attribute['key'] == 'Price') {
            priceValue =
                attribute['value']; // Store the value of "Price" attribute
          }
        });

        CartItem cartItem = CartItem(
          id: itemId,
          variantId: variantId,
          title: title,
          imageUrl: imageUrl,
          itemPrice: double.parse(itemPrice),
          currencyCode: currencyCode,
          selectedSize: selectedSize,
          quantity: quantity,
          priceValue: priceValue, // Assign the extracted price value
        );

        cartItems.add(cartItem);
      });

      return cartItems;
    } else {
      print('Failed to fetch cart items. Status Code: ${response.statusCode}');
      return [];
    }
  }

  // to get total price
  static Future<double> calculateCartTotal() async {
    final List<CartItem> cartItems = await fetchCartItems();

    double total = 0;
    for (var cartItem in cartItems) {
      total += cartItem.itemPrice * cartItem.quantity;
    }

    return total;
  }

  // to remove item from cart
  static Future<bool> removeCartItem(String cartItemId) async {
    final String? cartId = ShopifyAPI.cartId;

    String mutation = '''
    mutation {
      checkoutLineItemsRemove(
        checkoutId: "$cartId",
        lineItemIds: ["$cartItemId"]
      ) {
        checkout {
          id
        }
        checkoutUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
    };

    var body = json.encode({
      'query': mutation,
    });

    final response = await http.post(
      Uri.parse(kShopifyDomain),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dynamic result = data['data']['checkoutLineItemsRemove'];

      final List<dynamic>? errors = result?['checkoutUserErrors'];
      if (errors != null && errors.isNotEmpty) {
        // Handle error(s) if needed
        return false;
      }

      // Item successfully removed from the cart
      return true;
    } else {
      print(
          'Failed to remove item from cart. Status Code: ${response.statusCode}');
      return false;
    }
  }

  //chekout function

  static Future<void> initiateCheckout(
      List<Map<String, dynamic>> lineItems) async {
    final String query = '''
    mutation checkoutCreate(\$input: CheckoutCreateInput!) {
      checkoutCreate(input: \$input) {
        checkout {
          id
          customAttributes {
            key
            value
          }
          webUrl
          subtotalPrice {
            amount
            currencyCode
          }
          totalTax {
            amount
            currencyCode
          }
          totalPrice {
            amount
            currencyCode
          }
          paymentDue {
            amount
            currencyCode
          }
        }
        checkoutUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': storefrontApiAccessToken,
    };

    final List<Map<String, dynamic>> lineItemsWithVariant =
        lineItems.map((item) {
      String variantId = item['variantId'];
      int quantity = item['quantity'];

      return {
        'variantId': variantId,
        'quantity': quantity,
      };
    }).toList();

    final Map<String, dynamic> inputVariables = {
      'lineItems': lineItemsWithVariant,
    };

    final Map<String, dynamic> variables = {'input': inputVariables};

    final String body = jsonEncode({'query': query, 'variables': variables});

    final response = await http.post(
      Uri.parse(shopifyDomain),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // Print the response data for debugging

      if (data != null &&
          data['data'] != null &&
          data['data']['checkoutCreate'] != null) {
        final checkout = data['data']['checkoutCreate']['checkout'];
        final checkoutId = checkout['id'];
        final checkoutUrl = checkout['webUrl'];
        print('Checkout URL: $checkoutUrl');

        if (await canLaunch(checkoutUrl)) {
          await launch(checkoutUrl);
        } else {
          throw Exception('Could not launch $checkoutUrl');
        }
      } else {
        throw Exception('Invalid response data');
      }
    } else {
      throw Exception('Failed to create checkout: ${response.reasonPhrase}');
    }
  }

// for getting list of variant id and quantity.
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final String? cartId = ShopifyAPI.cartId;

    String query = '''
  query {
    node(id: "$cartId") {
      ... on Cart {
        lines(first: 10) {
          edges {
            node {
              id
              merchandise {
                ... on ProductVariant {
                  id
                }
              }
              quantity
            }
          }
        }
      }
    }
  }
  ''';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
    };

    final Map<String, dynamic> body = {
      'query': query,
    };

    final response = await http.post(
      Uri.parse(kShopifyDomain),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final dynamic cart = data['data']['node'];

      final List<dynamic> lineItems = cart['lines']['edges'];

      List<Map<String, dynamic>> cartItems = [];

      lineItems.forEach((item) {
        String variantId = item['node']['merchandise']['id'];
        int quantity = item['node']['quantity'];

        cartItems.add({
          'variantId': variantId,
          'quantity': quantity,
        });
      });

      return cartItems;
    } else {
      print(
          'Failed to retrieve cart items. Status Code: ${response.statusCode}');
      return [];
    }
  }

  static Future<int> getCartItemCount(BuildContext context) async {
    final String? cartId = ShopifyAPI.cartId;

    String query = '''
    query {
      node(id: "$cartId") {
        ... on Cart {
          lines(first: 10) {
            edges {
              node {
                id
              }
            }
          }
        }
      }
    }
  ''';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
    };

    final Map<String, dynamic> body = {
      'query': query,
    };

    final response = await http.post(
      Uri.parse(kShopifyDomain),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final dynamic cart = data['data']['node'];
      final List<dynamic> lineItems = cart['lines']['edges'];
      int itemCount = lineItems.length;

      // Update the item count using the setter method
      context.read<CartItemCountProvider>().setItemCount(itemCount);

      return itemCount;
    } else {
      print(
          'Failed to retrieve cart items. Status Code: ${response.statusCode}');
      return 0;
    }
  }
}
