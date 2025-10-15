import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String image; // 🔹 image field

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.image, required description,
  });

  Future<void> addToCart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection("cart").add({
        "userId": user.uid,
        "name": name,
        "price": price,
        "image": image,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Product Image or Default Icon
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: image.isNotEmpty
                    ? Image.network(
                  image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shopping_bag,
                    color: Colors.amber,
                    size: 100,
                  ),
                )
                    : const Icon(
                  Icons.shopping_bag,
                  color: Colors.amber,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Product Info
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            Text(
              "Price: Rs. $price",
              style: const TextStyle(fontSize: 18,color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "This is a sample product description. You can add more details here.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            const Spacer(),

            // 🔹 Add to Cart Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart"),
                onPressed: () async {
                  await addToCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Added to cart ✅"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
