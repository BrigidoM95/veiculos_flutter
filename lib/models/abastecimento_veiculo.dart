import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  String? id;
  DateTime data;
  double quantidadeLitros;
  double valorPago;
  double quilometragem;
  String tipoCombustivel;
  String veiculoId;
  double consumo;
  String? observacao;
  String ownerUid;

  Abastecimento({
    this.id,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    required this.veiculoId,
    required this.consumo,
    this.observacao,
    required this.ownerUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'veiculoId': veiculoId,
      'consumo': consumo,
      'observacao': observacao,
      'ownerUid': ownerUid,
    };
  }

  factory Abastecimento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Abastecimento(
      id: doc.id,
      data: (data['data'] as Timestamp).toDate(),
      quantidadeLitros: (data['quantidadeLitros'] ?? 0).toDouble(),
      valorPago: (data['valorPago'] ?? 0).toDouble(),
      quilometragem: (data['quilometragem'] ?? 0).toDouble(),
      tipoCombustivel: data['tipoCombustivel'] ?? '',
      veiculoId: data['veiculoId'] ?? '',
      consumo: (data['consumo'] ?? 0).toDouble(),
      observacao: data['observacao'],
      ownerUid: data['ownerUid'] ?? '',
    );
  }
}
