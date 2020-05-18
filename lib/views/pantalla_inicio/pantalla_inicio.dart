

import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:coronavirusmed/views/agregar_paciente/agregar_paciente.dart';

import 'package:coronavirusmed/views/crear_notificacion/crear_notificacion.dart';
import 'package:coronavirusmed/views/mis_notificaciones/mis_notificaciones.dart';
import 'package:coronavirusmed/views/notificaciones/notificaciones.dart';
import 'package:coronavirusmed/views/pacientes/pacientes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_messaging/firebase_messaging.dart';


class HomePage extends StatefulWidget {
  HomePage({this.currentUser,this.auth,this.logOut});
  final FirebaseUser currentUser;
  final auth;
  final VoidCallback logOut;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  var uuid = Uuid();
  bool _loading = true;






  void _initNotifications(){
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called: $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called: $message');
      },
    );
  }


  void _verifyAccount() {
    setState(() {
      _loading = true;
    });
    if(widget.currentUser != null){
      databaseReference.child('medicos').child(widget.currentUser.uid).once().then((data) async {
        if(data.value == null){
          widget.logOut();

          return showDialog(
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                title: Text('Lo sentimos'),
                content:Text('El correo ${widget.currentUser.email} esta registrado pero no como medico, vuelva a iniciar sesion'),
                actions: <Widget>[
                  FlatButton(

                    child: Text('cerrar'),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  )

                ],
              );
            },
            context: context,
          );
        }

      });
    }

    setState(() {
      _loading = false;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyAccount();
    _initNotifications();


  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: Text('INICIO',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        backgroundColor: Color(0xff3380d6),

      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff3380d6),
        onPressed: (){

          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AgregarPacientePage(currentUser: widget.currentUser,)
          ));


        },
        child: Icon(Icons.person_add,color: Colors.white,),
      ),
      body: !_loading
    ? Center(
        child: Container(
          width: 75 * SizeConfig.blockSizeHorizontal,
          child: Image.asset('assets/logo_covid.png',fit: BoxFit.fitWidth,),
        )
      )
          : Center(
              child: CircularProgressIndicator(),
            ),
      drawer: Drawer(

        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage('assets/drawer.png')
                )
              ),
              accountEmail: Text(widget.currentUser.email,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),

            ListTile(
              leading:  Icon(Icons.people),
              title: Text('Mis Pacientes'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PacientesPage(currentUser: widget.currentUser,)
                ));
              },
            ),

            ListTile(
              leading:  Icon(Icons.add_alert),
              title: Text('Crear Notificacion'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SavePage(currentUser: widget.currentUser,
                        )));
              },
            ),
            ListTile(
              leading:  Icon(Icons.notifications),
              title: Text('Mis Notificaciones'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MisNotificacionesPage(currentUser: widget.currentUser,)
                ));
              },
            ),
            ListTile(
              leading:  Icon(Icons.notification_important),
              title: Text('Todas las Notificaciones'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => NotificacionesPage(currentUser: widget.currentUser,)
                ));
              },
            ),

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Salir'),
              onTap: () async {
                Navigator.pop(context);
                widget.logOut();
              },
            ),

            Padding(
              padding: EdgeInsets.all(75.0),
              child: InkWell(
                onTap: (){
                  return showDialog(
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        title: Text('Proximamente'),
                        content:Text('La aplicacion aun esta en fase de desarrollo'),
                        actions: <Widget>[
                          FlatButton(

                            child: Text('cerrar'),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          )

                        ],
                      );
                    },
                    context: context,
                  );
                },
                  child: Text('Politica de privacidad',style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
          ],
        ),
      ),
    );
  }
}
