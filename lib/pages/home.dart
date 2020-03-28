import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

bool isAuth = false;
PageController pageController;
int pageIndex = 0;
@override
void dispose(){
  super.dispose();
  pageController.dispose();
}

login(){
  googleSignIn.signIn();
}

logout(){
  googleSignIn.signOut();
}

 @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }


  handleSignIn(GoogleSignInAccount account){
    if(account != null)
    {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }

  }

createUserInFirestore() async {
  //check if user exists in users collection in database
  final GoogleSignInAccount user = googleSignIn.currentUser;
  DocumentSnapshot doc = await usersRef.document(user.id).get();

  //if the user doesnt exist then take them to create account page

  if(!doc.exists){
   final username = await Navigator.push(
      context, MaterialPageRoute(
        builder: (context) => CreateAccount()
      ),
    );
  usersRef.document(user.id).setData({
    'id': user.id,
    'username': username,
    'photoUrl': user.photoUrl,
    'email': user.email,
    'displayName': user.displayName,
    'bio':"",
    'timestamp': timestamp
  });


  doc = await usersRef.document(user.id).get();
  }

  //get user name from create account use it to make new user document in users collection  

  currentUser = User.fromDocument(doc);
  print(currentUser);
  print(currentUser.username);
}


onPageChanged(int pageIndex){
  setState(() {
    this.pageIndex = pageIndex;
  });

}
onTap(int pageIndex){
  pageController.animateToPage(
    pageIndex,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOutCirc
  );
}


Scaffold buildAuthScreen(){
  return Scaffold(
    body: PageView(
      children: <Widget>[
        //Timeline(),
         RaisedButton(
    child: Text('Logout'),
    onPressed: logout,
  ),
        ActivityFeed(),
        Upload(),
        Search(),
        Profile(),
      ],
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: NeverScrollableScrollPhysics(), 
    ),
    bottomNavigationBar: CupertinoTabBar(
      currentIndex: pageIndex,
      onTap: onTap,
      activeColor: Colors.blueAccent,
      items:[
        BottomNavigationBarItem(icon: Icon(Icons.timeline)),
        BottomNavigationBarItem(icon: Icon(Icons.notifications)),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 40.0)),
        BottomNavigationBarItem(icon: Icon(Icons.search)),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle)),      ]
    ),
    
  );
  // return RaisedButton(
  //   child: Text('Logout'),
  //   onPressed: logout,
  // );
}

Scaffold buildUnAuthScreen(){
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).accentColor.withOpacity(0.6),
            Theme.of(context).primaryColor,
          ]
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Sociolizer',
          style: TextStyle(
            fontFamily: "Signatra",
            fontSize: 90.0,
            color: Colors.white, 
          ),
          ),
          GestureDetector(
            onTap: login,
            child: Container(
              width: 260,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/google_signin_button.png'),
                  fit: BoxFit.cover,
                )
              ),
            ),
          ),
        ]
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
