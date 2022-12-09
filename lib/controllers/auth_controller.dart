import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/user.dart' as model;
import 'package:tiktok/views/screens/auth/login_screen.dart';

import '../views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  Rx<File?> _pickedImage = Rxn<File?>();
  File? get profilePhoto => _pickedImage.value;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(LoginScreen());
    } else {
      Get.offAll(HomeScreen());
    }
  }

  void pickedImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar(
          'profile picture', 'you have successfully uploaded profile picture');
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  //upload to firebase storage

  // Future<String> _uploadToStorage(File image) async {
  //   Reference ref = firebaseStorage
  //       .ref()
  //       .child('profilePics/${firebaseAuth.currentUser!.uid}');

  //   // print("ref: $ref");

  //   // UploadTask uploadTask = ref.putFile(image);

  //   // print("upload: $uploadTask");
  //   // TaskSnapshot snap = await uploadTask;
  //   // print("snap: $snap");
  //   // String downloadUrl = await snap.ref.getDownloadURL();
  //   // print("upload: $downloadUrl");
  //   // return downloadUrl;

  //   //  Reference reference = storage.ref(filePath);

  //   UploadTask uploadTask = ref.putFile(image);

  //   final storageSnapshot = uploadTask.snapshot;

  //   final downloadUrl = await storageSnapshot.ref.getDownloadURL();
  //   debugPrint(downloadUrl);
  //   return downloadUrl;

//     await ref.putFile(_secilenresim);
// var downloadUrl = await ref.getDownloadURL();
  // }

  Future _uploadToStorage({
    File? image,
  }) async {
    try {
      String fileName = firebaseAuth.currentUser!.uid;
      Reference ref = firebaseStorage.ref().child("profilePictures/$fileName");
      UploadTask uploadTask = ref.putFile(image!);

      return await uploadTask.then((res) async {
        return await res.ref.getDownloadURL();
      });

      // print(" img res out : $imgRes");
      // String imageUrl = imgRes;
      // return imageUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Registering the user
  void registerUser(
      String username, String email, String password, File? image) async {
    print("----------------- printing info -----------------");
    print(username);
    print(email);
    print(password);
    print(image);
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save user in firebase firestore
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("cred: $cred");
        print("image: $image");
        String downloadUrl = await _uploadToStorage(image: image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profileUrl: downloadUrl,
        );
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Error creating an account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      print(e);
    }
  }

// Login User
  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        print('log successful');
      } else {
        Get.snackbar(
          'Error creating an account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error creating an account',
        e.toString(),
      );
    }
  }
}
