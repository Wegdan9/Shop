import 'package:flutter/material.dart';
import 'package:shop/models/http_exception.dart';
import 'product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; /// to avoid naming clashes


/// ChangeNotifier class is  kind of related to inherited widget which is flutter uses behind the scenes.
class Products with ChangeNotifier{

  List <Product> _items = [
    // Product(
    //   productId: 'p1',
    //   productTitle: 'Red Shirt',
    //   productDescription: 'A red shirt - it is pretty red!',
    //   productPrice: 29.99,
    //   productImageUrl:
    //   'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   productId: 'p2',
    //   productTitle: 'Trousers',
    //   productDescription: 'A nice pair of trousers.',
    //   productPrice: 59.99,
    //   productImageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   productId: 'p3',
    //   productTitle: 'Yellow Scarf',
    //   productDescription: 'Warm and cozy - exactly what you need for the winter.',
    //   productPrice: 19.99,
    //   productImageUrl:
    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   productId: 'p4',
    //   productTitle: 'A Pan',
    //   productDescription: 'Prepare any meal you want.',
    //   productPrice: 49.99,
    //   productImageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);



  List<Product> get items{
    /** [...] to return a copy of _items why?
     * all objects in flutter are reference types
     * if we return _items[] then we would return a pointer at this object in memory
     * which means anywhere in the code when i get access Products class then access to _items
     * i get direct access to the _items[] in memory
     * hence we could start editing this _items[] from anywhere else in the app
     * which we don't want to do ! why?
     * because when Products change we have to call a certain method to tell all the listeners of this Provider that new data is available.
     * */
    return [..._items];
  }

  List<Product> get favoriteItems{
    return _items.where((product) => product.isFavorite).toList();
}
  Product findById(String id){
    return items.firstWhere((product) => product.productId == id);
  }

  Future <void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' :'';
    try{
      /// ?auth=$authToken here the fetched token to load the products for certain user
      /// &orderBy="creatorId"&equalTo="$userId filter mechanism made in firebase to get values which equal to userId
      var url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
      final response = await http.get(Uri.parse(url));
       final extractedData = json.decode(response.body) as Map<String, dynamic>;
       if(extractedData == null){
         return;
       }

       url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
       final favoriteResponse = await http.get(Uri.parse(url));
       final favoriteData = json.decode(favoriteResponse.body) ;

       final List<Product> loadedProducts = [];
       extractedData.forEach((productId, productData) {
         loadedProducts.add(Product(
             productId: productId,
             productTitle: productData['title'],
             productDescription: productData['description'],
             productPrice: productData['price'],
             isFavorite: favoriteData == null ? false : favoriteData[productId] ?? false,
             productImageUrl: productData['imageUrl'])
         );
       });
        _items = loadedProducts;
       notifyListeners();
    }catch(error){
      throw error;
    }

  }

  ///Future type is a trick to use then() in the EDIT_PRODUCT_SCREEN for loading
  Future <void> addProduct(Product product) async {
    /**
     * if we change the data in _items[]
     * how would we tell the widgets about this?
     * here the use of ChangeNotifier class which gives us access to notifyListeners()
     * this class will be used by provider package which uses inherited widget behind the scenes
     * to establish communication channels between this class and widgets are interested we need to let these widgets know about the changes
     * with the notifyListeners()
     * so in these widgets will rebuild and get latest data we have in _items[]
     * that's why we return a copy so we cant directly edit _items[] from anywhere in the app
     * because if we could do that we cant call notifyListeners() because its defined in ChangeNotifier
     * hence widgets depend on the data here will not re-build correctly because they wouldn't know about the change.
     * so we need to make sure that we change the data from this class,
     * because then we can trigger notifyListeners() and all widgets listing to that class will re-build
     * */

    final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try{
      /// post() method with return type future which is the response
      final response = await http.post(Uri.parse(url), body: json.encode({
        'title': product.productTitle,
        'description': product.productDescription,
        'price': product.productPrice,
        'imageUrl':product.productImageUrl,
        'isFavorite': product.isFavorite,
        'creatorId' : userId
      }));

      final newProduct = Product(
          productId: json.decode(response.body)['name'],
          productTitle: product.productTitle,
          productDescription: product.productDescription,
          productPrice: product.productPrice,
          productImageUrl: product.productImageUrl);

      _items.add(newProduct);
    }
    catch(error){
      throw error;
    }

      notifyListeners();


// alternative approach
    //     .then((response) {
    //   final newProduct = Product(
    //       productId: json.decode(response.body)['name'],
    //       productTitle: product.productTitle,
    //       productDescription: product.productDescription,
    //       productPrice: product.productPrice,
    //       productImageUrl: product.productImageUrl);
    //
    //   _items.add(newProduct);
    //
    //   notifyListeners();
    // }).catchError((error){
    //   throw error;
    // });



  }

  Future<void> updateProduct(String id, Product newProduct) async {
   final prodIndex = _items.indexWhere((element) => element.productId == id);
   if(prodIndex >= 0){
     final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
     await http.patch(Uri.parse(url), body: json.encode({
       'title':newProduct.productTitle,
       'description' : newProduct.productDescription,
       'imageUrl': newProduct.productImageUrl,
       'price' : newProduct.productPrice
     }));

     _items[prodIndex] = newProduct;
     notifyListeners();
   }else{
     print(prodIndex);
   }
  }

  Future<void> deleteProduct(String id) async{
    final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((element) => element.productId == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode >= 400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete the product');
    }
    existingProduct = null;
   // _items.removeWhere((element) => element.productId == id);

  }

}