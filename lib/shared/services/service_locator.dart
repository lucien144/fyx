import 'package:fyx/features/gallery/presentation/viewmodel/gallery_viewmodel.dart';
import 'package:fyx/features/mail/data/repositories/mail_repository_impl.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mail_viewmodel.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:fyx/features/premium/data/repositories/premium_repository_impl.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_viewmodel.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/data/repositories/userstats_repository_impl.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_viewmodel.dart';
import 'package:fyx/shared/services/supabase_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Setup dependency injection with GetIt
void setupServiceLocator() {
    // Shared infrastructure
    getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());

    // ViewModels
    getIt.registerSingleton<GalleryViewModel>(GalleryViewModel());
    getIt.registerSingleton<MessageViewModel>(MessageViewModel());

    // Mail
    getIt.registerLazySingleton<MailRepository>(() => MailRepositoryImpl());
    getIt.registerSingleton<MailViewModel>(MailViewModel(getIt<MailRepository>()));

    // Premium
    getIt.registerLazySingleton<PremiumLocalDatasource>(() => PremiumLocalDatasource());
    getIt.registerLazySingleton<PremiumRemoteDatasource>(() => PremiumRemoteDatasource(getIt<SupabaseService>()));
    getIt.registerLazySingleton<PremiumRepository>(
        () => PremiumRepositoryImpl(getIt<PremiumLocalDatasource>(), getIt<PremiumRemoteDatasource>()));
    getIt.registerSingleton<PremiumViewModel>(PremiumViewModel(getIt<PremiumRepository>()));

    // Userstats
    getIt.registerLazySingleton<UserstatsDatabase>(() => UserstatsDatabase());
    getIt.registerLazySingleton<UserstatsRepository>(
        () => UserstatsRepositoryImpl(getIt<UserstatsDatabase>()),
    );
    getIt.registerSingleton<YearInReviewViewModel>(YearInReviewViewModel(getIt<UserstatsRepository>()));

}

/// Global accessor for UserstatsRepository
UserstatsRepository get userstatsRepo => getIt<UserstatsRepository>();
