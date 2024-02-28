import 'package:flutter/material.dart';
import 'package:projet_concert/models/concert.dart';
import 'package:projet_concert/services/api_concert_service.dart';
import 'package:geolocator/geolocator.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Concert? concertActuel;
  List<Concert>? concerts;
  bool isLoading = true;
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    recuperer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des concerts"),
        actions: [

          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {

              print("Ajouter un nouvel élément");
              ajoutDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (concerts == null || concerts!.isEmpty)
          ? Text("Aucun concert dans la liste")
          : buildConcertList(),
      floatingActionButton: buildBoutonNavigationPage(),
    );
  }

  Widget buildConcertList() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    endIndex = endIndex > concerts!.length ? concerts!.length : endIndex;

    List<Concert> currentPageConcerts = concerts!.sublist(startIndex, endIndex);

    return Container(
      margin: EdgeInsets.only(bottom: 90.0),

      child: ListView.builder(
        itemCount: currentPageConcerts.length,
        itemBuilder: (BuildContext context, int index) {
          Concert concert = currentPageConcerts[index];

          return ListTile(
            title: Text(concert.nomGroupe!),
            subtitle: Text(
                "Date et heure: ${concert.dateHeure}, Adresse: ${concert
                    .adresse}"),
            leading: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                concertActuel = concert;
                afficherDetails();
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildBoutonNavigationPage() {
    int totalPages = (concerts!.length / itemsPerPage).ceil();

    return Container(
      height: 80.0,
      child: Scrollbar(
        controller: ScrollController(),

        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalPages, (index) {
              return SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage = index + 1;
                      });
                    },
                    child: Text("${index + 1}"),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> afficherDetails() async {
    if (concertActuel != null) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Details du concert"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nom du groupe: ${concertActuel!.nomGroupe}"),
                Text("Date et heure: ${concertActuel!.dateHeure}"),
                Text("Adresse: ${concertActuel!.adresse}"),
                Text("Email: ${concertActuel!.email}"),
                Text("Tarif: ${concertActuel!.tarif}€"),
                Text("Organisateur : ${concertActuel!.referent}"),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Fermer"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> recuperer() async {
    try {
      ApiConcertService apiConcertService = ApiConcertService();
      dynamic response = await apiConcertService.getAll();
      print(response);

      if (response != null) {
        if (response is Map<String, dynamic>) {
          List<dynamic>? concertsJsonList = response['body'];

          if (concertsJsonList != null) {
            List<Concert> concertList =
            concertsJsonList.map((json) => Concert.fromMap(json)).toList();

            setState(() {
              concerts = concertList;
              isLoading = false;
            });
          } else {
            print("body n'a pas été trouvée dans la réponse JSON.");
            setState(() {
              isLoading = false;
            });
          }
        } else {
          print("La réponse n'est pas du bon type ");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Erreur lors de la récupération des concerts.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print("Erreur lors de la récupération des concerts: $e");
      print("StackTrace: $stackTrace");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> ajouter(Concert concert) async {
    try {
      ApiConcertService apiConcertService = ApiConcertService();
      dynamic response = await apiConcertService.add(
        concert.nomGroupe!,
        concert.dateHeure,
        concert.tarif!.toDouble(),
        concert.longitude!.isNotEmpty ? concert.longitude![0] : 0.0,
        concert.latitude!.isNotEmpty ? concert.latitude![0] : 0.0,
        concert.email!,
        concert.imageNom!,
        concert.imageRepo!,
        concert.referent!,
        concert.adresse!,
      );

      // Vérifiez le résultat de la requête ici si nécessaire
      if (response != null && response['code'] == 0) {
        print('Concert ajoute avec succes');
        print(response['body']);
        // Si vous avez besoin de faire quelque chose après l'ajout, faites-le ici
      } else {
        print('Erreur lors de lajout du concert');
        print(response != null ? response['body'] : 'Reponse nulle');
      }
    } catch (e) {
      print('Erreur lors de lajout du concert: $e');
    }
  }
  Future<Position?> obtenirLocalisation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {

          return null;
        }
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print("Erreur lors de la recuperation de la localisation : $e");
      return null;
    }
  }

  Future<void> ajoutDialog() async {
    TextEditingController nomGroupeController = TextEditingController();
    TextEditingController referentController = TextEditingController();
    TextEditingController tarifController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController adresseController = TextEditingController();
    Position? positionactuel = await obtenirLocalisation();
    double  longitude= positionactuel?.longitude?? 0.0;
    double  latitude= positionactuel?.latitude?? 0.0;
    String longitudeString = longitude.toString();
    String latitudeString = latitude.toString();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: (concertActuel?.nomGroupe == null)
              ? Text('Ajouter un concert')
              : Text('Modifier ${concertActuel?.nomGroupe}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nomGroupeController,
                decoration: InputDecoration(labelText: 'NomGroupe'),
              ),
              TextField(
                controller: tarifController,
                decoration: InputDecoration(labelText: 'Tarif'),
              ),
              TextField(
                controller: referentController,
                decoration: InputDecoration(labelText: 'Referent'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(buildContext);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Concert updatedConcert = Concert(
                  nomGroupe: nomGroupeController.text,
                  dateHeure: DateTime.now(),
                  tarif: int.tryParse(tarifController.text) ?? 0,
                  referent: nomGroupeController.text,
                  email: emailController.text,
                  latitude: [double.tryParse(latitudeString) ?? 0.0],
                  longitude: [double.tryParse(longitudeString) ?? 0.0],
                  adresse: "",
                  imageNom: "",
                  imageRepo: "",

                );

                await ajouter(updatedConcert);
                recuperer();

                Navigator.pop(buildContext);
              },
              child: Text(
                'Valider',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}