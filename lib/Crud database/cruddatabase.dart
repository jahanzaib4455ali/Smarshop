import 'package:cloud_firestore/cloud_firestore.dart';

class Crud {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create(String uid, String name, String age, String address) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'age': age,
      'address': address,
      'role': 'user', // 🔹 Default role add kiya
    });
  }
}
