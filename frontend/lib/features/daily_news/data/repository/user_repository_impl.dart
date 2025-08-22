import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<DataState<void>> updateUserName(String name) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const DataSuccess(null);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({'name': name.trim()}, SetOptions(merge: true));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/users/updateName'), error: e));
    }
  }

  @override
  Future<DataState<String>> getUserName(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final name = (snap.data()?['name'] ?? '').toString();
      return DataSuccess(name);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/users/getName'), error: e));
    }
  }

  @override
  Future<DataState<String?>> getCurrentUserId() async {
    try {
      return DataSuccess(FirebaseAuth.instance.currentUser?.uid);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/auth/currentUser'), error: e));
    }
  }
}


