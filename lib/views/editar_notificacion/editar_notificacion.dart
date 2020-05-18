import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../utilities/screenSize.dart';

import '../../services/notificaciones.dart';

class EditarPage extends StatefulWidget {
  EditarPage({this.currentUser,this.id,this.nombre,this.descripcion,this.contenido,this.image});
  final FirebaseUser currentUser;
  final String id;
  final String nombre;
  final String descripcion;
  final String contenido;
  final String image;

  @override
  _EditarPageState createState() => _EditarPageState();
}

class _EditarPageState extends State<EditarPage> {
  BaseNotificaciones _notificaciones = new Notificaciones();

  File _image;

  String _nombre = '';
  String _descripcion = '';
  String _contenido = '';


  bool _loading = false;

  Future getImage() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1280.0, maxWidth: 1280.0);

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _nombre = widget.nombre;
      _descripcion = widget.descripcion;
      _contenido = widget.contenido;


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff3380d6),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Editar NOTIFICACION',
            style: TextStyle(
                color: Colors.white,
                fontSize: 2.5 * SizeConfig.safeBlockVertical),
          )),
      floatingActionButton: !_loading
          ? FloatingActionButton(
        backgroundColor: Color(0xff3380d6),
        onPressed: () async {
          if (!_loading) {
            setState(() {
              _loading = true;
            });
            var notificaicon =
            await _notificaciones.actualizarNotificacion(
                widget.currentUser,
                widget.id,
                _nombre,
                _descripcion,
                _contenido,
                widget.image);
            setState(() {
              _loading = true;
            });
            Navigator.pop(context);
          }
        },
        child: Icon(
          Icons.cloud_upload,
          color: Colors.white,
        ),
      )
          : Container(),
      body: !_loading
          ? SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              TextField(
                onChanged: (val) => _nombre = val,
                controller: TextEditingController(text: _nombre),
                decoration: InputDecoration(

//                  icon: Icon(Icons.subject),
//                  labelText:'Nombre'
                    helperText: 'Nombre'),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextField(
                onChanged: (val) => _descripcion = val,
                controller: TextEditingController(text: _descripcion),

                decoration: InputDecoration(
//                  icon: Icon(Icons.description),
//                  labelText:'Descripcion'
                    helperText: 'Descripcion'),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextField(
                onChanged: (val) => _contenido = val,
                controller: TextEditingController(text: _contenido),

                maxLines: 10,
                decoration: InputDecoration(helperText: 'Contenido'
//                  icon: Icon(Icons.assignment),
//                  labelText:'Contenido'
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              InkWell(
                //onTap: getImage,
                child: Container(
                  width: 400.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: widget.image == null
                      ? Center(
                    child: Icon(Icons.image),
                  )
                      : Image.network(widget.image, fit: BoxFit.fitWidth,) ,
                ),
              ),
            ],
          ))
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
