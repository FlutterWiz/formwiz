import 'package:equatable/equatable.dart';

/// Base failure class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Failure that occurs during form validation
class ValidationFailure extends Failure {
  final Map<String, String?> errors;
  
  const ValidationFailure({
    required String message,
    this.errors = const {},
  }) : super(message: message);
  
  @override
  List<Object> get props => [message, errors];
} 