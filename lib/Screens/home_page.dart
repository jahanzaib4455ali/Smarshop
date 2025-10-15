import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text("Mini Store 🛍️",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage(cart: [],)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history,color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
          ),
        ],
      ),

      // ✅ Overflow fix with SafeArea + Expanded GridView
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search + Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search product...',
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_alt, color: Colors.blue),
                    onSelected: (value) {
                      setState(() => selectedFilter = value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'All', child: Text('All')),
                      const PopupMenuItem(value: 'Low to High', child: Text('Price: Low to High')),
                      const PopupMenuItem(value: 'High to Low', child: Text('Price: High to Low')),
                    ],
                  ),
                ],
              ),
            ),

            // 🔥 Product Grid
            Expanded(
              child: Container(
                color: Colors.blue.shade700,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    List<DocumentSnapshot> products = snapshot.data!.docs;

                    // 🔍 Search Filter
                    products = products.where((doc) {
                      final name = doc['name'].toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    // 🔽 Sort Filter
                    if (selectedFilter == 'Low to High') {
                      products.sort((a, b) => (a['price']).compareTo(b['price']));
                    } else if (selectedFilter == 'High to Low') {
                      products.sort((a, b) => (b['price']).compareTo(a['price']));
                    }

                    // 🧾 GridView
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final name = product['name'] ?? '';
                        final price = product['price']?.toString() ?? '';
                        final image = product['image'] ?? '';
                        final description = product['description'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  name: name,
                                  price: price,
                                  image: image,
                                  description: description,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🖼️ Image (Safe fallback)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: image.isNotEmpty
                                      ? Image.network(
                                    image,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    height: 120,
                                    width: double.infinity,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                ),
                                // 🧾 Details
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rs. $price",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('$name added to cart')),
                                            );
                                          },
                                          icon: const Icon(Icons.add_shopping_cart, size: 25,color: Colors.white,),
                                          label: const Text('Add',style: TextStyle(color: Colors.white),),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
