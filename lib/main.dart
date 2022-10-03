import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 1 método main
// el único que se ejecuta de manera "automatica"
void main() {
  runApp(const MyApp());
}

// Widget
// componente de UI
// todas las interfaces están hechas de widgets
// existen 2 categorías
// - stateless - interfaz no cambia
// - stateful - interfaz cambia basada en un estado

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaWidget(),
    );
  }
}

class ListaWidget extends StatefulWidget {

  @override
  _ListaWidgetState createState() => _ListaWidgetState();

}

class _ListaWidgetState extends State<ListaWidget>{

  List<String> _contenido = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"];
  TextStyle _estilito = const TextStyle(fontSize: 15.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("APLICACIÓN CHIDA"),
      ),
      body: _construyeLista(), // Tiene un text pero quiero agregar algo más complejo
    );
  }

  Widget _construyeLista() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _contenido.length,
        itemBuilder: (context, i) {
          return _construyeRow(_contenido[i]);
        },
    );
  }

  Widget _construyeRow(String valor) {
    return ListTile(
      title: Text(
        valor,
        style: _estilito,
      ),
      onTap: () {
        Fluttertoast.showToast(
          msg: "PRESIONASTE UN ROW: " + valor,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VistaRequest(paseDeArgs: valor)
            )
        );
      },
    );
  }
}

class VistaDetalle extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("EL DETALLE AQUI"),
      ),
      body: Center(
          child: Text("ESTA ES UNA VISTA DE DETALLE!"),
      ),
    );
  }

}

// segunda versión de lista detalle
// en esta haremos request
class VistaRequest extends StatefulWidget {

  VistaRequest({required this.paseDeArgs});

  final String paseDeArgs;

  @override
  _VistaRequestState createState() => _VistaRequestState(argsExterno: paseDeArgs);
}

class _VistaRequestState extends State<VistaRequest> {

  _VistaRequestState({required this.argsExterno});

  final String argsExterno;

  // OJO - esto es necesario para el request
  late Future<List<Carro>> carros;

  // si usas el future builder hay que hacer request en init
  // existen métodos del ciclo de vida

  @override
  void initState() {
    super.initState();
    carros = obtenerCarros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DETALLE CON REQUEST")),
      body: Center(
        child: FutureBuilder<List<Carro>> (
          future: carros,
          builder: (context, snapshot) {

            if(snapshot.hasData){

              // vamos a regresar el widget si se completo la promesa con éxito
              return Column(
                  children: [
                    Text(snapshot.data![0].marca),
                    Text(snapshot.data![0].modelo),
                    Text("${snapshot.data![0].anio}"),
                    Text(argsExterno),
                    Image.network("https://www.foodchallenges.com/wp-content/uploads/2018/08/beast-pizza2-184x184.jpeg")
                  ]
              );

            } else if (snapshot.hasError){

              // regresamos otro widget en caso de error
              return Text("${snapshot.error}");
            }

            // si no hay datos y no hay error significa que seguimos trabajando
            return CircularProgressIndicator();
          },
        )
      ),
    );

  }

}

// vamos a hacer la lógica para la solicitud asíncrona
// 2 partes -
// 1 - Parsing del JSON
// 2 - Request de HTTP

// https://bitbucket.org/itesmguillermorivas/partial2/raw/45f22905941b70964102fce8caf882b51e988d23/carros.json

class Carro {

  final String marca;
  final String modelo;
  final int anio;

  Carro({required this.marca, required this.modelo, required this.anio});

  factory Carro.fromJson(Map<String, dynamic> json){
    return Carro(
      marca: json['marca'],
      modelo: json['modelo'],
      anio: json['anio']
    );
  }
}

// yo puedo declarar una función que no pertenezca a una clase
// aquí vamos a declarar la función de request remoto
Future<List<Carro>> obtenerCarros() async {

  final response = await http.get(
    Uri.parse(
      "https://bitbucket.org/itesmguillermorivas/partial2/raw/45f22905941b70964102fce8caf882b51e988d23/carros.json"
    )
  );

  if(response.statusCode == 200){

    List<dynamic> list = jsonDecode(response.body);
    List<Carro> result = [];
    for (var actual in list){
      Carro carroActual = Carro.fromJson(actual);
      result.add(carroActual);
    }

    return result;
  } else {
    throw Exception("ERROR EN REQUEST");
  }

}