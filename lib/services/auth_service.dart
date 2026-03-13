import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // ✅ Current UID (easy access)
  String? get currentUid => _auth.currentUser?.uid;

  // ✅ Get Firebase ID token (for backend Authorization header)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  // ✅ Require token (throws if not logged in)
  Future<String> requireIdToken({bool forceRefresh = false}) async {
    final token = await getIdToken(forceRefresh: forceRefresh);
    print(token);
    if (token == null) {
      throw Exception("User not logged in");
    }
    return token;
  }

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Register with Email and Password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update Display Name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);

        try {
          await saveUserToFirestore(
            uid: userCredential.user!.uid,
            name: name,
            email: email,
            role: role,
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          print("Firestore timeout or error: $e");
        }

        // require login after registration
        await _auth.signOut();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Save user to Firestore
  Future<void> saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving user to Firestore: $e");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to handle Firebase Exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password provided.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'network-request-failed':
        return Exception(
          'Network error. Please check your internet connection.',
        );
      case 'too-many-requests':
        return Exception('Too many login attempts. Please try again later.');
      default:
        return Exception(e.message ?? 'An authentication error occurred.');
    }
  }

  // Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] as String?;
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
    return null;
  }

  // Upload Profile Picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      throw Exception("Failed to upload profile picture");
    }
  }

  // Delete Profile Picture
  Future<void> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await ref.delete();
      await user.updatePhotoURL(null);

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error deleting profile picture: $e");
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Stream of auth changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // Current User
//   User? get currentUser => _auth.currentUser;

//   // Sign in with Email and Password
//   Future<UserCredential> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       return await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthException(e);
//     } catch (e) {
//       throw Exception('An unknown error occurred.');
//     }
//   }

//   // Register with Email and Password
//   Future<UserCredential> createUserWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String name,
//     required String role,
//   }) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Update Display Name
//       if (userCredential.user != null) {
//         await userCredential.user!.updateDisplayName(name);

//         try {
//           // Save user data to Firestore with a timeout to prevent UI hanging
//           await saveUserToFirestore(
//             uid: userCredential.user!.uid,
//             name: name,
//             email: email,
//             role: role,
//           ).timeout(const Duration(seconds: 5));
//         } catch (e) {
//           print("Firestore timeout or error: $e");
//         }

//         // To require the user to log in after registration, sign them out initially
//         await _auth.signOut();
//       }

//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthException(e);
//     } catch (e) {
//       throw Exception('An unknown error occurred.');
//     }
//   }

//   // Save user to Firestore
//   Future<void> saveUserToFirestore({
//     required String uid,
//     required String name,
//     required String email,
//     required String role,
//   }) async {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'name': name,
//         'email': email,
//         'role': role,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print("Error saving user to Firestore: $e");
//       // Optionally rethrow or handle explicitly
//     }
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // Helper to handle Firebase Exceptions
//   Exception _handleAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//       case 'wrong-password':
//       case 'invalid-credential':
//         return Exception('Invalid email or password provided.');
//       case 'email-already-in-use':
//         return Exception('The account already exists for that email.');
//       case 'weak-password':
//         return Exception('The password provided is too weak.');
//       case 'invalid-email':
//         return Exception('The email address is not valid.');
//       case 'network-request-failed':
//         return Exception(
//           'Network error. Please check your internet connection.',
//         );
//       case 'too-many-requests':
//         return Exception('Too many login attempts. Please try again later.');
//       default:
//         return Exception(e.message ?? 'An authentication error occurred.');
//     }
//   }

//   // Get User Role
//   Future<String?> getUserRole(String uid) async {
//     try {
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//       if (doc.exists && doc.data() != null) {
//         return (doc.data() as Map<String, dynamic>)['role'] as String?;
//       }
//     } catch (e) {
//       print("Error fetching user role: $e");
//     }
//     return null;
//   }

//   // Get Firebase ID token (for backend authorization)
//   Future<String?> getIdToken() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;
//     return await user
//         .getIdToken(); // optionally: getIdToken(true) to force refresh
//   }
// }
