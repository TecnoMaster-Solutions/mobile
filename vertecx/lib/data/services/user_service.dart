import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import '../models/users/user_model.dart';


class UserService {
  String get _baseUrl => kBackendBaseUrl;

  Future<List<UserModel>> getUsers() async {
    final url = Uri.parse('$_baseUrl/users');
    final response = await ApiHttp.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> payload = jsonData is List
          ? jsonData
          : (jsonData is Map<String, dynamic>
              ? List<dynamic>.from(jsonData['data'] ?? [])
              : []);

      return payload
          .map((e) => UserModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Error al obtener usuarios: ${response.statusCode}',
    );
  }

  Future<UserModel> updateUserStatus(String userId, bool newStatus) async {
    final int stateId = newStatus ? 1 : 2;

    final url = Uri.parse('$_baseUrl/users/$userId');
    final response = await ApiHttp.patch(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'stateid': stateId}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserModel.fromJson(jsonData['data']);
    }

    throw Exception(
      'Error al actualizar estado: ${response.statusCode} - ${response.body}',
    );
  }
}
