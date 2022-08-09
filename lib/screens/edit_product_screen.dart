import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';


/// why stateful because FORMS are localState which we may need to validate and manipulate it locally before submitting it
class EditProductScreen extends StatefulWidget {

  static const routeName = '/edit-product-screen';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(productId: '', productTitle: '', productDescription: '', productPrice: 0, productImageUrl: '');
  var _isInit = true;
  var _initValues = {
    'title':'',
    'description':'',
    'price':'',
    'imageUrl':'',
  };
  var _isLoading = false;

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {

    if(_isInit){
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if(productId != null){
        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title' : _editedProduct.productTitle,
          'description' : _editedProduct.productDescription,
          'price': _editedProduct.productPrice.toString(),
          'imageUrl' : ''
        };
        _imageUrlController.text = _editedProduct.productImageUrl;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _updateImageUrl() {
      if(!_imageUrlFocusNode.hasFocus){
        setState(() {

        });
      }
  }

  Future <void> _saveForm() async {
  final isValid =_form.currentState!.validate();
  if(!isValid){
    return;
  }
  _form.currentState!.save();
  setState(() {
    _isLoading = true;
  });
  if(_editedProduct.productId != ''){
    await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.productId, _editedProduct);

  }else{
    try{
      await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }catch (error){
     await showDialog(context: context, builder: (ctx) =>
           AlertDialog(title: Text('Error'),content: Text('Something went wrong!'), actions: [
            TextButton(onPressed: (){
              Navigator.of(ctx).pop();
            }, child: Text('Okay'))
          ],
          )
        );
     }
     //finally{
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   Navigator.of(context).pop();
    // }

  }
  setState(() {
    _isLoading = false;
  });
  Navigator.of(context).pop();


    //alternative approach
    // .catchError((error){
    //   return showDialog(context: context, builder: (ctx) =>
    //      AlertDialog(title: Text('Error'),content: Text('Something went wrong!'), actions: [
    //       TextButton(onPressed: (){
    //         Navigator.of(ctx).pop();
    //       }, child: Text('Okay'))
    //     ],
    //     )
    //   );
    // })
    // .then((_) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   Navigator.of(context).pop();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm, )
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _form,
          child: ListView(
              children: [
            TextFormField( /// TEXTFORMFIELDS takes as much width as it can get
              initialValue: _initValues['title'],
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if(value!.isEmpty){
                  return 'Please enter a Title.';
                }
                return null;
                },
              onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_priceFocusNode),
              onSaved: (newValue) => _editedProduct = Product(
                  productId: _editedProduct.productId,
                  productTitle: newValue!,
                  productDescription: _editedProduct.productDescription,
                  productPrice: _editedProduct.productPrice,
                  productImageUrl: _editedProduct.productImageUrl,
                  isFavorite: _editedProduct.isFavorite),
            ),
            TextFormField(
             decoration: InputDecoration(labelText: 'Price'),
             initialValue: _initValues['price'],
             keyboardType: TextInputType.number,
             textInputAction: TextInputAction.next,
             focusNode: _priceFocusNode,
             onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_descriptionNode),
              validator: (value) {
                if(value!.isEmpty){
                  return 'Please Enter a Price.';
                }if(double.tryParse(value)== null){
                  return 'Please Enter a Valid Number.';
                }if(double.parse(value) <= 0){
                  return 'Please Enter a number greater than ZERO.';
                }
                return null;
              },
              onSaved: (newValue) => _editedProduct = Product(
                  productId: _editedProduct.productId,
                  productTitle: _editedProduct.productTitle,
                  productDescription: _editedProduct.productDescription,
                  productPrice: double.parse(newValue!),
                  productImageUrl: _editedProduct.productImageUrl,
                  isFavorite: _editedProduct.isFavorite),
                ),
             TextFormField(
               decoration: InputDecoration(labelText: 'Description'),
               initialValue: _initValues['description'],
               keyboardType: TextInputType.multiline,
               maxLines: 3,
               focusNode: _descriptionNode,
               validator: (value) {
                 if(value!.isEmpty){
                   return 'Please enter a Description !';
                 }if(value.length < 10){
                   return 'Should be at least 10 characters.';
                 }
                 return null ;
               },
               onSaved: (newValue) => _editedProduct = Product(
                   productId: _editedProduct.productId,
                   productTitle: _editedProduct.productTitle,
                   productDescription: newValue!,
                   productPrice: _editedProduct.productPrice,
                   productImageUrl: _editedProduct.productImageUrl,
                   isFavorite: _editedProduct.isFavorite),

             ),
             Row(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Container(
                   width: 100,
                   height: 100,
                   margin: EdgeInsets.only(top: 8, right: 10),
                   decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
                   child: _imageUrlController.text.isEmpty ? Text('Enter the URL',) :
                   FittedBox(child: Image.network(_imageUrlController.text, fit: BoxFit.cover,)),
                 ),
                 Expanded(
                   child: TextFormField(
                     decoration: InputDecoration(labelText: 'Image Url'),
                     //initialValue: _initValues['imageUrl'],
                     keyboardType: TextInputType.url,
                     textInputAction: TextInputAction.done,
                     controller: _imageUrlController, /// to get the value before submitting the form
                     focusNode: _imageUrlFocusNode,
                     onFieldSubmitted: (value) => _saveForm(),
                     validator: (value) {
                       if(value!.isEmpty){
                         return 'Please enter an Image URl.';
                       } if(!value.startsWith('http') && !value.startsWith('https')){
                         return 'Please enter valid URL.';
                       }if(!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')){
                         return 'Image URL extension should be .PNG or .JPG or .JPEG ';
                       }
                       return null;
                     },
                     onSaved: (newValue) => _editedProduct = Product(
                         productId: _editedProduct.productId,
                         productTitle: _editedProduct.productTitle,
                         productDescription: _editedProduct.productDescription,
                         productPrice: _editedProduct.productPrice,
                         isFavorite: _editedProduct.isFavorite,
                         productImageUrl: newValue!),
                   ),
                 ),
               ],
             )


          ]),
        ),
      ),
    );
  }




}
