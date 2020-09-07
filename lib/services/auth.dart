
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


abstract class BaseAuth {
  Future<FirebaseUser> getUser();
  Future logout();
  Future<FirebaseUser> loginUser(String email, String password);
  Future<void> resetPassword(String email);
}

class Auth  implements BaseAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  final firebaseMessaging = new FirebaseMessaging();
  final backEndUrl = "https://us-central1-covid-19-cc7c5.cloudfunctions.net/app";

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future logout() async {
    var result = FirebaseAuth.instance.signOut();
    return result;
  }




  void Autenticar(email,password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('backEndUrl', backEndUrl);
    Map <String,dynamic> body = {
      "email":email,
      "password":password
    };
    http.post(backEndUrl + '/api/medicos/login', headers: {"Content-Type": 'application/json'}, body: jsonEncode(body)).then((response) {
      if (response.statusCode == 200) {
        Map<String,dynamic> datosObtenidos = jsonDecode(response.body);
        prefs.setString('token', 'Bearer ' +  datosObtenidos['user']['accessToken']);
        prefs.setString('refreshtoken', datosObtenidos['user']['refreshToken']);

      }
    }).catchError((e){
      print(e);
    });
  }

  Future<FirebaseUser> loginUser(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      var result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      databaseReference.child('medicos').child(result.user.uid).once().then((data) async {
        if(data.value != null){
          if(data.value['correo'] != result.user.email){
            await databaseReference.child('medicos').child(result.user.uid).child('informacion').child('correo').set(email);

          }

          firebaseMessaging.getToken().then((token) async {
            prefs.setString('fcm_token', token);
            if(token != data.value['fcm_token'])
            {
              await databaseReference.child('medicos').child(result.user.uid).child('informacion').child('fcm_token').set(token);
            }
          });

        }
      });

      Autenticar(email, password);
      return result.user;
    }  catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }


  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
