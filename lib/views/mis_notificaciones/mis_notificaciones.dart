import 'package:coronavirusmed/services/notificaciones.dart';
import 'package:coronavirusmed/views/editar_notificacion/editar_notificacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:photo_view/photo_view.dart';

import '../../utilities/screenSize.dart';


class MisNotificacionesPage extends StatefulWidget {
  MisNotificacionesPage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _MisNotificacionesPageState createState() => _MisNotificacionesPageState();
}

class _MisNotificacionesPageState extends State<MisNotificacionesPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  BaseNotificaciones _notifiaciones = new Notificaciones();
  bool _loading = true;



  void playYoutubeVideo(String videoUrl) {
    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "AIzaSyAwr579cdq1ITdDEq3JhDqZPhQqxMiUJxY",
      videoUrl: videoUrl,
    );
  }



  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('notificaciones').orderByChild('creada_por').equalTo(widget.currentUser.uid);

    setState(() {
      _loading = false;
    });
  }

  _verNotificacion(BuildContext conext, var item, int index){
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
                  item[index]['foto'] != null ? InkWell(
                    onTap: (){
                      return showDialog(
                        builder: (context) {
                          return  Container(
                              width: SizeConfig.screenWidth,
                              height: SizeConfig.screenHeight,
                              child: PhotoView(
                                imageProvider: NetworkImage(item[index]['foto']),
                              )
                          );
                        },
                        context: context,
                      );
                    },
                    child: Image.network(item[index]['foto'],fit: BoxFit.fill,
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
                    ),
                  ) : Container(),
                  item[index]['video'] != null ? Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.transparent)
                    ),
                    child: FlatButton(
                      child: Text("Ver video",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      onPressed: (){
                        playYoutubeVideo(item[index]['video'] );
                      },
                    ),
                  ): Container()
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
  }


  void _borrarNotificacion(var item, int index) async{

    showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Confirmar'),
              Divider(color: Colors.black26,)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Esta seguro que desea borrar la notificacion?'),
              SizedBox(height: 10.0,),
              Divider(color: Colors.black26,)
            ],
          ),
          actions: <Widget>[


            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            FlatButton(
              child: Text('Confirmar'),
              onPressed: ()async {
                Navigator.pop(context);
                setState(() {
                  _loading = true;
                });
                await _notifiaciones.eliminarNotificacion(widget.currentUser, item[index]['key'], item[index]['foto']);
                setState(() {
                  _loading = false;
                });
              },
            ),
          ],
        );
      },
      context: context,
    );


  }


  void _opciones(context, var item, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.remove_red_eye),
                    title: new Text('Ver'),
                    onTap: (){
                      Navigator.pop(context);

                      _verNotificacion(context,item,index);
                    }),
                new ListTile(
                    leading: new Icon(Icons.edit),
                    title: new Text('Editar'),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => EditarPage(currentUser: widget.currentUser,id: item[index]['key'], nombre: item[index]['nombre'],descripcion: item[index]['descripcion'],contenido: item[index]['contenido'],image: item[index]['foto'],)
                      ));

                    }),
                new ListTile(
                  leading: new Icon(Icons.delete),
                  title: new Text('Eliminar'),
                  onTap: () async {

                    Navigator.pop(context);
                    _borrarNotificacion(item,index);

                  },
                ),
              ],
            ),
          );
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
          title: Text('MIS NOTIFICACIONES',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((key, data) {
                var notificacion = {
                  "key": key,
                  "nombre": data['nombre'],
                  "descripcion": data['descripcion'],
                  "contenido": data['contenido'],
                  "foto": data['foto'],
                  "video": data['video']
                };
                item.add(notificacion);
              });
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
                      onTap: (){
                        _opciones(context, item, index);
                      },
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
