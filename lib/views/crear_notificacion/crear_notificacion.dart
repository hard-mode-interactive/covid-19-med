import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../utilities/screenSize.dart';

import '../../services/notificaciones.dart';

class SavePage extends StatefulWidget {
  SavePage({this.currentUser});
  final FirebaseUser currentUser;

  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  BaseNotificaciones _notificaciones = new Notificaciones();

  File _image;

  String _nombre = '';
  String _descripcion = '';
  String _contenido = '';

  bool _loading = false;

  Future getImage() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1280.0, maxWidth: 1280.0);

    setState(() {
      _image = image;
    });
  }

  void _validateInputs() async {

    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      if (!_loading) {
        setState(() {
          _loading = true;
        });
        var nuevaNotificacion =
            await _notificaciones.crearNotificacion(
            widget.currentUser,
            _nombre,
            _descripcion,
            _contenido,
            _image);
        setState(() {
          _loading = false;
        });
        Navigator.pop(context);
      }
    }
    else
      {
        setState(() {
          _autoValidate = true;
        });
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff3380d6),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'CREAR  NOTIFICACION',
            style: TextStyle(
                color: Colors.white,
                fontSize: 2.5 * SizeConfig.safeBlockVertical),
          )),
      floatingActionButton: !_loading
          ? FloatingActionButton(
        backgroundColor: Color(0xff3380d6),
              onPressed:_validateInputs,
              child: Icon(
                Icons.cloud_upload,
                color: Colors.white,
              ),
            )
          : Container(),
      body: !_loading
          ? SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5.0,
                    ),
                   _dataField("Nombre:", "", TextInputType.text,(val){
                     if(val.length < 5){
                       return "Al menos 5 caracteres";
                     }
                     return null;
                   }, (val)=> _nombre = val),

                    SizedBox(
                      height: 25.0,
                    ),
                    _dataField("Descripcion:", "", TextInputType.text,(val){
                      if(val.length < 5){
                        return "Al menos 5 caracteres";
                      }
                      return null;
                    }, (val)=> _descripcion = val),
                    SizedBox(
                      height: 25.0,
                    ),
                    TextFormField(
                      validator: (val){
                        if(val.length < 25){
                          return "Al menos 25 caracteres";
                        }
                        return null;
                      },
                      onSaved: (val) => _contenido = val,
                      maxLines: 5,
                      decoration: InputDecoration(
                          helperText: 'Contenido',
                        filled: true
                          ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    InkWell(
                      onTap: getImage,
                      child: Container(
                        width: 400.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.add_a_photo),
                                  Text('Agregar foto',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold))
                                ],
                              )
                            : Image.file(
                                _image,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                    ),
                  ],
                ),
              ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _dataField(String name, String value,TextInputType textType, var validation, var save){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
          TextFormField(
            initialValue: value,
            validator: validation,
            keyboardType: textType,
            onSaved: save,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
            ),
          )
        ],
      ),
    );
  }
}
