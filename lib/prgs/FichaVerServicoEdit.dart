import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';

import 'package:rgti_gsi/models/infra/fichaVerServicos.dart';
import 'package:rgti_gsi/prgs/NaoConforme.dart';
import 'package:rgti_gsi/prgs/inspServicosEdit.dart';

String _servicoInspecionado, _localVerificado;
String _respVerificacao, _naoConformidade;

String _fsCodigo = '';
String _desCCU = '';
String _codCCU = '';

var _listFichaServicos = new List<FichaVerServicos>();

class FichaVerServicoEdit extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  FichaVerServicoEdit({this.data, this.dataConfig});

  @override
  _FichaVerServicoEdit createState() =>
      new _FichaVerServicoEdit(data: data, dataConfig: dataConfig);
}

class _FichaVerServicoEdit extends State<FichaVerServicoEdit> {
  final Data data;
  final AppConfig dataConfig;

  _FichaVerServicoEdit({this.data, this.dataConfig});

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  // Acesso - informações conexão e usuario
  List _acessoUserList = [];

  String _login = '';
  String _password = '';
  String _nome = '';
  String _host = '';
  String _porta = '';
  String _codigo = '';
  String _codColigada = '';
  String _codCCusto = '';
  String _codServico = '';
  String _codModelo = '';

  String _coligada = '1';
  String _codRelator = '1';
  String _codExecutor = '8';
  String _selectedCentroCusto = '1.0001';
  String _selectedModeloFVS = '01-01-TESTE 01';

  String _itemMFVS;
  String _itemCCU;

  DateTime _dataInicio = new DateTime.now();
  DateTime _dataFim = new DateTime.now();

  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _login = _acessoUserList[0]['login'];
        _password = _acessoUserList[0]['senha'];
        _nome = _acessoUserList[0]['nome'];
        _codigo = _acessoUserList[0]['codigo'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];

        _codColigada = this.data.idColigada;
        _codCCusto = this.data.idCCU;
        _codServico = this.data.codFVS;
        _codModelo = this.data.codModelo;
        _servicoInspecionado = this.data.servicoInspecionado;
        _localVerificado = this.data.localServico;
        _respVerificacao = this.data.responsavelServico;
        _desCCU = this.data.nomeCCU;
        _codCCU = this.data.idCCU;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Editar - Ficha Serviços'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: _formUI(),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    String _SdataInicio = new DateFormat.yMMMd().format(_dataInicio);
    String _SdataFim = new DateFormat.yMMMd().format(_dataFim);

    return new Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Código:  ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _codServico,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Centro de Custo
        Row(
          children: <Widget>[
            Text(
              'Obra:  ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _desCCU,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),

        // Modelo FVS
        Row(
          children: <Widget>[
            Text(
              'Modelo de FVS:  ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _codModelo,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Serviço Inspecionado
        Row(
          children: <Widget>[
            Text(
              'Inspeção:  ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _servicoInspecionado,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Local a ser verificado
        Row(
          children: <Widget>[
            Text(
              'Local a ser verificado: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _localVerificado,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Responsavel pela verificação
        Row(
          children: <Widget>[
            Text(
              'Responsável:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _respVerificacao,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Data Inicio do serviço
        Row(
          children: <Widget>[
            Text(
              'Inicio Serviço :  $_SdataInicio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        // Data Fim do Serviço
        Row(
          children: <Widget>[
            Text(
              'Fim do Serviço :  $_SdataFim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
        new RaisedButton(
          onPressed: _inspecaoServicos,
          child: new Text('Proximo'),
        )
      ],
    );
  }

  String _validarTexto(String value) {
    String patttern = r'(^[a-zA-Z \-_Ããç!,.áÁÉéêÊ?0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o Texto";
    } else if (!regExp.hasMatch(value)) {
      return "O Texto deve conter apenas caracteres de a-z ou A-Z";
    }
    return null;
  }

  void _dropDownItemSelected(String tipo, String novoItem) {
    setState(() {
      if (tipo == 'CCU') {
        this._itemCCU = novoItem;
      } else if (tipo == 'FVS') {
        this._itemMFVS = novoItem;
      }
    });
  }

  void _inspecaoServicos() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              InspServicosEdit(data: data, dataConfig: dataConfig)),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/gsiacesso.json");
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "VERIFICAÇÃO DE SERVIÇOS",
      desc: "Código: $_fsCodigo",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => _retornoMenu(_naoConformidade.substring(0, 1)),
          width: 120,
        )
      ],
    ).show();
  }

  void _retornoMenu(String pnaoConforme) {
    if (pnaoConforme == 'S') {
      Navigator.pushReplacementNamed(context, "/");
    } else {
      Navigator.pop(context);
    }
  }
}

class FVNaoConforme extends StatefulWidget {
  @override
  _NaoConforme createState() {
    return _NaoConforme();
  }
}

class _NaoConforme extends State<FVNaoConforme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Não Conformidades')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: TextField(
              //controller: textFieldController,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
          new NaoConforme(),
        ],
      ),
    );
  }
}
