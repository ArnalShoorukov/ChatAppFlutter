import 'dart:io';

import 'package:chat_app/widgets/auth/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  String url = '';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitFrom(
    String email,
    String name,
    String password,
    File image,
    bool isLogin,
    BuildContext context,
  ) async {
    AuthResult authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

       final ref =  FirebaseStorage.instance
            .ref()
            .child(
              'user_image',
            )
            .child(
              authResult.user.uid + 'jpg',
            );

       print('Reference $ref');


        ref.putFile(image).onComplete;

       final url = await ref.getDownloadURL();

  /*      //await ref.getDownloadURL();
        StorageUploadTask uploadTask = ref.putFile(image);
        await uploadTask.onComplete.then((taskSnapshot) async {
          var _uploadedFileURL = await taskSnapshot.ref.getDownloadURL();
          setState(() {
            widget.url = _uploadedFileURL;
          });
          print("Successfully uploaded profile picture $_uploadedFileURL" );
        }).catchError((e) {
          print("Failed to upload profile picture");
        });*/


       print(url);

        await Firestore.instance.collection('users').document(authResult.user.uid).setData(
          {
            'username': name,
            'email': email,
            'image_url' : url,
          },
        );
      }
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials!';
      print(message);
      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitFrom, _isLoading),
    );
  }
}
