import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Setup dependency injection with GetIt
void setupServiceLocator() {
  // ViewModels are registered as singletons per screen session
  // They are registered when screen opens and unregistered when it closes
}
