import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout(
      {Key? key,
      required this.webScreenLayout,
      required this.mobileScreenLayout})
      : super(key: key);
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  //where doing this here cus we want to use it in both webScreenLayout and mobileScreenLayout
  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    //Note: We’ve set listen to false because we don’t need to listen to any values here. We’re just dispatching an action to be performed.
    //listen false cus it will constantly to listen to values given by the provider and we don't want that
    //we just need to call refreshUser fn once on it
    //so, it's not going to listen for any update
      await _userProvider.refreshUser();
    //refreshUser() is what we are using to store value in our _user of type User in our User Provider class
  }
  //question, why is this in the initstate?
  //is it cus we want to call the function inside first?
  //so that the _user variable of type User can hold it
  //and we can then access it(in mobileScreenLayout and webScreenLayout) using the getter (getUser)
  //we can the use it in the build fn
  //NB:we doing all this here cus mobileScreenLayout and webScreenLayout both need the getter
  //we could do it individually in both widgets initstate

  //answer, we want to trigger the refreshUser() fn as the app is building or when we log in, so that we can get the user data(with the getter - getUser) by the time the app is done building or when we are logged in
  //cus if we just put it in the build fn, the refreshUser() fn will only be triggered when we use or call it manually and we don't want that.
  //we want it to be trigger when we are entering the app or when the app is being built. 
  //we want the user data to be gotten automatically when we the app is being built or when we log in, not when we trigger the fn manually
  //then we now use the user data in the build fn

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        //web screen
        return widget.webScreenLayout;
      } else {
        //mobile screen
        return widget.mobileScreenLayout;
      }
    }));
  }
}
