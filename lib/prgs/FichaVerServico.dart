import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';

import 'package:rgti_gsi/prgs/InspServicos.dart';
import 'package:rgti_gsi/prgs/NaoConforme.dart';
import 'package:rgti_gsi/models/infra/centroDeCusto.dart';
import 'package:rgti_gsi/models/infra/modeloFVS.dart';

class API {
  static Future getCCU(String phost, String pporta, String pUserId) async {
    var url = "http://$phost:$pporta/GetCentrodeCusto/$pUserId";
    var dataCCU = await http.get(url);
    return dataCCU;
  }

  static Future getMFVS(String phost, String pporta) async {
    var url =
        "http://$phost:$pporta/INNER JOIN [dbo].[VMODELOFVS] VMO ON VMO.CODIGO = FVS.CODMODELO";
    var dataMFVS = await http.get(url);
    return dataMFVS;
  }
}

String _numeroContrato, _conformeIT, _servicoInspecionado, _localVerificado;
String _respVerificacao, _naoConformidade;

class FichaVerServico extends StatefulWidget {
  @override
  _FichaVerServico createState() => new _FichaVerServico();
}

class _FichaVerServico extends State<FichaVerServico> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  // Acesso - informações conexão e usuario
  List _acessoUserList = [];
  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';

  var _centroDeCusto = new List<CentroDeCusto>();
  var _modeloFVS = new List<ModeloFVS>();

  String _coligada = '1';
  String _codRelator = '1';
  String _codExecutor = '8';
  String _selectedCentroCusto = '1.0001';
  String _selectedModeloFVS = '01-01-TESTE 01';

  String _fsCodigo;

  String _itemCCU;
  String _itemMFVS;

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

        _getCCU();
        _getMFVS();

        if (_centroDeCusto.length > 0) {
          _itemCCU = _centroDeCusto[0].ccuNome;
        }
        if (_modeloFVS.length > 0) {
          _itemMFVS = _modeloFVS[0].mFVSDescricao;
        }
      });
    });
  }

  final data = Data();
  final dataConfig = AppConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // Centro de Custo
        Row(
          children: <Widget>[
            Text(
              'Obra:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione Obra"),
                isDense: true,
                items: _centroDeCusto.map((CentroDeCusto map) {
                  return new DropdownMenuItem<String>(
                    value: map.ccuNome,
                    child: new Text(map.ccuNome,
                        style:
                            new TextStyle(fontSize: 11, color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('CCU', newValue);
                    this._itemCCU = newValue;
                  });
                },
                value: _itemCCU,
              ),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Modelo FVS
        Row(
          children: <Widget>[
            Text(
              'Modelo de FVS:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione Modelo FVS"),
                isDense: true,
                items: _modeloFVS.map((ModeloFVS map) {
                  return new DropdownMenuItem<String>(
                    value: map.mFVSDescricao,
                    child: new Text(map.mFVSDescricao,
                        style:
                            new TextStyle(fontSize: 11, color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('FVS', newValue);
                    //            this._itemFVS = newValue;
                  });
                },
                value: _itemMFVS,
              ),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Serviço Inspecionado
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Inspeção:', hintText: 'Inspeção:'),
          maxLength: 30,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              _servicoInspecionado = val;
            });
          },
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Local a ser verificado
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Local a ser verificado:',
              hintText: 'Local a ser verificado:'),
          maxLength: 30,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              _localVerificado = val;
            });
          },
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Data Inicio do serviço
        Row(
          children: <Widget>[
            Text(
              'Inicio Serviço :  $_SdataInicio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                final _seldate = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                    builder: (context, child) {
                      return SingleChildScrollView(
                        child: child,
                      );
                    });
                if (_seldate != null) {
                  setState(() {
                    _dataInicio = _seldate;
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
            )
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Data Fim do Serviço
        Row(
          children: <Widget>[
            Text(
              'Fim do Serviço :  $_SdataFim',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                final _seldate = await showDatePicker(
                    context: context,
                    initialDate: _dataFim,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                    builder: (context, child) {
                      return SingleChildScrollView(
                        child: child,
                      );
                    });
                if (_seldate != null) {
                  setState(() {
                    _dataFim = _seldate;
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
            )
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Responsavel pela verificação
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Responsável pela verificação:',
              hintText: 'Responsável pela verificação:'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              _respVerificacao = val;
            });
          },
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
/*        RichText(
            text: TextSpan(children: <TextSpan>[
          TextSpan(
            text:
                "Em case NÃO CONFORMIDADE, será necessario abrir uma ação corretiva?",
            style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.bold),
          )
        ])),
        RadioButtonGroup(
          orientation: GroupedButtonsOrientation.HORIZONTAL,
          margin: const EdgeInsets.only(left: 12.0),
          onSelected: (String selected) => setState(() {
            _naoConformidade = selected;
          }),
          labels: <String>[
            "Sim",
            "Não",
          ],
          picked: _naoConformidade,
          itemBuilder: (Radio rb, Text txt, int i) {
            return Column(
              children: <Widget>[
                rb,
                txt,
              ],
            );
          },
        ),

        */
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Enviar'),
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

  void _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _insertFVS();
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  void _insertFVS() async {
    final DateFormat wData = DateFormat('ddMMyyyy');
    final String wDataInicio = wData.format(_dataInicio);
    final String wDataFim = wData.format(_dataFim);

    print('Cheguei ! - Save');
    print('_itemFVS: $_itemMFVS');
    print('_itemCCU: $_itemCCU');

    if ((_itemMFVS != null) || (_itemCCU != null)) {
      var dataFichaServicos = await http.get(
          'http://$_host:$_porta/PFichaServ/$_coligada/$_itemCCU/$_itemMFVS/$_servicoInspecionado/$_localVerificado/$wDataInicio/$wDataFim/$_respVerificacao');
      var jsonData = json.decode(dataFichaServicos.body)['FichaServicos'];

      List<FichaServicos> _listFichaServicos = [];
      int x = 0;

      for (var u in jsonData) {
        FichaServicos documento = FichaServicos(x, u['CODIGO'], u['MENSAGEM']);
        _listFichaServicos.add(documento);
        x = x + 1;
      }
      _fsCodigo = _listFichaServicos[0].fsCodigo;
      print('_fsCodigo: $_fsCodigo');

      //_showAlertDialog(context);

      print(_listFichaServicos[0].fsCodigo);
      data.idColigada = _coligada;
      data.idCCU = _itemCCU;
      data.codFVS = _fsCodigo;

      dataConfig.auIdUser = _codigo;
      dataConfig.auHost = _host;
      dataConfig.auLogin = _login;
      dataConfig.auPorta = _porta;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                InspServicos(data: data, dataConfig: dataConfig)),
      );
      // _showAlertDialog(context);
    } else {
      print("erro: valores null - send novamente");
    }
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

  _getCCU() async {
    API.getCCU(_host, _porta, _codigo).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['CentrodeCusto'];
        _centroDeCusto =
            list.map((model) => CentroDeCusto.fromJson(model)).toList();
      });
    });
  }

  _getMFVS() async {
    API.getMFVS(_host, _porta).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['ListaModeloFVS'];
        _modeloFVS = list.map((model) => ModeloFVS.fromJson(model)).toList();
      });
    });
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
//      Navigator.pushReplacementNamed(context, "/FichaVerServico");
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

class FichaServicos {
  final int index;
  final String fsCodigo;
  final String fsMensagem;

  FichaServicos(this.index, this.fsCodigo, this.fsMensagem);
}
