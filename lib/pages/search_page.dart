import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../const.dart';
import 'product_details.dart';

class MySearchDelegate extends SearchDelegate<String> {
  final List<dynamic> items;

  MySearchDelegate({required this.items});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredItems = items
        .where((item) => item['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Text('No products found :('),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading:
              Image.network(item['images']['edges'][0]['node']['originalSrc']),
          title: Text(item['title']),
          onTap: () {
            // Handle item selection
            final String productId = item['id'];
            final String variantId = item['variants']['edges'][0]['node']['id'];
            // Do something with the productId and variantId
            close(context, item['title']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredItems = items
        .where((item) => item['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          child: ListTile(
            leading: Image.network(
                item['images']['edges'][0]['node']['originalSrc']),
            title: Text(item['title']),
            onTap: () {
              // Handle item selection
              final String productId = item['id'];
              final String variantId =
                  item['variants']['edges'][0]['node']['id'];
              // Do something with the productId and variantId
              // close(context, item['title']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetails(
                    productId: productId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MySearchPage extends StatefulWidget {
  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;

    final String query = '''
      {
        products(first: 200) {
          edges {
            node {
              id
              title
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
              variants(first: 1) {
                edges {
                  node {
                    id
                  }
                }
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
        final List<dynamic> productEdges = data['data']['products']['edges'];
        setState(() {
          products = productEdges
              .map((edge) => edge['node'])
              .where((node) => node != null)
              .toList();
          isLoading = false; // Set loading state to false
        });
      } else {
        print('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'Search Products',
          style: TextStyle(fontFamily: 'karla', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Open search page and wait for selection
              final selected = await showSearch<String>(
                context: context,
                delegate: MySearchDelegate(items: products),
              );

              // Handle selected item
              if (selected != null) {
                print('Selected: $selected');
              }
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: isLoading // Show circular progress indicator if loading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Card(
                  child: ListTile(
                    title: Text(item['title']),
                    onTap: () {
                      // Handle item selection
                      final String productId = item['id'];
                      final String variantId =
                          item['variants']['edges'][0]['node']['id'];
                      // Do something with the productId and variantId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetails(
                            productId: productId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
