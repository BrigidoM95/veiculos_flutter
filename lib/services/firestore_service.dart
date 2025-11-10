import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';
import '../models/abastecimento_veiculo.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  String? get _uid => _auth.currentUser?.uid;

  // ==================== VEÍCULOS ====================
  CollectionReference<Map<String, dynamic>> _veiculosRef(String uid) {
    return _db.collection('users').doc(uid).collection('veiculos');
  }

  Future<void> addVeiculo(Veiculo v) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    final col = _veiculosRef(uid);
    final docRef = col.doc();
    v.id = docRef.id;
    await docRef.set(v.toMap());
  }

  Stream<List<Veiculo>> streamVeiculos() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _veiculosRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Veiculo.fromDoc(d)).toList());
  }

  Future<List<Veiculo>> getVeiculos(String uid) async {
    final query = await _veiculosRef(uid).get();
    return query.docs.map((d) => Veiculo.fromDoc(d)).toList();
  }

  Future<Veiculo?> getVeiculo(String id) async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _veiculosRef(uid).doc(id).get();
    if (!doc.exists) return null;
    return Veiculo.fromDoc(doc);
  }

  Future<void> updateVeiculo(Veiculo v) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    if (v.id == null) throw Exception('Veículo sem id');
    await _veiculosRef(uid).doc(v.id).update({
      'modelo': v.modelo,
      'marca': v.marca,
      'placa': v.placa,
      'ano': v.ano,
      'tipoCombustivel': v.tipoCombustivel,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteVeiculo(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _veiculosRef(uid).doc(id).delete();
  }

  // ==================== ABASTECIMENTOS ====================

  CollectionReference<Map<String, dynamic>> _abastecimentosRef(String uid) {
    return _db.collection('users').doc(uid).collection('abastecimentos');
  }

  Future<void> addAbastecimento(Abastecimento a) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    final col = _abastecimentosRef(uid);
    final docRef = col.doc();
    a.id = docRef.id;
    await docRef.set(a.toMap());
  }

  Stream<List<Abastecimento>> streamAbastecimentos() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _abastecimentosRef(uid)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Abastecimento.fromFirestore(d)).toList(),
        );
  }

  Future<void> deleteAbastecimento(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _abastecimentosRef(uid).doc(id).delete();
  }

  Future<void> updateAbastecimento(Abastecimento a) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    if (a.id == null) throw Exception('Abastecimento sem id');
    await _abastecimentosRef(uid).doc(a.id).update({
      'data': Timestamp.fromDate(a.data),
      'quantidadeLitros': a.quantidadeLitros,
      'valorPago': a.valorPago,
      'quilometragem': a.quilometragem,
      'tipoCombustivel': a.tipoCombustivel,
      'consumo': a.consumo,
      'observacao': a.observacao,
      'ownerUid': a.ownerUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
