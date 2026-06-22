class Obra {
  final int? id;
  final String nome;
  final String autor;
  final String editora;
  final String tipo;
  final String estado;
  final int total;
  final int tenho;
  final int lidos;

  Obra(
    {
    this.id,
    required this.nome,
    required this.autor,
    required this.editora,
    required this.tipo,
    required this.estado,
    required this.total,
    required this.tenho,
    required this.lidos,
  }
  );
  Map <String, dynamic> toMap(){
    return {
      'id': id,
      'nome': nome,
      'autor': autor,
      'editora': editora,
      'tipo': tipo,
      'estado': estado,
      'total': total,
      'tenho': tenho,
      'lidos': lidos,
    };
  }

  factory Obra.fromMap(Map<String, dynamic> map){
    return Obra(
      id: map['id'],
      nome: map['nome'],
      autor: map['autor'],
      editora: map['editora'],
      tipo: map['tipo'],
      estado: map['estado'],
      total: map['total'],
      tenho: map['tenho'],
      lidos: map['lidos'],
    );
  }
}
