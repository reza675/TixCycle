import 'package:tixcycle/models/validation_result_model.dart';
import 'package:tixcycle/services/ticket_validation_service.dart';

class TicketValidationRepository {
  final TicketValidationService _service;
  TicketValidationRepository(this._service);

  Future<ValidationResultModel> validateAndCheckInTicket(String ticketId) async {
    try {
      return await _service.checkInTicket(ticketId);
    } catch (e) {
      rethrow;
    }
  }
}

