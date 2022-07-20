


import 'package:firebase_auth/firebase_auth.dart';

import '../modal/user.dart';

class AuthMethods{
  final FirebaseAuth result =FirebaseAuth.instance;
  
  User_? _userFromFirebase(User? user){
  return user !=null ? User_(userId: user.uid): null;
}

  Future? signInWithEmailAndPassword(String email,String password)  async {
    try {
      final UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
     //String uid = credential.user!.uid; // or credential.user?.uid if you're using null-safety
      User? firebaseUser = credential.user;//firebaseUser==user parametre _userFromFirebase(User user)
     return _userFromFirebase(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }
  Future signUpwithEmailAndPassword(String email, String password)async {
    try {
            final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
            User? firebaseUser = credential.user;//firebaseUser==user parametre _userFromFirebase(User user)
            return _userFromFirebase(firebaseUser);

    } catch (e)  {
      print(e.toString());
    }
}
Future resetPass(String email)async {
  try {
    return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } catch (e) {
    print(e.toString());
  }
}
Future signOut()async {
  try {
    return await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}
}

// FirebaseUser has been changed to User

// AuthResult has been changed to UserCredential

// GoogleAuthProvider.getCredential() has been changed to GoogleAuthProvider.credential()

// onAuthStateChanged which notifies about changes to the user's sign-in state was replaced with authStateChanges()

// currentUser() which is a method to retrieve the currently logged in user, was replaced with the property currentUser and it no longer returns a Future<FirebaseUser>