import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saif_final/models/login_model.dart';
import 'package:saif_final/views/subscribed_courses_page.dart';

class LoginViewModel {
  String? errorMessage;
///////////////////////////////////edit
  Future<void> login(LoginModel loginData, BuildContext context) async {
    errorMessage = null;

    const String loginUrl = "http://feeds.ppu.edu/api/login";

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData.toJson()),
      );

      if (response.statusCode == 200) {
        dynamic jsonObject = jsonDecode(response.body);
        if (jsonObject['status'] == 'success') {
          String token = jsonObject['session_token'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubscribedCoursesPage(token: token),
            ),
          );
        } else {
          errorMessage = 'Invalid credentials. Please try again.';
        }
      } else {
        errorMessage = 'Server error. Please try later.';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    }
  }
}
