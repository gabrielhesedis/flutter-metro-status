import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ExemploRest());
}

class ExemploRest extends StatefulWidget {
  @override
  _ExemploRestState createState() => _ExemploRestState();
}

class _ExemploRestState extends State<ExemploRest> {
  Future<List<Linha>> linhasMetro;
  int loading = 0;

  @override
  void initState() {
    super.initState();
    linhasMetro = statusMetro();
  }

  Future<List<Linha>> statusMetro() async {
    setState(() {
      loading = 1;
    });

    // TROQUE O ENDEREÇO PELA CHAMADA DO ENDPOINT DA API
    final response = await http.get('https://localhost:3000/metro');

    if (response.statusCode == 200) {
      var linhasMetroJSON = jsonDecode(response.body)['status'] as List;
      List<Linha> linhasMetroResultado = linhasMetroJSON
          .map((linhaJSON) => Linha.fromJson(linhaJSON))
          .toList();

      setState(() {
        loading = 0;
      });

      return linhasMetroResultado;
    } else {
      throw Exception('Falha no carregamento do endpoint');
    }
  }

  void reloadStatusMetro() {
    setState(() {
      linhasMetro = statusMetro();
    });
  }

  Map<String, dynamic> obtemCor(valor) {
    var combinacaoCores = {"corFundo": Colors.grey, "corTexto": Colors.black};

    switch (valor) {
      case "Azul":
        combinacaoCores["corFundo"] = Colors.blue[900];
        combinacaoCores["corTexto"] = Colors.white;
        break;

      case "Verde":
        combinacaoCores["corFundo"] = Colors.green[900];
        combinacaoCores["corTexto"] = Colors.white;
        break;

      case "Vermelha":
        combinacaoCores["corFundo"] = Colors.red[900];
        combinacaoCores["corTexto"] = Colors.white;
        break;

      case "Prata":
        combinacaoCores["corFundo"] = Colors.grey[300];
        break;

      case "Amarela":
        combinacaoCores["corFundo"] = Colors.yellow;
        break;

      case "Lilás":
        combinacaoCores["corFundo"] = Colors.purple[300];
        combinacaoCores["corTexto"] = Colors.white;
        break;
    }

    return combinacaoCores;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Metro Direto ao Ponto"),
          backgroundColor: Colors.blueGrey[900],
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: reloadStatusMetro,
            )
          ],
        ),
        body: Container(
          child: loading == 0
              ? RefreshIndicator(
                  onRefresh: statusMetro,
                  child: FutureBuilder<List<Linha>>(
                    future: linhasMetro,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var linhas = snapshot.data;

                        return ListView.builder(
                          itemCount: linhas.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: obtemCor(linhas[index].cor)["corFundo"],
                              child: ListTile(
                                leading: Icon(
                                  Icons.train,
                                  size: 50,
                                ),
                                isThreeLine: true,
                                title: Text(
                                  "${linhas[index].nomeCompleto}",
                                  style: TextStyle(
                                      color: obtemCor(
                                          linhas[index].cor)["corTexto"],
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${linhas[index].status}",
                                  style: TextStyle(
                                      color: obtemCor(
                                          linhas[index].cor)["corTexto"]),
                                ),
                                trailing: Text(
                                  "${linhas[index].numero}",
                                  style: TextStyle(
                                    fontSize: 40,
                                    color:
                                        obtemCor(linhas[index].cor)["corTexto"],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Erro: ${snapshot.error}"));
                      }

                      return CircularProgressIndicator();
                    },
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  ),
                ),
        ),
      ),
    );
  }
}

class Linha {
  final String nomeCompleto;
  final String numero;
  final String cor;
  final String status;

  Linha({this.nomeCompleto, this.numero, this.cor, this.status});

  factory Linha.fromJson(dynamic linha) {
    return new Linha(
        nomeCompleto: linha['nome_completo'],
        numero: linha['numero'],
        cor: linha['cor'],
        status: linha['status']);
  }
}
