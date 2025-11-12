import 'package:tixcycle/services/ticket_validation_service.dart';

class TicketValidationRepository {
  final TicketValidationService _service;
  TicketValidationRepository(this._service);

  Future<String> validateAndCheckInTicket(String ticketId) async {
    try {
      return await _service.checkInTicket(ticketId);
    } catch (e) {
      return "Validasi Gagal: ${e.toString().replaceAll("Exception: ", "")}";
    }
  }
}

