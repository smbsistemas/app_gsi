import 'package:flutter/material.dart';
// import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
// import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:rgti_gsi/prgs/planoAcao.dart';

final String idColumn = "idColumn";
final String imgColumn = "imgColumn";

class AnexarEvidencias extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  AnexarEvidencias({this.data, this.dataConfig});

  @override
  _AnexarEvidencias createState() =>
      new _AnexarEvidencias(data: data, dataConfig: dataConfig);
}

class _AnexarEvidencias extends State<AnexarEvidencias> {
  final Data data;
  final AppConfig dataConfig;

  // List<EvidTratativa> evidTratativa = [];

  _AnexarEvidencias({this.data, this.dataConfig});

  //print('idnaoconformidade: $data.idNaoConformidade');

  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  GlobalKey<FormState> _key = new GlobalKey();

  String _login = '';
  String _password = '';
  String _nome = '';
  String _idUser = '';
  String _host = '';
  String _porta = '';

  File _imageObservada;
  File _imageTratativa;

  bool _validate = false;
  DateTime _dataCorrente = new DateTime.now();

  String _idNaoConformidade;
  String _idCCU;
  String _idColigada;
  String _reCodigo;
  String _itemRelator = '';
  String _temPlanoAcao = '';

  initState() {
    super.initState();
    _idNaoConformidade = this.data.idNaoConformidade;
    _idColigada = this.data.idColigada;
    _idCCU = this.data.idCCU;
    _temPlanoAcao = this.data.temPlanoAcao;
    _appBarTitle = new Text('Anexar Evidências');
    _appBarBackgroundColor = Colors.red;
    _porta = this.dataConfig.auPorta;
    _host = this.dataConfig.auHost;
    _idUser = this.dataConfig.auIdUser;
  }

  @override
  Widget build(BuildContext context) {
    print('idNC: $_idNaoConformidade');
    return Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      body: new Container(
        margin: new EdgeInsets.all(15.0),
        child: new Form(
          key: _key,
          autovalidate: _validate,
          child: _formUI(),
        ),
      ),
    );
  }

  //@override
  var _evidTratativa = ['', '', '', '', '', '', '', '', '', '', ''];
  var _evidObservada = ['', '', '', '', '', '', '', '', '', '', ''];
  Widget _formUI() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
            child: Container(
                //  padding: EdgeInsets.only(left: 60.0, top: 20.0),
                padding: EdgeInsets.only(left: 120.0, top: 20.0),
                child: Text("Observada",
                    style: Theme.of(context).textTheme.title.merge(
                        TextStyle(fontSize: 18.0, color: Colors.blue))))),
        // Evidencia Observada
        SliverGrid.count(
          crossAxisCount: 3,
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[0] != ''
                        ? FileImage(File(_evidObservada[0]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[0] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[1] != ''
                        ? FileImage(File(_evidObservada[1]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[1] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[2] != ''
                        ? FileImage(File(_evidObservada[2]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[2] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[3] != ''
                        ? FileImage(File(_evidObservada[3]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[3] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[4] != ''
                        ? FileImage(File(_evidObservada[4]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[4] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[5] != ''
                        ? FileImage(File(_evidObservada[5]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidObservada[5] = file.path;
                  });
                });
              },
            ),
          ],
        ),
        // Evidencia da Tratativa
        SliverToBoxAdapter(
            child: Container(
                //  padding: EdgeInsets.only(left: 60.0, top: 20.0),
                padding: EdgeInsets.only(left: 120.0, top: 20.0),
                child: Text("Tratativa",
                    style: Theme.of(context).textTheme.title.merge(
                        TextStyle(fontSize: 18.0, color: Colors.blue))))),
        SliverGrid.count(
          crossAxisCount: 3,
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[0] != ''
                        ? FileImage(File(_evidTratativa[0]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[0] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[1] != ''
                        ? FileImage(File(_evidTratativa[1]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[1] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[2] != ''
                        ? FileImage(File(_evidTratativa[2]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[2] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[3] != ''
                        ? FileImage(File(_evidTratativa[3]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[3] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[4] != ''
                        ? FileImage(File(_evidTratativa[4]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[4] = file.path;
                  });
                });
              },
            ),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: _evidTratativa[5] != ''
                        ? FileImage(File(_evidTratativa[5]))
                        : AssetImage("images/logorgti.jpg"),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                  if (file == null) return;
                  setState(() {
                    _evidTratativa[5] = file.path;
                  });
                });
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
            child: Container(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: new RaisedButton(
              onPressed: _sendForm,
              child: new Text('Proximo'),
            ),
          ),
        ))
      ],
    );
  }

  void _sendForm() {
    if (_evidTratativa[0] != '') {
      String _fileName = 'fotoTrativa0';
      _uploadImage(_evidTratativa[0], _fileName);
    }

    if (_temPlanoAcao == 'S') {
      print('plano de ação = sim');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PlanoAcao(data: data, dataConfig: dataConfig)),
      );
      // Route route = MaterialPageRoute(builder: (context) => PlanoAcao(_ncCodigo));
      // Navigator.pushReplacement(context, route);
    } else {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  Future<Map<String, dynamic>> _uploadImage(
//      File image, String pImagePath, String pfile) async {
      String pImagePath,
      String pfile) async {
//    final mimeTypeData =
//        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final mimeTypeData =
        lookupMimeType(pImagePath, headerBytes: [0xFF, 0xD8]).split('/');

    Uri apiUrl = Uri.parse('http://$_host:$_porta/postEvidencia');
    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', apiUrl);

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath(
        'half_body_image', pImagePath,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.fields['name'] = pfile;
    imageUploadRequest.fields['extencao'] = 'jpeg';
    imageUploadRequest.fields['tipo'] = 'EVDOBJETIVA';
    imageUploadRequest.fields['idNaoConformidade'] = _idNaoConformidade;
    imageUploadRequest.fields['coligada'] = _idColigada;
    imageUploadRequest.fields['ccu'] = _idCCU;
    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('response - enviado');
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // upload(File imageFile) async {
  /*
  upload(String imagePath, String pfile) async {
    File imageFile;
    imageFile = File(imagePath);
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    String whost = '100.68.70.101';
    String wporta = '8080';
    //var uri = Uri.parse("http://$whost:$wporta/postEvidencia");
    var uri = Uri.parse("http://$_host:$_porta/postEvidencia");
    print('uri: $uri');
    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile(pfile, stream, length,
        // filename: basename(imageFile.path));
        filename: imageFile.path);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }
  */

}
