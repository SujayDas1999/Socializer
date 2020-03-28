import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();

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
void initState(){
  super.initState();  
  pageController = PageController(

  );
  googleSignIn.onCurrentUserChanged.listen((account){
    if(account != null)
    {
      print('User signed in: $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }

  }
   );
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
        Timeline(),
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
