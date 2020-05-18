//import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utilities/screenSize.dart';


class NotificacionesPage extends StatefulWidget {
  NotificacionesPage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  bool _loading = true;



  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('notificaciones');

    setState(() {
      _loading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xff3380d6),
          title: Text('NOTIFICACIONES',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((index, data) => item.add({"key": index, ...data}));

              return ListView.builder(
                itemCount: item.length,

                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 10.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      dense: true,
                      leading: Icon(Icons.warning,color: Colors.red,),
                      title: Text('${item[index]['nombre']}'),
                      subtitle: Text('${item[index]['descripcion']}'),
                      onTap: item[index]['contenido'] != null ?  () {
                        return showDialog(
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              title: Text('Informacion'),
                              content:SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Text('${item[index]['contenido']}'),
                                    SizedBox(
                                      height: 25.0,
                                    ),
                                    item[index]['foto'] != null ? Image.network(item[index]['foto'],fit: BoxFit.fill,
                                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: Column(
                                            children: <Widget>[
                                              Text('Cargando imagen'),
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null ?
                                                loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                    : null,
                                              ),
                                            ],
                                          )
                                        );
                                      },
                                    ) : Container()
                                  ],
                                )
                              ),
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
                      }: (){},
                    ),
                  );
                },
              );
            }
            else
              return Center(
                child: Text('No hay informacion.',style: TextStyle(color: Colors.black26),),
              );
          },
        ) : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
