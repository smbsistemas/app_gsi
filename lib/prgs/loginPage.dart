import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  //final dataConfig = AppConfig();

  String _porta = '';
  String _host = '';

  String _password;
  String _pwdCript;
  String _user;
  String _nome;
  String _codigo;
  String _mensagem;

  List _acessoUserList = [];

  @override
  void initState() {
    super.initState();
    _porta = '8080';
    _host = 'srvrgti.ddns.net';
//    _host = '100.68.70.101';
    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        final String _login = _acessoUserList[1]['login'];
        print('login: $_login');
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    'Gerenciamento Integrado',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                      onSaved: (value) => _user = value,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: "Login")),
                  TextFormField(
                      onSaved: (value) => _password = value,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Senha")),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      child: Text("Enviar"),
                      onPressed: () async {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();

                        // Validate will return true if is valid, or false if invalid.
                        if (form.validate()) {
                          var result = await _validaAcesso();
                          if (result != null) {
                            Navigator.pushReplacementNamed(context, "/");
                          } else {
                            return _buildShowErrorDialog(
                                context, "Acesso negado!");
                          }
                        }
                      })
                ]))));
  }

  _validaAcesso() async {
    print('usuario:$_user');
    print('senha:$_password');

    var dataValidaAcesso =
        await http.get('http://$_host:$_porta/GetValidaUser/$_user/$_password');
    var jsonData = json.decode(dataValidaAcesso.body)['CTRLAcesso'];

    List<Login> _loginPage = [];
    int x = 0;

    for (var u in jsonData) {
      Login documento =
          Login(x, u['CODIGO'], u['NOME'], u['PW'], u['MENSAGEM']);
      _loginPage.add(documento);
      x = x + 1;
    }
    _codigo = _loginPage[0].lpCodigo;
    _nome = _loginPage[0].lpNome;
    _pwdCript = _loginPage[0].lpSenha;
    _mensagem = _loginPage[0].lpMensagem;
    print('_mensagem: $_mensagem');
    // print('senha criptografada: $_pwdCript');
    // String _pwdDecode;
    //   Uint8List base64Decode(_pwdDecode) => base64.decode(_pwdCript);
    /*  try {
      final cryptor = new PlatformStringCryptor();
      String key = "Q3JpcHRvZ3JhZmlhcyBjb20gUmluamRhZWwgLyBBRVM=";
      final String _pwdDecode = await cryptor.decrypt(_pwdCript, key);
      print('senha: $_pwdDecode');
    } on MacMismatchException {}
    // String _pwdDecode = utf8.decode(base64.decode(_pwdCript));
  */
    if (_mensagem == 'LIBERADO') {
      _addUser();
      return ('LIBERADO');
    }
  }

  Future _buildShowErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Mensagem de erro:'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      title: "Acesso",
      desc: "$_nome",
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

  void _addUser() {
    setState(() {
      Map<String, dynamic> newUser = Map();
      newUser["login"] = _user;
      newUser["senha"] = _password;
      newUser["nome"] = _nome;
      newUser["codigo"] = _codigo;
      newUser["host"] = _host;
      newUser["porta"] = _porta;
      _acessoUserList.add(newUser);
      _saveData();
    });
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/gsiacesso.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_acessoUserList);
    final file = await _getFile();
    return file.writeAsString(data);
  }
}

class Login {
  final int index;
  final String lpCodigo;
  final String lpNome;
  final String lpSenha;
  final String lpMensagem;
  Login(this.index, this.lpCodigo, this.lpNome, this.lpSenha, this.lpMensagem);
}
