import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Model/obra_model.dart';
import '../conection/database_helper.dart';

class CartaoEstatistica extends StatelessWidget {
  final String titulo;
  final String valor;

  const CartaoEstatistica({
    super.key,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(76, 175, 80, 1),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

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

class FormularioObra extends StatefulWidget {
  const FormularioObra({super.key});
  @override
  State<FormularioObra> createState() => _FormularioObraState();
}

class _FormularioObraState extends State<FormularioObra> {
  final _nomeController = TextEditingController();
  final _autorController = TextEditingController();
  final _editoraController = TextEditingController();
  final _volTotaisController = TextEditingController();
  final _volLidosController = TextEditingController();
  final _volPossuidosController = TextEditingController();

  String _tipoSelecionado = 'Mangá';
  String _estadoSelecionado = 'Completo';

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF232833),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF232833),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF232833),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Nova Obra",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          _buildTextField("Nome", _nomeController),
          _buildTextField("Autor", _autorController),
          _buildTextField("Editora", _editoraController),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Tipo",
                  _tipoSelecionado,
                  ["Mangá", "Novel"],
                  (val) => setState(() => _tipoSelecionado = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  "Estado",
                  _estadoSelecionado,
                  ["Completo", "Em lançamento"],
                  (val) => setState(() => _estadoSelecionado = val!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Volumes Totais",
                  _volTotaisController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Volumes Lidos",
                  _volLidosController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Volumes Possuídos",
                  _volPossuidosController,
                  isNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_nomeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("O nome é obrigatorio"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                int totalConvertido =
                    int.tryParse(_volTotaisController.text) ?? 0;
                int tenhoConvertido =
                    int.tryParse(_volPossuidosController.text) ?? 0;
                int lidosConvertido =
                    int.tryParse(_volLidosController.text) ?? 0;

                Obra novaObra = Obra(
                  nome: _nomeController.text,
                  autor: _autorController.text,
                  editora: _editoraController.text,
                  tipo: _tipoSelecionado,
                  estado: _estadoSelecionado,
                  total: totalConvertido,
                  tenho: tenhoConvertido,
                  lidos: lidosConvertido,
                );

                await DataBaseHelper.instance.insertObra(novaObra);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Salvar",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardObra extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String progresso;

  const CardObra({
    super.key,
    required this.titulo,
    required this.tipo,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF232833),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            tipo == 'Mangá' ? Icons.book : Icons.book_outlined,
            color: tipo == 'Mangá'
                ? Colors.green
                : const Color.fromARGB(255, 0, 38, 255),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  tipo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              progresso,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
