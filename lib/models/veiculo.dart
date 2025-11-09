// lib/models/veiculo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  String? id;
  String modelo;
  String marca;
  String placa;
  int ano;
  String tipoCombustivel;
  String ownerUid; // id do usuário dono

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
    required this.ownerUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
      'ownerUid': ownerUid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Veiculo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Veiculo(
      id: doc.id,
      modelo: data['modelo'] ?? '',
      marca: data['marca'] ?? '',
      placa: data['placa'] ?? '',
      ano: (data['ano'] ?? 0) is int
          ? data['ano']
          : int.tryParse('${data['ano']}') ?? 0,
      tipoCombustivel: data['tipoCombustivel'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
    );
  }
}
