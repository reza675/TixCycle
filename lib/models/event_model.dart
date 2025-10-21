import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/ticket_model.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final double startingPrice;
  final String imageUrl;
  final DateTime date;
  final String address;
  final String city;
  final GeoPoint coordinates;
  final String venueName;
  final String organizerId;
  final List<TicketModel> tickets;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    this.startingPrice = 0.0,
    this.imageUrl = '',   // image url default isi disini 
    required this.date,
    required this.address,
    required this.city,
    required this.coordinates,
    required this.venueName,
    required this.organizerId,
    this.tickets = const [],
  });

  factory EventModel.fromSnapshot(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      coordinates: data['coordinates'] ?? GeoPoint(0,0),
      organizerId: data['organizerId'] ?? '',
      venueName: data['venueName']?? '',
      startingPrice: (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '', // image url default isi disini 
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'name' : name,
      'description' : description,
      'startingPrice' : startingPrice,
      'imageUrl' : imageUrl,
      'date' : Timestamp.fromDate(date),
      'address' : address,
      'venueName' : venueName,
      'organizerId' : organizerId,
    };
  }
}