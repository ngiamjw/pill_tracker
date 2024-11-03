import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection of users
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  //CREATE: add a new user
  Future<void> addUser({
    required String email,
    required List<Map<String, dynamic>> medications,
  }) {
    // Use the email as the document ID
    return users.doc(email).set({
      'email': email,
      'medications': medications,
      'permissions': [],
      'request': [],
      'requested_users': []
    });
  }
  //READ: get user info from database

  Stream<DocumentSnapshot> getUserStream(String email) {
    return users.doc(email).snapshots();
  }

  //UPDATE: update user info given a doc id

  Future<void> updateUser({
    required String email,
    required List<Map<String, dynamic>> medications,
  }) {
    // Use the email as the document ID
    return users.doc(email).update({
      'medications': medications,
    });
  }

  Future<void> updateRequest({
    required String email,
    required String request_email,
  }) async {
    DocumentSnapshot doc = await users.doc(email).get();

    if (doc.exists) {
      // Document exists, proceed with the update
      return users.doc(email).update({
        'request': FieldValue.arrayUnion([request_email]),
      });
    } else {
      // Handle the case when the document does not exist
      throw Exception("Document does not exist");
    }
  }

  Future<void> updatePermissions(
      {required String email, required String request_email}) {
    // Use the email as the document ID
    return users.doc(email).update({
      'permissions': FieldValue.arrayUnion([request_email]),
    });
  }

  Future<void> updateRequestedUsers(
      {required String email, required String request_email}) {
    // Use the email as the document ID
    return users.doc(email).update({
      'requested_users': FieldValue.arrayUnion([request_email]),
    });
  }

  //DELETE: delete user given a doc id

  Future<void> removeRequest({
    required String email,
    required String requestEmail,
  }) {
    // Use the email as the document ID
    return users.doc(email).update({
      'request': FieldValue.arrayRemove([requestEmail]),
    });
  }
}
