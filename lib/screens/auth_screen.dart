
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/Auth.dart';
//import 'package:shop/models/http_exception.dart';

enum AuthMode {
  Login,
  SignUp
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors:  [Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                           Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
                  ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0,1],
              )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 90),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration : BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.deepOrange.shade900,
                            boxShadow: const [
                               BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0,10) // move shadow right left - up and down
                              )
                            ]
                          ),
                          transform: Matrix4.rotationZ(-8 * pi /180)..translate(-10.0),
                          child: const Text('My Shop', style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.normal, fontFamily: 'Anton'),))
                  ),
                  Flexible(
                      flex: deviceSize.width > 600 ? 2 : 1,
                      child: AuthCard())
                ],
              ),
            ),
          )
        ],
      ),
      
    );
  }
}

class AuthCard extends StatefulWidget{

  _AuthCardState createState() => _AuthCardState();

}

class _AuthCardState extends State<AuthCard>{

  final _formKey = GlobalKey<FormState>();
  var _authMode = AuthMode.Login;
  Map <String, String> _authData = {
    'email':'',
    'password': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _switchAuthMode (){
    if(_authMode == AuthMode.Login){
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    }else{
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  void _showErrorDialog (String message) {
     showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          },
              child: Text('Okay!'))
        ],
      );
    },);
  }

  Future<void> _submit() async{
    if(!_formKey.currentState!.validate()){
      return;
    }
    _formKey.currentState!.save();
    //print(_authData.values);
    setState(() {
      _isLoading = true;
    });

    try{
      if(_authMode == AuthMode.Login){
        await Provider.of<Auth>(context,listen: false).login(_authData['email']!, _authData['password']!);
      }else{
        await Provider.of<Auth>(context, listen: false).signup(_authData['email']!, _authData['password']!);
      }
    }on HttpException catch(error){
      var errorMessage = 'Authentication Failed';
      if(error.toString().contains('EMAIL_EXISTS')){
        errorMessage = 'Email Exists';
      }else if(error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'Invalid Email';
      }else if(error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'Weak Password';
      }else if(error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = 'Email not Found';
      }else if(error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'Invalid Password';
         _showErrorDialog(errorMessage);
      }
    }catch(error){
      const errorMessage = 'Could not Authenticate you, Try again later';
       _showErrorDialog(error.toString());
    }



    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final deviceSize = MediaQuery.of(context).size;


  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 8,
    child: Container(
      padding: EdgeInsets.all(12),
      width: deviceSize.width * 0.9,
       //height: _authMode == AuthMode.SignUp ? 320 : 260,
      //constraints: BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if(value!.isEmpty || !value.contains('@')){
                    return 'Invalid Email';
                  }
                },
                onSaved: (newValue) {
                  _authData['email'] = newValue!;
                },

              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if(value!.isEmpty || value.length < 6){
                    return 'Enter Password OR ur password is too short';
                  }
                },
                onSaved: (newValue) {
                  _authData['password'] = newValue!;
                },
              ),
              if(_authMode == AuthMode.SignUp)
              TextFormField(
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
                validator: _authMode == AuthMode.SignUp ? (value) {
                  if(value != _passwordController.text){
                    return 'passwords don\'t match';
                  }
                } : null,
              ),
              SizedBox(height: 20,),
              if(_isLoading)
                CircularProgressIndicator()
              else
              ElevatedButton(
                child: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 8)),
                ),
                onPressed: _submit,),
              TextButton(
                  child: Text('${_authMode == AuthMode.Login ? 'SignUp' : 'Login'} Instead'),
                  onPressed: _switchAuthMode, )
            ],
          ),
        ),
      ),
    ),
  );
  }
}
