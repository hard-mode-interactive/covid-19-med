import 'package:coronavirusmed/services/nexos_epidemiologicos.dart';
import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:flutter/material.dart';

class VerNexoPage extends StatefulWidget {
  VerNexoPage({this.datos});

  final datos;
  @override
  _VerNexoPageState createState() => _VerNexoPageState();
}

class _VerNexoPageState extends State<VerNexoPage> {

  BaseNexos _nexos = new Nexos();

  bool _loading = false;

  String _apiKey = 'AIzaSyC-QMvNA4hxrO6pb9pUDQYbw4inQc5Rn3M';
  String url1;
  String url2;



  void _setMarkers(){
    setState(() {
      _loading = true;
    });


    setState(() {
      url1 = "http://maps.google.com/maps/api/staticmap?center=" + widget.datos['posible_infectado']['location']['lat'].toString() + "," + widget.datos['posible_infectado']['location']['long'].toString() + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.datos['posible_infectado']['location']['lat'].toString()},${widget.datos['posible_infectado']['location']['long'].toString()}&key=${_apiKey}";
      url2 = "http://maps.google.com/maps/api/staticmap?center=" + widget.datos['infectado']['location']['lat'].toString() + "," + widget.datos['infectado']['location']['long'].toString() + "&zoom=17&size=512x256&sensor=false&&markers=color:red%7Clabel:%7C${widget.datos['infectado']['location']['lat'].toString()},${widget.datos['infectado']['location']['long'].toString()}&key=${_apiKey}";
    });

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setMarkers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POSIBLE NEXO',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        backgroundColor: Color(0xff3380d6),
      ),
      body: !_loading ? SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Una persona contagiada estuvo en el mismo lugar que otra.\nLa persona contagiada estuvo en ${widget.datos['infectado']['location']['direction']} en la fecha ${widget.datos['infectado']['date']}',style: TextStyle(fontWeight: FontWeight.bold),),
              Text('El posible infectado estuvo en ${widget.datos['posible_infectado']['location']['direction']} en la fecha ${widget.datos['posible_infectado']['date']} \nSi considera que esto es un error por favor no notifique al usuario',style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 50.0,
              ),
              Text('El paciente infectado estuvo aqui',style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                  height: 150.0,
                  child: Image.network(url1)
              ),
              SizedBox(
                height: 50.0,
              ),
              Text('El posible infectado estuvo aqui',style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                  height: 150.0,
                  child: Image.network(url2)
              ),
              SizedBox(
                height: 50.0,
              ),

              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                ),
                color: Colors.orange,
                onPressed: () async {

                  setState(() {
                    _loading = true;
                  });
                  await _nexos.notificarUnPaciente(widget.datos).then((value){
                    print(value.body);
                    setState(() {
                      _loading = false;
                    });

                    return showDialog(
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0))
                          ),
                          title: Text('Listo!'),
                          content:Text('El usuario ha sido notificado'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cerrar'),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                      context: context,
                    );
                  });
                },
                child: Text("Alertar al usuario",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              )
            ],
          ),
        ),
      ): Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
