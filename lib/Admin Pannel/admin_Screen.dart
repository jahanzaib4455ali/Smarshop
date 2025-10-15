import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String? editProductId;
  final CollectionReference productsRef =
  FirebaseFirestore.instance.collection('products');

  Future<void> addOrUpdateProduct() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final imageUrl = imageUrlController.text.trim();

    if (name.isEmpty || desc.isEmpty || price <= 0 || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all fields!')),
      );
      return;
    }

    final data = {
      'name': name,
      'description': desc,
      'price': price,
      'image': imageUrl,
      'created_at': FieldValue.serverTimestamp(),
    };

    if (editProductId == null) {
      await productsRef.add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product Added!')),
      );
    } else {
      await productsRef.doc(editProductId).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✏️ Product Updated!')),
      );
      setState(() => editProductId = null);
    }

    nameController.clear();
    descController.clear();
    priceController.clear();
    imageUrlController.clear();
  }

  Future<void> deleteProduct(String id) async {
    await productsRef.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Product Deleted')),
    );
  }

  void startEdit(Map<String, dynamic> product, String id) {
    setState(() {
      editProductId = id;
      nameController.text = product['name'] ?? '';
      descController.text = product['description'] ?? '';
      priceController.text = product['price'].toString();
      imageUrlController.text = product['image'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('🛒 Admin Panel'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(editProductId == null
                        ? 'Add Product'
                        : 'Edit Product'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Price', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                        helperText:
                        'Paste image link (e.g. from imgbb.com or postimages.org)',
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: addOrUpdateProduct,
                        icon: const Icon(Icons.save),
                        label: Text(
                            editProductId == null ? 'Add Product' : 'Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: productsRef
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data =
                    products[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: data['image'] != null &&
                            data['image'].toString().isNotEmpty
                            ? Image.network(data['image'], width: 50)
                            : const Icon(Icons.image),
                        title: Text(data['name'] ?? ''),
                        subtitle:
                        Text('Rs. ${data['price'] ?? 0}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.orange),
                              onPressed: () =>
                                  startEdit(data, products[index].id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deleteProduct(products[index].id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
