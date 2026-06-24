import 'package:flutter/material.dart';
import '../Model/obra_model.dart';
import '../conection/database_helper.dart';



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

