import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier{
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;


  // bool isAuthMethod ([bool toLogout = false]){
  //  if(toLogout == false){
  //    return token != null;
  //  }else{
  //    return false;
  //  }
  // }

  bool get isAuth{

  return token != '';
  }

  String get token {
  if(_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != null ) {
    return _token!;
  }
  return '';
  }

  String get userId{
    return _userId!;
}

  Future<void> _authentication(String email, String password, String urlSegment) async {
    try{
      /// to get this url write in google(Firebase Auth REST API Docs) follow the steps
      final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyANKNw8i4rqBpzITrQ8ebC4cyFyQ6Zhaxk';
      final response = await http.post(Uri.parse(url), body: json.encode({
        'email' : email,
        'password' : password,
        'returnSecureToken' : true,
      }));
     // print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if(responseData['error'] != null){
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken']; /// to get and store idToken which is retrieved from the response in firebase auth docs
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print(_token);
      print(_userId);
      print(_expiryDate);
      autoLogout();
      notifyListeners();

      /// storing user data in the device storage + working with preferences involves working with futures
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({'token': _token, 'userId' : _userId, 'expiryDate': _expiryDate!.toIso8601String()});
      prefs.setString('userData', userData);

    }catch(error){
        throw error;
    }

  }

  Future<bool>  tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
      final extractedUserData = json.decode(prefs.getString('userData')! )as Map<String, dynamic> ;  // as Map<String, Object>
      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
      if(expiryDate.isBefore(DateTime.now())) {
        return false;
      }
        _token = extractedUserData['token'];
        _userId = extractedUserData['userId'];
        _expiryDate = expiryDate;
        notifyListeners();
        autoLogout();

      return true;

  }

  Future<void> signup(String email, String password) async {
        return _authentication(email, password, 'signUp');

  }

  Future<void> login(String email, String password) async{
      return _authentication(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;

    print(_token);
    print(_userId);
    print(_expiryDate);

    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('userData'); /// remove user data stored from map
    // prefs.clear(); /// clear() wil clear all the data stored in the storage
  }

  void autoLogout(){
      if(_authTimer != null){
        _authTimer!.cancel();
      }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

}