import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:http/http.dart' as http;

class InspServicosEdit extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  InspServicosEdit({this.data, this.dataConfig});

  @override
  _InspServicosEdit createState() =>
      new _InspServicosEdit(data: data, dataConfig: dataConfig);
}

enum SingingCharacter { conforme, naoConforme }

class _InspServicosEdit extends State<InspServicosEdit> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Data data;
  final AppConfig dataConfig;

  _InspServicosEdit({this.data, this.dataConfig});

  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  GlobalKey<FormState> _key = new GlobalKey();

  List<ModeloServicos> _listModeloServicosI = [];

  List _enabled = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _userId = '';
  String _host = '';
  String _porta = '';
  String _idColigada = '';
  String _tipoInspecao = '';

  String _codFVS = '';
  int _index = 0;

  initState() {
    super.initState();
    _idColigada = this.data.idColigada;
    _appBarTitle = new Text('INSPEÇÃO DE SERVIÇOS');
    _appBarBackgroundColor = Colors.red;
    _porta = this.dataConfig.auPorta;
    _host = this.dataConfig.auHost;
    _userId = this.dataConfig.auIdUser;
    _codFVS = this.data.codFVS;
  }

  bool wvar = true;
  List checked1 = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];

  List checked2 = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 10.0, 17.0, 3.0),
          ),
          Row(children: <Widget>[
            Container(
                width: 80.0,
                child: Text(
                  'Conforme',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            Container(
                width: 200.0,
                child: Text(
                  'Serviços',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            Container(
                width: 80.0,
                child: Text(
                  'Não Conforme',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
          ]),
          Container(
            child: Divider(),
            padding: EdgeInsets.fromLTRB(17.0, 10.0, 17.0, 3.0),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getModeloFVS(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 80.0,
                                child: Column(children: <Widget>[
                                  new Radio(
                                    value: SingingCharacter.conforme,
                                    groupValue: checked1[index],
                                    onChanged: (value) {
                                      setState(() {
                                        checked1[index] = value;
                                        checked2[index] = '';
                                      });
                                    },
                                  ),
                                ]),
                              ),
                              Container(
                                width: 200.0,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data[index].descricao,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        snapshot.data[index].tolerancia,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ]),
                              ),
                              Container(
                                width: 80.0,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new Radio(
                                        value: SingingCharacter.conforme,
                                        groupValue: checked2[index],
                                        onChanged: (value) {
                                          setState(() {
                                            checked2[index] = value;
                                            checked1[index] = '';
                                          });
                                        },
                                      )
                                    ]),
                              ),
                            ],
                          ),
                          Container(
                            child: Divider(),
                          ),
                        ]);
                      });
                }
              },
            ),
          ),
          new RaisedButton(
            onPressed: _sendForm,
            child: new Text('Enviar'),
          )
        ],
      ),
    );
  }

  void _sendForm() async {
    print('insert ficha de inspeção de serviços');
    String _codModelo = '';
    String _item = '';
    String _pInspecao = '';
    String _pAcao = '';
    String _pReinspecao = '';
    String _temNaoConformidade = 'N';

    int x = 0;
    int t = _listModeloServicosI.length;
    while (x < t) {
      _codModelo = _listModeloServicosI[x].codModelo;
      _item = _listModeloServicosI[x].item;
      _pInspecao = '';
      _pAcao = '';
      _pReinspecao = '';
      /*
      if (_enabled[x] == true) {
        _pInspecao = 'X'; // Item Conforme
      } else {
        _pAcao = 'O'; // Item não conforme
        _temNaoConformidade = 'S';
      } */
      if (checked1[x] != '') {
        _pInspecao = 'X'; // Item Conforme
      } else {
        if (checked2[x] != '') {
          _pAcao = 'O'; // Item não conforme
          _temNaoConformidade = 'S';
        }
      }
      var data = await http.get(
          'http://$_host:$_porta/PostInspecao/$_codFVS/$_idColigada/$_codModelo/$_item/$_pInspecao/$_pAcao/$_pReinspecao');
      var jsonData = json.decode(data.body)['ItensServicos'];
      x = x + 1;
    }

    if (_temNaoConformidade == 'S') {
      Navigator.pushReplacementNamed(context, "/");
    } else {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  Future<List<ModeloServicos>> _getModeloFVS() async {
    print('_codFVS:$_codFVS');
    var data = await http.get('http://$_host:$_porta/GetItemMFVSEdit/$_idColigada/$_codFVS/');
    var jsonData = json.decode(data.body)['ItensServicos'];

    List<ModeloServicos> _listModeloServicos = [];
    int x = 0;
    for (var u in jsonData) {
      ModeloServicos documento = ModeloServicos(x, u['CODMODELO'], u['ITEM'],
          u['DESCRICAO'], u['TOLERANCIA'], 'INSPECAO', 'ACAO', '');
      _listModeloServicos.add(documento);
      x = x + 1;
    }

    _listModeloServicosI = _listModeloServicos;

    return _listModeloServicos;
  }
}

class ModeloServicos {
  final int index;
  final String codModelo;
  final String item;
  final String descricao;
  final String tolerancia;
  final String inspecao;
  final String acao;
  final String reinspecao;

  ModeloServicos(this.index, this.codModelo, this.item, this.descricao,
      this.tolerancia, this.inspecao, this.acao, this.reinspecao);
}
