import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Model/obra_model.dart';
import '../conection/database_helper.dart';
import '../Views/CardsEstatisticas.dart';
import '../Views/CardObra.dart';
import '../Views/Forms.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScrenState();
}

class _HomeScrenState extends State<HomeScreen> {
  int titulos = 0;
  int totais = 0;
  int tenho = 0;
  int lidos = 0;

  @override
  void initState() {
    super.initState();
    _atualizarEstatisticas();
  }

  Future<void> _atualizarEstatisticas() async {
    final states = await DataBaseHelper.instance.getResumoEstatisticas();
    setState(() {
      titulos = states['titulos']!;
      totais = states['totais']!;
      tenho = states['tenho']!;
      lidos = states['lidos']!;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Kiwi",
          style: GoogleFonts.merriweather(
            //conferir fonte
            color: Colors.green,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CartaoEstatistica(
                        titulo: "Titulos",
                        valor: "$titulos",
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CartaoEstatistica(
                        titulo: "Lidos/A ler",
                        valor: "$lidos/$totais",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CartaoEstatistica(
                        titulo: "Backlog",
                        valor: "${(tenho - lidos) < 0 ? 0 : (tenho - lidos)}",
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CartaoEstatistica(
                        titulo: "Taxa de Leitura",
                        valor:
                            "${totais > 0 ? ((lidos / totais) * 100).round() : 0}%",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 58, 97, 55)!,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<List<Obra>>(
                  future: DataBaseHelper.instance.getObras(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Sua coleção está vazia",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    final listaDeObras = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: listaDeObras.length,
                      itemBuilder: (context, index) {
                        final obra = listaDeObras[index];

                        return Dismissible(
                          key: ValueKey(obra.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (direction) async {
                            await DataBaseHelper.instance.deleteObra(obra.id!);
                            _atualizarEstatisticas();
                            setState(() {});
                          },

                          child: CardObra(
                            titulo: obra.nome,
                            tipo: obra.tipo,
                            progresso: "${obra.lidos}/${obra.total}",
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(26.0),
        child: SizedBox(
          height: 36,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color.fromARGB(255, 23, 51, 32),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const FormularioObra(),
                  );
                },
              );

              _atualizarEstatisticas();
            },

            child: const Text(
              "Adicionar Obra",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

