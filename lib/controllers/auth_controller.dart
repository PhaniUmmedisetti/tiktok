import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/user.dart' as model;

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  Rx<File?> _pickedImage = Rxn<File?>();
  File? get profilePhoto => _pickedImage.value;

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

  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilrPics')
        .child(firebaseAuth.currentUser!.uid);

    print("ref: $ref");

    UploadTask uploadTask = ref.putFile(image);

    print("upload: $uploadTask");
    TaskSnapshot snap = await uploadTask;
    print("snap: $snap");
    String downloadUrl = await snap.ref.getDownloadURL();
    print("upload: $downloadUrl");
    return downloadUrl;
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
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profileUrl: downloadUrl,
        );
        await firestore
            .collection('users')
            .doc(cred.user?.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Error creating an account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error creating an account',
        e.toString(),
      );
    }
  }
}
