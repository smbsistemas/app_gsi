import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rgti_gsi/models/infra/setor.dart';
import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:rgti_gsi/models/infra/usuarios.dart';
import 'package:rgti_gsi/models/infra/centroDeCusto.dart';
import 'package:rgti_gsi/prgs/relator.dart';

class API {
  static Future getSetor(String phost, String pporta, String pUserId) async {
    var url = "http://$phost:$pporta/getSetor/$pUserId";
    var dataSetor = await http.get(url);
    return dataSetor;
  }

  static Future getUsers(String phost, String pporta) async {
    var url = "http://$phost:$pporta/getUsuarios";
    var dataUsers = await http.get(url);
    return dataUsers;
  }

  static Future getCCU(String phost, String pporta, String pUserId) async {
    var url = "http://$phost:$pporta/GetCentrodeCusto/$pUserId";
    var dataCCU = await http.get(url);
    return dataCCU;
  }
}

String _naoConformidade = '';
String _acaoImediata = '';
String _evidenciaObservada = '';
String _evidenciaTratativa = '';
String _primeiroPorque = '';
String _descricaoAbrangencia = '';

String _selectedTipoAcao = '';
String _selectedClassificacao = '';
String _selectedTipoRegistro = '';
String _selectedSetor = '';
String _selectedExtratificacao = '';
String _tipoIsolado = '';
String _afetaQualidade = '';
String _planoDeAcao = '';

String wccuCodigo;
String wccuDescricao;
String _ncCodigo;

class NaoConforme extends StatefulWidget {
  @override
  _NaoConforme createState() => new _NaoConforme();
}

class _NaoConforme extends State<NaoConforme> {
  // Acesso - informações conexão e usuario
  List _acessoUserList = [];
  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';

  var _usuarios = new List<Usuarios>();
  var _centroDeCusto = new List<CentroDeCusto>();
  var _setor = new List<Setor>();

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
        _getSetor();
        _getUsers();
        _getCCU();
      });
    });
  }

  final data = Data();
  final dataConfig = AppConfig();

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  String _coligada = '1';
  //String _codExecutor = '8';
  String _itemCCU = 'ADM CENTRAL';
  String _itemTipo = 'CORRETIVA';
  String _itemClassificacao = 'Leve';
  String _itemTipoRegistro = 'INSPEÇÃO SS';
  String _itemSetor = 'SESMT';
  String _itemExtratificacao = 'ATO INSEGURO';
  String _itemExecutor = '';

  bool _unico = true;

  DateTime _dataCorrente = new DateTime.now();

  List<TipoAcao> _tipoAcao = [];
  List<Classificacao> _classificacao = [];
  List<TipoRegistro> _tipoRegistro = [];
  List<Extratificacao> _extratificacao = [];

  final String dataTipoAcao =
      '{"TipoAcao":[{"CODIGO":"C","DESCRICAO":"CORRETIVA"},{"CODIGO":"M","DESCRICAO":"MELHORIA"}]}';

  final String dataClassificacao =
      '{"Classificacao":[{"CODCLASSIF":"1","DESCRICAO":"Leve"},{"CODCLASSIF":"2","DESCRICAO":"Moderada"},{"CODCLASSIF":"3","DESCRICAO":"Grave"}]}';

  final String dataTipoRegistro =
      '{"TipoRegistro":[{"CODIGO":"1","DESCRICAO":"INSPEÇÃO SS"}]}';

  final String dataExtratificacao =
      '{"Extratificacao":[{"CODCOLIGADA":"1","CODSETOR":"1","CODEXTRATIF":"1","DESCRICAO":"ATO INSEGURO"}]}';

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
    if (_usuarios.length > 0 && _unico) {
      _itemExecutor = _usuarios[0].nome;
    }
    if (_centroDeCusto.length > 0 && _unico) {
      _itemCCU = _centroDeCusto[0].ccuNome;
    }
    if (_setor.length > 0 && _unico) {
      _itemSetor = _setor[0].setorDescricao;
      _unico = false;
    }
    final jsonTA = JsonDecoder().convert(dataTipoAcao);
    _tipoAcao = (jsonTA['TipoAcao'])
        .map<TipoAcao>((item) => TipoAcao.fromJson(item))
        .toList();
    _selectedTipoAcao = _tipoAcao[0].tipoAcaoDescricao;

    final jsonCL = JsonDecoder().convert(dataClassificacao);
    _classificacao = (jsonCL['Classificacao'])
        .map<Classificacao>((item) => Classificacao.fromJson(item))
        .toList();
    _selectedClassificacao = _classificacao[0].classificacaoDescricao;

    final jsonTR = JsonDecoder().convert(dataTipoRegistro);
    _tipoRegistro = (jsonTR['TipoRegistro'])
        .map<TipoRegistro>((item) => TipoRegistro.fromJson(item))
        .toList();
    _selectedTipoRegistro = _tipoRegistro[0].tipoRegistroDescricao;

    final jsonEX = JsonDecoder().convert(dataExtratificacao);
    _extratificacao = (jsonEX['Extratificacao'])
        .map<Extratificacao>((item) => Extratificacao.fromJson(item))
        .toList();
    _selectedExtratificacao = _extratificacao[0].extratificacaoDescricao;

    String _dataNConforme = new DateFormat.yMMMd().format(_dataCorrente);

    return new Column(
      children: <Widget>[
        // Centro de Custo
        Row(
          children: <Widget>[
            Text(
              'Centro de Custo:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione a CCU"),
                isDense: true,
                items: _centroDeCusto.map((CentroDeCusto map) {
                  return new DropdownMenuItem<String>(
                    value: map.ccuNome,
                    child: new Text(map.ccuNome,
                        style: new TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        )),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('CCU', newValue);
                    _itemCCU = newValue;
                    print('itemCCU: $_itemCCU');
                  });
                },
                value: _itemCCU,
              ),
            ),
          ],
        ),
        // Tipo da Ação
        Row(
          children: <Widget>[
            Text(
              'Tipo da Ação:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione a Ação"),
                isDense: true,
                items: _tipoAcao.map((TipoAcao map) {
                  return new DropdownMenuItem<String>(
                    value: map.tipoAcaoDescricao,
                    child: new Text(map.tipoAcaoDescricao,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('TNC', newValue);
                    this._itemTipo = newValue;
                  });
                },
                value: _itemTipo,
              ),
            ),
          ],
        ),
        // Classificação
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Classificação: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione a Classificação "),
                isDense: true,
                items: _classificacao.map((Classificacao map) {
                  return new DropdownMenuItem<String>(
                    value: map.classificacaoDescricao,
                    child: new Text(map.classificacaoDescricao,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('CLA', newValue);
                    this._itemClassificacao = newValue;
                  });
                },
                value: _itemClassificacao,
              ),
            ),
          ],
        ),
        // Tipo de Registro
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Tipo de Registro:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione Registro"),
                isDense: true,
                items: _tipoRegistro.map((TipoRegistro map) {
                  return new DropdownMenuItem<String>(
                    value: map.tipoRegistroDescricao,
                    child: new Text(map.tipoRegistroDescricao,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('TRE', newValue);
                    this._itemTipoRegistro = newValue;
                  });
                },
                value: _itemTipoRegistro,
              ),
            ),
          ],
        ),
        // Setor
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Setor:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione Setor"),
                isDense: true,
                items: _setor.map((Setor map) {
                  return new DropdownMenuItem<String>(
                    value: map.setorDescricao,
                    child: new Text(map.setorDescricao,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('SET', newValue);
                    this._itemSetor = newValue;
                  });
                },
                value: _itemSetor,
              ),
            ),
          ],
        ),
        // Extratificação
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Extratificação:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Selecione Extratificação"),
                isDense: true,
                items: _extratificacao.map((Extratificacao map) {
                  return new DropdownMenuItem<String>(
                    value: map.extratificacaoDescricao,
                    child: new Text(map.extratificacaoDescricao,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('EXT', newValue);
                    this._itemExtratificacao = newValue;
                  });
                },
                value: _itemExtratificacao,
              ),
            ),
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

        // Data da Nao Conformidade
        Row(
          children: <Widget>[
            Text(
              'Data Não Conformidade :  $_dataNConforme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                final _seldate = await showDatePicker(
                    context: context,
                    initialDate: _dataCorrente,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                    builder: (context, child) {
                      return SingleChildScrollView(
                        child: child,
                      );
                    });
                if (_seldate != null) {
                  setState(() {
                    _dataCorrente = _seldate;
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
        // Texto não conformidade
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Não Conformidade Real ou Potencial:',
              hintText: 'Não Conformidade Real ou Potencial:'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              //   _atribuiValor(1, val);
              //   this._naoConformidade = val;
              _naoConformidade = val;
            });
          },
        ),
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Ação imediata Tomada:',
              hintText: 'Ação imediata Tomada:'),
          maxLength: 100,
          //    validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              //  _atribuiValor(2, val);
              //  this._acaoImediata = val;
              _acaoImediata = val;
            });
          },
        ),
        // Row(children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Evidência Observada:',
              hintText: 'Evidência Observada:'),
          maxLength: 100,
          //      validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              //  this._evidenciaObservada = val;
              //  _atribuiValor(3, val);
              _evidenciaObservada = val;
            });
          },
        ),
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Evidência da Tratativa:',
              hintText: 'Evidência da Tratativa:'),
          maxLength: 100,
          //   validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              _evidenciaTratativa = val;
            });
          },
        ),

        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Análise da Causa:', hintText: 'Análise da Causa:'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              //  this._primeiroPorque = val;
              //  _atribuiValor(5, val);
              _primeiroPorque = val;
            });
          },
        ),
        // RadioButton - Fato Isolado
        Row(
          children: <Widget>[
            Text(
              'Fato Isolado?  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioButtonGroup(
              orientation: GroupedButtonsOrientation.HORIZONTAL,
              margin: const EdgeInsets.only(left: 12.0),
              onSelected: (String selected) => setState(() {
                _tipoIsolado = selected;
              }),
              labels: <String>[
                "Sim",
                "Não",
              ],
              picked: _tipoIsolado,
              itemBuilder: (Radio rb, Text txt, int i) {
                return Column(
                  children: <Widget>[
                    rb,
                    txt,
                  ],
                );
              },
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Afeta a Qualidade do produto / Serviço
        RichText(
            text: TextSpan(children: <TextSpan>[
          TextSpan(
            text: "Afeta a qualidade do produto / serviço?",
            style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.bold),
          )
        ])),
        RadioButtonGroup(
          orientation: GroupedButtonsOrientation.HORIZONTAL,
          margin: const EdgeInsets.only(left: 12.0),
          onSelected: (String selected) => setState(() {
            _afetaQualidade = selected;
          }),
          labels: <String>[
            "Sim",
            "Não",
          ],
          picked: _afetaQualidade,
          itemBuilder: (Radio rb, Text txt, int i) {
            return Column(
              children: <Widget>[
                rb,
                txt,
              ],
            );
          },
        ),
        // Descrição da Abrangência
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Descrição Abrangência:',
              hintText: 'Descrição Abrangência:'),
          maxLength: 100,
          //   validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              _descricaoAbrangencia = val;
              //_atribuiValor(6, val);
            });
          },
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
        RichText(
            text: TextSpan(children: <TextSpan>[
          TextSpan(
            text: "Necessário plano de ação?",
            style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.bold),
          )
        ])),
        RadioButtonGroup(
          orientation: GroupedButtonsOrientation.HORIZONTAL,
          margin: const EdgeInsets.only(left: 12.0),
          onSelected: (String selected) => setState(() {
            _planoDeAcao = selected;
          }),
          labels: <String>[
            "Sim",
            "Não",
          ],
          picked: _planoDeAcao,
          itemBuilder: (Radio rb, Text txt, int i) {
            return Column(
              children: <Widget>[
                rb,
                txt,
              ],
            );
          },
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Executor
        Row(
          children: <Widget>[
            Text(
              'Executor:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                hint: new Text("Executor"),
                isDense: true,
                items: _usuarios.map((Usuarios map) {
                  return new DropdownMenuItem<String>(
                    value: map.nome,
                    child: new Text(map.nome,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _dropDownItemSelected('USU', newValue);
                    this._itemExecutor = newValue;
                  });
                },
                value: _itemExecutor,
              ),
            ),
          ],
        ),
        new RaisedButton(
          onPressed:
//            _sendForm(_naoConformidade, _acaoImediata, _evidenciaObservada,
//                _evidenciaTratativa, _primeiroPorque, _descricaoAbrangencia)
              _sendForm,
          child: new Text('Enviar'),
        )
      ],
    );
  }

  String _validarTexto(String value) {
    //String patttern = r'(^[a-zA-Z \-_Ããç!,.áÁÉéêÊ?0-9]*$êéíÍãÃ)';
    String patttern = r'(^[a-zA-Z \-_Ããç!,.áÁÉéêÊíÍ?0-9]*$)';
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
        _itemCCU = novoItem;
      } else if (tipo == 'TNC') {
        this._itemTipo = novoItem;
      } else if (tipo == 'CLA') {
        this._itemClassificacao = novoItem;
      } else if (tipo == 'TRE') {
        this._itemTipoRegistro = novoItem;
      } else if (tipo == 'SET') {
        this._itemSetor = novoItem;
      } else if (tipo == 'EXT') {
        this._itemExtratificacao = novoItem;
      } else if (tipo == 'USU') {
        this._itemExecutor = novoItem;
      }
    });
  }

/*  void _atribuiValor(int pCampo, String pValor) {
    setState(() {
      if (pCampo == 1) {
        this._naoConformidade = pValor;
      } else if (pCampo == 2) {
        this._acaoImediata = pValor;
      } else if (pCampo == 3) {
        this._evidenciaObservada = pValor;
      } else if (pCampo == 4) {
        this._evidenciaTratativa = pValor;
      } else if (pCampo == 5) {
        this._primeiroPorque = pValor;
      } else if (pCampo == 6) {
        this._descricaoAbrangencia = pValor;
      }
    });
  }
*/
//  void _sendForm(String pnaoConformidade) {
/*   _sendForm(
      String pnaoConformidade,
      String pacaoImediata,
      String pevidenciaObservada,
      String pevidenciaTratativa,
      String pprimeiroPorque,
      String pdescricaoAbrangencia) { */
  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _insertNaoConforme(_naoConformidade, _acaoImediata, _evidenciaObservada,
          _evidenciaTratativa, _primeiroPorque, _descricaoAbrangencia);
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  void _insertNaoConforme(
      String pnaoConformidade,
      String pacaoImediata,
      String pevidenciaObservada,
      String pevidenciaTratativa,
      String pprimeiroPorque,
      String pdescricaoAbrangencia) async {
    String wtipoIsolado = 'N';
    if (_tipoIsolado != null) {
      wtipoIsolado = _tipoIsolado.substring(0, 1);
    }
    String wAfetaQualidade = 'N';
    if (_afetaQualidade != null) {
      wAfetaQualidade = _afetaQualidade.substring(0, 1);
    }
    String wPlanoAcao = 'N';
    if (_planoDeAcao != null) {
      wPlanoAcao = _planoDeAcao.substring(0, 1);
    }
    String wTipoAcao = _selectedTipoAcao.substring(0, 1);

    final DateFormat wData = DateFormat('ddMMyyyy');
    final String wDataAcao = wData.format(_dataCorrente);
    String wnaoConformidade = _naoConformidade;
    print('Cheguei ! - Save');
    print('_itemCCU: $_itemCCU');
    print('naoConformidade : $wnaoConformidade');
    print('_acaoImediata: $_acaoImediata');
    print('_evidenciaObservada: $_evidenciaObservada');
    print('_evidenciaTratativa: $_evidenciaTratativa');
    print('_primeiroPorque: $_primeiroPorque');
    print('_descricaoAbrangencia: $_descricaoAbrangencia');
    if ((_naoConformidade != null) && (_itemCCU != null)) {
      var dataNaoConf = await http.get(
          'http://$_host:$_porta/PostNaoConfomidade/$_coligada/$_itemCCU/$_itemTipo/$_itemClassificacao/$_itemExtratificacao/$wDataAcao/$pnaoConformidade/$pacaoImediata/$pevidenciaObservada/$pevidenciaTratativa/$_codigo/$_itemExecutor/$pprimeiroPorque/$_itemSetor/$_itemTipoRegistro/$wtipoIsolado/$wAfetaQualidade/$pdescricaoAbrangencia/$wPlanoAcao');
      var jsonData = json.decode(dataNaoConf.body)['NaoConformidade'];
      List<NaoConfomidade> _listNaoConf = [];
      int x = 0;
      for (var u in jsonData) {
        NaoConfomidade documento =
            NaoConfomidade(x, u['CODIGO'], u['MENSAGEM']);
        _listNaoConf.add(documento);
        x = x + 1;
      }
      _ncCodigo = _listNaoConf[0].ncCodigo;
      print('_ncCodigo: _ncCodigo');

      data.idNaoConformidade = _ncCodigo;
      data.idColigada = _coligada;
      data.idCCU = _itemCCU;
      data.temPlanoAcao = wPlanoAcao;
      data.desNaoConfomidade = _naoConformidade;
      data.tipoAcao = _itemTipo;

      dataConfig.auIdUser = _codigo;
      dataConfig.auHost = _host;
      dataConfig.auLogin = _login;
      dataConfig.auPorta = _porta;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Relator(data: data, dataConfig: dataConfig)),
      );
      print('fim - relator');
      /*   if (wPlanoAcao == 'S') {
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
      } */
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

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "NÃO CONFORMIDADE",
      desc: "Código: $_ncCodigo",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  _getUsers() async {
    API.getUsers(_host, _porta).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['Usuarios'];
        _usuarios = list.map((model) => Usuarios.fromJson(model)).toList();
      });
    });
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

  _getSetor() async {
    API.getSetor(_host, _porta, _codigo).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['Setor'];
        _setor = list.map((model) => Setor.fromJson(model)).toList();
      });
    });
  }
}

class NaoConfomidade {
  final int index;
  final String ncCodigo;
  final String ncMensagem;
  NaoConfomidade(this.index, this.ncCodigo, this.ncMensagem);
}

class TipoAcao {
  final String tipoAcaoCodigo;
  final String tipoAcaoDescricao;

  TipoAcao({this.tipoAcaoCodigo, this.tipoAcaoDescricao});
  factory TipoAcao.fromJson(Map<String, dynamic> json) {
    return new TipoAcao(
        tipoAcaoCodigo: json['CODIGO'], tipoAcaoDescricao: json['DESCRICAO']);
  }
}

class Classificacao {
  final String classificacaoCodigo;
  final String classificacaoDescricao;

  Classificacao({this.classificacaoCodigo, this.classificacaoDescricao});
  factory Classificacao.fromJson(Map<String, dynamic> json) {
    return new Classificacao(
        classificacaoCodigo: json['CODCLASSIF'],
        classificacaoDescricao: json['DESCRICAO']);
  }
}

class TipoRegistro {
  final String tipoRegistroCodigo;
  final String tipoRegistroDescricao;

  TipoRegistro({this.tipoRegistroCodigo, this.tipoRegistroDescricao});
  factory TipoRegistro.fromJson(Map<String, dynamic> json) {
    return new TipoRegistro(
        tipoRegistroCodigo: json['CODIGO'],
        tipoRegistroDescricao: json['DESCRICAO']);
  }
}

class Extratificacao {
  final String extratificacaoCodigo;
  final String extratificacaoDescricao;

  Extratificacao({this.extratificacaoCodigo, this.extratificacaoDescricao});
  factory Extratificacao.fromJson(Map<String, dynamic> json) {
    return new Extratificacao(
        extratificacaoCodigo: json['CODEXTRATIF'],
        extratificacaoDescricao: json['DESCRICAO']);
  }
}
