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
    required String requester_email,
  }) async {
    DocumentSnapshot doc = await users.doc(email).get();

    if (doc.exists) {
      // Document exists, proceed with the update
      return users.doc(email).update({
        'request': FieldValue.arrayUnion([requester_email]),
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

  Future<void> updateAllMedicationTaken({
    required String email,
    required List<Map<String, dynamic>> medications,
  }) {
    // Use the email as the document ID
    return users.doc(email).update({
      'medications': medications,
    });
  }

  Future<void> updateMedicationTaken({
    required String email,
    required int index,
    required bool value,
    required DateTime time,
  }) async {
    // Get the current document
    DocumentSnapshot docSnapshot = await users.doc(email).get();

    if (docSnapshot.exists) {
      // Retrieve the medications array
      List<dynamic> medications = docSnapshot['medications'];

      // Check if the index is valid
      if (index < medications.length) {
        // Update the 'taken' field for the specific medication
        medications[index]['taken'] = {
          'value': value,
          'date': Timestamp.fromDate(time),
        };

        // Write the updated array back to Firestore
        await users.doc(email).update({'medications': medications});
      } else {
        print("Index out of bounds for medications array.");
      }
    } else {
      print("Document does not exist.");
    }
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
