
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

abstract class BaseNotificaciones {

  Future<DataSnapshot> crearNotificacion(FirebaseUser currentUser,String nombre, String descripcion, String contenido, File _image) ;
  Future<DataSnapshot> eliminarNotificacion(FirebaseUser currentUser, String key, String foto);
  Future<DataSnapshot> actualizarNotificacion(FirebaseUser currentUser, String key, String nombre, String descripcion, String contenido, String url);
}

class Notificaciones implements BaseNotificaciones  {

  final databaseReference = FirebaseDatabase.instance.reference();
  final storageReference = FirebaseStorage.instance.ref();
  var uuid = Uuid();



  Future<DataSnapshot> crearNotificacion(FirebaseUser currentUser,String nombre, String descripcion, String contenido, File _image) async {

    /*Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();
    final Position currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final coordinates = new Coordinates(currentLocation.latitude,currentLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;*/
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(now);

    var url;


    if(_image != null){


      StorageUploadTask uploadTask = storageReference.child(currentUser.uid)
          .child('notificaciones').child(uuid.v4()).putFile(_image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      url = await taskSnapshot.ref.getDownloadURL();

    }

    Map<String,dynamic> notificacion = {


      /*'location': {
        'lat':'${currentLocation.latitude}',
        'long':'${currentLocation.longitude}',
        'direccion': '${first.addressLine}',
      },*/
      'nombre':nombre,
      'descripcion':descripcion,
      'contenido':contenido,
      'foto': url,
      'creada_por': currentUser.uid,
      'fecha': formattedDate



    };



    databaseReference.child('notificaciones').child(uuid.v4()).set(notificacion).then((val){

      return val;

    });


  }

  Future<DataSnapshot> actualizarNotificacion(FirebaseUser currentUser, String key, String nombre, String descripcion, String contenido, String url){

    Map<String,dynamic> notificacion = {


      'nombre':nombre,
      'descripcion':descripcion,
      'contenido':contenido

    };

    print(notificacion);
    databaseReference.child('notificaciones').child(key).update(notificacion).then((val){
      return val;
    });


  }
  
  Future<DataSnapshot> eliminarNotificacion(FirebaseUser currentUser, String key, String foto){

    if(foto != null){
      FirebaseStorage.instance.getReferenceFromUrl(foto).then((val){
        val.getPath().then((path){
          storageReference.child(path).delete().whenComplete((){
            databaseReference.child('notificaciones').child(key).remove().then((val){
              return val;
            });
          });
        });
      });



    }
    else
      {
        databaseReference.child('notificaciones').child(key).remove().then((val){
          return val;
        });
      }

  }



}