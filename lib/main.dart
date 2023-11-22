import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/responsive/mobile_screen_Layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    //the condition is to check the platforms web or mobile
    //this is done for our web app. web apps usually require the options property of type FirebaseOptions
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCSWveVegUfXgZPmNG2zFhg4Y8d6r8BdnQ",
        appId: "1:53266328746:web:da96a3db9926d670b974d3",
        messagingSenderId: "53266328746",
        projectId: "instagram-clone-20b4b",
        storageBucket: "instagram-clone-20b4b.appspot.com",
        //storageBucket since we are going to firebase storage
        //all this data is gotten from firebase(sdk) when creating a firebase prject for our web app
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
            //firebase returns StreamBuilder
            //persisting user authentication state
            //we are using the uid
            //a user can only have uid if they're authenticated(registered)
            //and the uid is in the User object
            //firebase has provided use with a method we can use to know if the user is signed in
            //that method is authStateChanges()
            //this method runs when the user signs in or out
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((context, snapshot) {
              //checking if we've made connection to our stream, if the connection is active
              if (snapshot.connectionState == ConnectionState.active) {
                //then if it is active, does it have data as in the user object
                //we are getting data back from the stream when the user sign's in
                //the FirebaseAuth service is going to send something to us every time the user sign's in or out
                //and that something could be a null value if they signed out or user object. if they're signed in
                //our flutter app is going to receive those event object when thet happen
                // and determine based on the value inside of them whether they are user object or not i.e
                //whether the user is logged in or not
                //the snapshot holds the values(data)
                //the snapshot ony has data when the user is signed in
                if (snapshot.hasData) {
                  //so, if it has data
                  return const ResponsiveLayout(
                      webScreenLayout: WebScreenLayout(),
                      mobileScreenLayout: MobileScreenLayout());
                } else if (snapshot.hasError) {
                  //if it does not have data. if it has error
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                //ConnectionState.waiting means Connected to an asynchronous computation and awaiting interaction as in waiting for the result you want to get or for the result to set in the database
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              return const LoginScreen();
              //so if the snapshot has no data i.e the user is signed out, it should show the login screen
            })),
      ),
    );
  }
}
