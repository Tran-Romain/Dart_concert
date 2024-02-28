import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConcertService {
  String baseUrl = "http://10.33.18.213:8001/public/User/loginJwt";
  http.Client client = http.Client();
  String? authToken;

/*
  Future<void> initializeAuthToken() async {
    authToken = await loginJwt();
    print("AuthToken: $authToken");  // Ajoute cette ligne pour déboguer
  }*/


  Future<String?> loginJwt() async {
    try {
      var url = Uri.parse(baseUrl);
      var response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'mail': 'romain@mail.com',
          'password': 'azerty',
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Correction ici
      } else {
        print("Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la requête HTTP: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>?> getAll() async {
    // Assurez-vous que le token est disponible
    authToken = await loginJwt();
    await Future.delayed(Duration(seconds: 2));

    print("authToken ici: $authToken");
    // Construire l'URL
    String completeURL = 'http://10.33.18.213:8001/public/ApiConcert/getAll';

    final response = await http.get(
      Uri.parse(completeURL),
      headers: {
        'Authorization': 'Bearer ${authToken}',
        'Content-Type': 'application/json',
      },
    );

    print("response code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> concertsJsonList = jsonDecode(response.body);


      return {
        'code': 0,
        'body': concertsJsonList,
      };
    }

    return {
      'code': 1,
      'body': 'Erreur lors de la récupération des concerts',
    };
  }


  // Fermez le client HTTP lorsqu'il n'est plus nécessaire
  void closeClient() {
    client.close();
  }

  Future<Map<String, dynamic>?> add(String nomGroupe, DateTime dateHeure, double tarif, double longitude, double latitude, String email, String imageNom, String imageRepo, String referent, String adresse) async {

    String? authToken = await loginJwt();
    await Future.delayed(Duration(seconds: 2));

    print("authToken ici: $authToken");

    String completeURL = 'http://10.33.18.213:8001/public/ApiConcert/add';

    final Map<String, dynamic> requestBody = {
      'NomGroupe': nomGroupe,
      'DateHeure': dateHeure.toIso8601String(),
      'Tarif': tarif.toString(),
      'Longitude': longitude.toString(),
      'Latitude': latitude.toString(),
      'Email': email,
      'ImageNom': imageNom,
      'ImageRepo': imageRepo,
      'Referent': referent,
      'Adresse': adresse,
    };

    final response = await http.post(
      Uri.parse(completeURL),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: requestBody,
    );

    print("response code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final dynamic responseBody = jsonDecode(response.body);

      return {
        'code': 0,
        'body': responseBody,
      };
    }

    return {
      'code': 1,
      'body': 'Erreur lors de lajout du concert',
    };
  }

}
