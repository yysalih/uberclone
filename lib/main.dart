import 'dart:async';
import 'package:ebuber/repos/app_repo.dart';
import 'package:ebuber/repos/card_repo.dart';
import 'package:ebuber/welcome_pages/welcome_page.dart';

import 'classes/card.dart' as card;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/message.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/recentdrive.dart';
import 'package:ebuber/classes/rent.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/repos/active_drive_repo.dart';
import 'package:ebuber/repos/address_repo.dart';
import 'package:ebuber/repos/driver_repo.dart';
import 'package:ebuber/repos/message_repo.dart';
import 'package:ebuber/repos/passenger_repo.dart';
import 'package:ebuber/repos/rating_repo.dart';
import 'package:ebuber/repos/recent_drive_repo.dart';
import 'package:ebuber/repos/rent_repo.dart';
import 'package:ebuber/repos/sent_request_repo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ebuber/passenger/screens/main_pages/profile_page.dart';
import 'package:ebuber/welcome_pages/login_register_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classes/activedriver.dart';
import 'classes/rating.dart';
import 'constant.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as nots;
import 'package:firebase_messaging/firebase_messaging.dart' as message;


Future<void> _firebaseMessagingBackgroundHandler(message.RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}


const nots.AndroidNotificationChannel channel = nots.AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: nots.Importance.high,
);
final nots.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = nots.FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  message.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      nots.AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await message.FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  message.FirebaseMessaging messaging = message.FirebaseMessaging.instance;

  // Get any messages which caused the app to open from a terminated state
  message.RemoteMessage? initialMessage = await messaging.getInitialMessage();

  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void requestAndRegisterNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    message.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    message.NotificationSettings settings = await message.FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

  }


  @override
  void initState() {
    requestAndRegisterNotification();
    super.initState();
    var initializationSettingsAndroid = new nots.AndroidInitializationSettings('ic_launcher');
    var initialzationSettingsAndroid = nots.AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = nots.InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    message.FirebaseMessaging.onMessage.listen((message.RemoteMessage messageee) {
      message.RemoteNotification? notification = messageee.notification;
      message.AndroidNotification? android = messageee.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            nots.NotificationDetails(
              android: nots.AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sen Götür',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [ProfilePage(), ProfilePage(), ProfilePage(), ProfilePage()];

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SplashScreen(),//pages[_currentIndex],

    );
  }

}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => WelcomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,//Color(0xFFecf6f3),//Color(0xFF0b1405),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo here


            Image.asset(
              'images/app/logotext.png',

              width: width * .8,
              fit: BoxFit.contain,
            ),
            // SizedBox(
            //   height: 25,
            // ),
            // Text("TosbaaGo", style: TextStyle(color: kDarkColors[0],
            //   fontWeight: FontWeight.bold, fontSize: 45, fontFamily: kFontFamily
            // ),)
            // CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            // )
          ],
        ),
      ),
    );
  }


}




final passengerStreamProvider = StreamProvider.autoDispose.family<Passenger, String?>((ref, uid) {
  // get repository from the provider below
  final passengerRepository = ref.watch(passengerRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return passengerRepository.getPassenger();
});

final passengerRepositoryProvider = Provider.family<PassengerRepository, String?>((ref, uid) {
  return PassengerRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final passengersStreamProvider = StreamProvider.autoDispose<List<Passenger>>((ref) {
  // get repository from the provider below
  final passengersRepository = ref.watch(passengersRepositoryProvider);

  // call method that returns a Future<Weather>
  return passengersRepository.getPassengers();
});

final passengersRepositoryProvider = Provider<PassengerRepository>((ref) {
  return PassengerRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});

//----------------------------------

final driverStreamProvider = StreamProvider.autoDispose.family<Driver, String?>((ref, uid) {
  // get repository from the provider below
  final driverRepository = ref.watch(driverRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return driverRepository.getDriver();
});

final driverRepositoryProvider = Provider.family<DriverRepository, String?>((ref, uid) {
  return DriverRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final driversStreamProvider = StreamProvider.autoDispose<List<Driver>>((ref) {
  // get repository from the provider below
  final driversRepository = ref.watch(driversRepositoryProvider);

  // call method that returns a Future<Weather>
  return driversRepository.getDrivers();
});

final driversRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});


//----------------------------------

final addressStreamProvider = StreamProvider.autoDispose.family<Address, String?>((ref, uid) {
  // get repository from the provider below
  final addressRepository = ref.watch(addressRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return addressRepository.getAddress();
});

final addressRepositoryProvider = Provider.family<AddressRepository, String?>((ref, uid) {
  return AddressRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final addressesStreamProvider = StreamProvider.autoDispose<List<Address>>((ref) {
  // get repository from the provider below
  final addressesRepository = ref.watch(addressesRepositoryProvider);

  // call method that returns a Future<Weather>
  return addressesRepository.getAddresses();
});

final addressesRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});

//----------------------------------

final recentDriveStreamProvider = StreamProvider.autoDispose.family<RecentDrive, String?>((ref, uid) {
  // get repository from the provider below
  final recentDriveRepository = ref.watch(recentDriveRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return recentDriveRepository.getRecentDrive();
});

final recentDriveRepositoryProvider = Provider.family<RecentDriveRepository, String?>((ref, uid) {
  return RecentDriveRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final recentDrivesStreamProvider = StreamProvider.autoDispose<List<RecentDrive>>((ref) {
  // get repository from the provider below
  final recentDrivesRepository = ref.watch(recentDrivesRepositoryProvider);

  // call method that returns a Future<Weather>
  return recentDrivesRepository.getRecentDrives();
});

final recentDrivesRepositoryProvider = Provider<RecentDriveRepository>((ref) {
  return RecentDriveRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});

//----------------------------------

final sentRequestStreamProvider = StreamProvider.autoDispose.family<SentRequest, String?>((ref, uid) {
  // get repository from the provider below
  final sentRequestRepository = ref.watch(sentRequestRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return sentRequestRepository.getSentRequest();
});

final sentRequestRepositoryProvider = Provider.family<SentRequestRepository, String?>((ref, uid) {
  return SentRequestRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final sentRequestsStreamProvider = StreamProvider.autoDispose<List<SentRequest>>((ref) {
  // get repository from the provider below
  final sentRequestsRepository = ref.watch(sentRequestsRepositoryProvider);

  // call method that returns a Future<Weather>
  return sentRequestsRepository.getSentRequests();
});

final sentRequestsRepositoryProvider = Provider<SentRequestRepository>((ref) {
  return SentRequestRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});

//----------------------------------

final messagesStreamProvider = StreamProvider.autoDispose.family<List<Message>, String?>((ref, uid) {
  // get repository from the provider below
  final messagesRepository = ref.watch(messagesRepositoryProvider(uid));

  // call method that returns a Future<Weather>
  return messagesRepository.getMessages();
});

final messagesRepositoryProvider = Provider.family<MessageRepository, String?>((ref, uid) {
  return MessageRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid); // declared elsewhere
});

//----------------------------------

final ratingsStreamProvider = StreamProvider.autoDispose.family<List<Rating>, String?>((ref, uid) {
  // get repository from the provider below
  final ratingsRepository = ref.watch(ratingsRepositoryProvider(uid));

  // call method that returns a Future<Weather>
  return ratingsRepository.getRatings();
});

final ratingsRepositoryProvider = Provider.family<RatingRepository, String?>((ref, uid) {
  return RatingRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid); // declared elsewhere
});

//----------------------------------

final rentStreamProvider = StreamProvider.autoDispose.family<Rent, String?>((ref, uid) {
  // get repository from the provider below
  final rentRepository = ref.watch(rentRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return rentRepository.getRent();
});

final rentRepositoryProvider = Provider.family<RentRepository, String?>((ref, uid) {
  return RentRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final rentsStreamProvider = StreamProvider.autoDispose<List<Rent>>((ref) {
  // get repository from the provider below
  final rentsRepository = ref.watch(rentsRepositoryProvider);

  // call method that returns a Future<Weather>
  return rentsRepository.getRents();
});

final rentsRepositoryProvider = Provider<RentRepository>((ref) {
  return RentRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});


//-----------------------------------------

final cardStreamProvider = StreamProvider.autoDispose.family<card.Card, String?>((ref, uid) {
  // get repository from the provider below
  final cardRepository = ref.watch(cardRepositoryProvider(uid));

  // call method that returns a Stream<User>
  return cardRepository.getCard();
});

final cardRepositoryProvider = Provider.family<CardRepository, String?>((ref, uid) {
  return CardRepository(firebaseFirestore: FirebaseFirestore.instance, uid: uid);
});

final cardsStreamProvider = StreamProvider.autoDispose<List<card.Card>>((ref) {
  // get repository from the provider below
  final cardsRepository = ref.watch(cardsRepositoryProvider);

  // call method that returns a Future<Weather>
  return cardsRepository.getCards();
});

final cardsRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});

//----------------------------------
final startHourStreamProvider = StreamProvider.autoDispose<int>((ref) {
  // get repository from the provider below
  final appRepository = ref.watch(appRepositoryProvider);

  // call method that returns a Future<Weather>
  return appRepository.getStartHour();
});

final endHourStreamProvider = StreamProvider.autoDispose<int>((ref) {
  // get repository from the provider below
  final appRepository = ref.watch(appRepositoryProvider);

  // call method that returns a Future<Weather>
  return appRepository.getEndHour();
});

final driveKmStreamProvider = StreamProvider.autoDispose<int>((ref) {
  // get repository from the provider below
  final appRepository = ref.watch(appRepositoryProvider);

  // call method that returns a Future<Weather>
  return appRepository.getDriveKm();
});

final rentDaytreamProvider = StreamProvider.autoDispose<int>((ref) {
  // get repository from the provider below
  final appRepository = ref.watch(appRepositoryProvider);

  // call method that returns a Future<Weather>
  return appRepository.getRentDayPrice();
});

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository(firebaseFirestore: FirebaseFirestore.instance,); // declared elsewhere
});
