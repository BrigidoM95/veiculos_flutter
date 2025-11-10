import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/abastecimento_veiculo.dart';

class FirestoreAbastecimentoService {
  final CollectionReference _abastecimentos = FirebaseFirestore.instance
      .collection('abastecimentos');

  Future<void> addAbastecimento(Abastecimento a) async {
    await _abastecimentos.add(a.toMap());
  }

  Stream<List<Abastecimento>> getAbastecimentos(String ownerUid) {
    return _abastecimentos
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Abastecimento.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> deleteAbastecimento(String id) async {
    await _abastecimentos.doc(id).delete();
  }

  Future<void> updateAbastecimento(Abastecimento a) async {
    await _abastecimentos.doc(a.id).update(a.toMap());
  }
}
