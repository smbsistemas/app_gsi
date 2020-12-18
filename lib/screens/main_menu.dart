import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:rgti_gsi/models/infra/menu_item.dart';
import 'package:rgti_gsi/prgs/FichaVerServico.dart';
import 'package:rgti_gsi/prgs/Sobre.dart';
import 'package:rgti_gsi/prgs/NaoConforme.dart';
import 'package:rgti_gsi/prgs/DocEletronico.dart';
import 'package:rgti_gsi/prgs/ListaNConforme.dart';
import 'package:rgti_gsi/prgs/ListFichaInspServicos.dart';
import 'package:rgti_gsi/prgs/loginPage.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() {
    return MainMenuState();
  }
}

class MainMenuState extends State<MainMenu> {
  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  MenuItem _selectedMenuItem;
  List<MenuItem> _menuItems;
  List<Widget> _menuOptionWidgets = [];
  List _acessoUserList = [];
  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';

  @override
  initState() {
    super.initState();

    _menuItems = createMenuItems();
    _selectedMenuItem = _menuItems.first;
    _appBarTitle = new Text(_menuItems.first.title);
    _appBarBackgroundColor = _menuItems.first.color;

    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _login = _acessoUserList[0]['login'];
        _password = _acessoUserList[0]['senha'];
        _nome = _acessoUserList[0]['nome'];
        _codigo = _acessoUserList[0]['codigo'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];

        print('_login: $_login');
        print('_password: $_password');
        print('_nome: $_nome');
        print('_codigo: $_codigo ');
        print('_host: $_host');
        print('_porta: $_porta');
      });
    });
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

  _getMenuItemWidget(MenuItem menuItem) {
    return menuItem.func();
  }

  _onSelectItem(MenuItem menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
      _appBarTitle = new Text(menuItem.title);
      _appBarBackgroundColor = menuItem.color;
    });
    Navigator.of(context).pop(); // close side menu
  }

  @override
  Widget build(BuildContext context) {
    _menuOptionWidgets = [];
    for (var menuItem in _menuItems) {
      _menuOptionWidgets.add(new Container(
          decoration: new BoxDecoration(
              color: menuItem == _selectedMenuItem
                  ? Colors.grey[200]
                  : Colors.white),
          child: new ListTile(
              leading: new Image.asset(menuItem.icon),
              onTap: () => _onSelectItem(menuItem),
              title: Text(
                menuItem.title,
                style: new TextStyle(
                    fontSize: 20.0,
//                    color: menuItem.color,
                    color: Colors.black,
                    fontWeight: menuItem == _selectedMenuItem
                        ? FontWeight.bold
                        : FontWeight.w300),
              ))));

      _menuOptionWidgets.add(
        new SizedBox(
          child: new Center(
            child: new Container(
              margin: new EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
              height: 0.3,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            new Container(
              width: 300,
              height: 300,
              child: CircleAvatar(
                backgroundImage: new AssetImage('images/logorgti.jpg'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            new Container(
                child: new ListTile(
                    //  leading: new Image.asset('assets/images/lion.png'),
                    title: Text(
                  "Gerenciamento Integrado",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                )),
                margin: new EdgeInsetsDirectional.only(top: 17.0),
                color: Colors.white,
                constraints: BoxConstraints(maxHeight: 90.0, minHeight: 90.0)),
            new SizedBox(
              child: new Center(
                child: new Container(
                  margin: new EdgeInsetsDirectional.only(start: 7.0, end: 7.0),
                  height: 0.6,
                  color: Colors.black,
                ),
              ),
            ),
            new Container(
              color: Colors.white,
              child: new Column(children: _menuOptionWidgets),
            ),
          ],
        ),
      ),
      body: _getMenuItemWidget(_selectedMenuItem),
    );
  }

  List<MenuItem> createMenuItems() {
    final menuItems = [
      new MenuItem(
          "Não Conformidades", '', Colors.red, () => new NaoConforme()),
      new MenuItem("Lista - Não Conformidades", '', Colors.red,
          () => new ListaNConforme()),
      new MenuItem("Verificação de Serviços", '', Colors.red,
          () => new FichaVerServico()),
      new MenuItem("Lista - Serviços", '', Colors.red,
          () => new ListFichaInspServicos()),
      new MenuItem(
          "Documentação Eletrônica", '', Colors.red, () => new DocEletronico()),
      new MenuItem("Login", '', Colors.red, () => new LoginPage()),
      new MenuItem("Sobre", '', Colors.red, () => new Sobre()),
    ];
    return menuItems;
  }
}
