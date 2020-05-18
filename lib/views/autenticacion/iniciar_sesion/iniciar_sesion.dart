
import 'package:coronavirusmed/services/auth.dart';
import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth,this.login});
  final BaseAuth auth;
  final VoidCallback login;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);




   _error(String error){
    return showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Covid-19 Tracker'),
              Divider(color: Colors.black26,)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(error),
              SizedBox(height: 10.0,),
              Divider(color: Colors.black26,)
            ],
          ),
          actions: <Widget>[

            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    Size pantalla = queryData.size;

    return Scaffold(
        body: !_loading
            ? Container(
                color: Colors.white,
                height: pantalla.height,
                width: pantalla.width,
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 10 * SizeConfig.blockSizeHorizontal,vertical: 10 * SizeConfig.blockSizeVertical),
                  child: _formulario(),
                ))
            : Center(
                child: CircularProgressIndicator(),
              ));
  }



  Widget _formulario(){
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100.0,
              ),
              _logo(),
              SizedBox(height: 75.0),

              _campoCorreo(),
              SizedBox(height: 25.0),
              _campoContrasena(),
              SizedBox(
                height: 35.0,
              ),
              SizedBox(height: 20.0),
              _botonEntrar(context),
              SizedBox(
                height: 15.0,
              ),
            ])
    );
  }



  Widget _logo(){
    return  SizedBox(
      height: 155.0,
      child: Image.asset(
        "assets/logo_covid.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _campoCorreo ()
  {
    return TextFormField(
      obscureText: false,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      validator: (val) => !val.contains('@') ? 'Este no es un correo valido' : null,
      onSaved: (value) => _email = value,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Correo",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  Widget _campoContrasena (){
    return TextFormField(
      obscureText: true,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      validator: (val) => val.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
      onSaved: (value) => _password = value,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Contraseña",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  Widget _botonEntrar (BuildContext context){
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff3380d6),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {

          final form = _formKey.currentState;
          form.save();

          if (form.validate()) {
            setState(() {
              _loading = true;
            });

            try {
              FirebaseUser result = await widget.auth.loginUser(_email, _password);
              widget.login();
              setState(() {
                _loading = false;
              });

            } on AuthException catch (error) {
              setState(() {
                _loading = false;
              });
              _error(error.message);
            } on Exception catch (error) {
              setState(() {
                _loading = false;
              });
              _error(error.toString());
            }
          }

        },
        child: Text("Entrar",
            textAlign: TextAlign.center,
            style:TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white)),
      ),
    );
  }





}
