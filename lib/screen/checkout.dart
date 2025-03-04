import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:royalmart/BottomNavigation/wishlist.dart';
import 'package:royalmart/General/AppConstant.dart';
import 'package:royalmart/StyleDecoration/styleDecoration.dart';
import 'package:royalmart/dbhelper/CarrtDbhelper.dart';
import 'package:royalmart/dbhelper/database_helper.dart';
import 'package:royalmart/model/AddressModel.dart';
import 'package:royalmart/model/CoupanModel.dart';
import 'package:royalmart/model/InvoiceModel.dart';
import 'package:royalmart/model/OrderDliverycharge.dart';
import 'package:royalmart/screen/deliveryinfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'ShowAddress.dart';
import 'ShowINVoiceIc1.dart';
import 'ShowInvoiceid2.dart';
import 'finalScreen.dart';

class CheckOutPage extends StatefulWidget {
  final UserAddress address;
  const CheckOutPage(this.address) : super();
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final DbProductManager dbmanager = new DbProductManager();
  final coupanController = TextEditingController();

  String name1;
  String email1;
  String mobile1;
  String gateway;
  String codp;
  String pin1;
  String city1;
  String address1;
  String address2;
  String user_name;
  double finalamount, calcutateAmount,checkamount,difference=0.0;
  bool discountval_flag =false;

  String sex1;
  String coupancode;
  String user_id1;
  String state1;
  String invoiceid;
  String razorpay_key;
  String deliveryfee='00.00';
  bool flag =true;

  Future<void> _gefreedelivery() async {
    final response = await http.get(Constant.base_url+'api/shipping.php?shop_id='+Constant.Shop_id);

    if (response.statusCode == 200) {

      final jsonBody = json.decode(response.body);
      DeliveryCharge user1 = DeliveryCharge.fromJson(jsonDecode(response.body));
      if(user1.success.toString()== "true" )
      {
        setState(() {
          gateway=user1.Gateway;
          codp=user1.COD;

          if(Constant.cityid.length>0){
            Onedayprice=double.parse(user1.fast_price);

            // finalamount=finalamount+Onedayprice;
            print('delivery charge ${finalamount }, $Onedayprice');
          }
          else{
            Onedayprice=0.0;
            print('delivery charge ${finalamount }, $Onedayprice');

          }


          fast_text=user1.fast_text;
          razorpay_key=user1.razorpay_key;
        });
        print(user1.COD);
        // print("user1.Min_Order");
        if(Constant.totalAmount<double.parse(user1.Min_Order)){
          setState(() {

            deliveryfee=(double.parse(user1.Fee)+Constant.shipingAmount).toString();
            // print(deliveryfee);
            // print("deliveryfee");


            finalamount=Constant.totalAmount+double.parse(user1.Fee)+Onedayprice;
            ;
            // print(finalamount);
            // print("finalamount");

          });
        }
        else{
          if(Constant.shipingAmount>0){
            deliveryfee=(double.parse("0.0")+Constant.shipingAmount).toString();
            finalamount=Constant.totalAmount+double.parse(user1.Fee)+Onedayprice;
          }
          else {
            deliveryfee = '0.0';
          }
        }


//        setState(() {
//          invoiceid=user.Invoice;
//
//        });

      }
      else {



      }

    } else
      throw Exception("Unable to generate Employee Invoice");
//    print("123  Unable to generate Employee Invoice");

  }

/*
  Future<void> getUserInfo() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    String name= pre.getString("name");
    String email= pre.getString("email");
    String mobile= pre.getString("mobile");
    String pin= pre.getString("pin");
    String city= pre.getString("city");
    String address= pre.getString("address");
    String sex= pre.getString("sex");
    String state=pre.getString("state");
    String userid=pre.getString("user_id");
    print(name);
    print(email);
    print(pin);

    this.setState(() {

      name1=name;
      email1= email;
      mobile1=mobile;
      pin1=pin;
      city1=city;
      address1=address;
      sex1=sex;
      state1=state;
      user_id1=userid;


    });
  }
*/
  SharedPreferences pre;
  Future<void> getUserInfo() async {
    pre = await SharedPreferences.getInstance();
    user_name= pre.getString("mobile");
    print(user_name+"userNAme");

    String email= pre.getString("email");
    String name= pre.getString("name");
//    String pin= pre.getString("pin");
//    String city= pre.getString("city");
//    String address= pre.getString("address");
    String sex= pre.getString("sex");
//    String state=pre.getString("state");
    String userid=pre.getString("user_id");


    this.setState(() {

      name1=widget.address.fullName;
      email1= widget.address.email;
      mobile1=widget.address.mobile;
      pin1=widget.address.pincode;
      city1=widget.address.city;
      address1=widget.address.address1;
      address2=widget.address.address2;
      sex1=sex;
      state1=widget.address.state;
      user_id1=userid;
      Constant.name=name;
      Constant.email=email;
      Constant.username=user_name;
      Constant.latitude=double.parse(widget.address.lat);
      Constant.longitude=double.parse(widget.address.lng);


    });
  }

  Razorpay razorpay;
  List<ProductsCart> prodctlist1=new List<ProductsCart>() ;

  @override
  void initState() {
    getUserInfo();

    super.initState();

    finalamount=Constant.totalAmount;
    calcutateAmount=Constant.totalAmount;
    _gefreedelivery();

    dbmanager.getProductList().then((usersFromServe) {
      if(this.mounted) {
        setState(() {
          prodctlist1 = usersFromServe;
          print(" Shipping ${prodctlist1[0].shipping}");
          print(" Shipping ${prodctlist1[0].shipping.length}");

          for(var i=0;i<prodctlist1.length;i++){
            Constant.shipingAmount= Constant.shipingAmount+prodctlist1[i].shipping.trim().length>1?double.parse(prodctlist1[i].shipping.trim()):0.0;
            print(" Shipping ${Constant.shipingAmount}");

          }


        });
      }

    });


    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }


  String orderid;
  String signature;
  String paymentId;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }
  void handlerPaymentSuccess(PaymentSuccessResponse response){
    print(response.orderId);
    print(response.signature);
    print(response.paymentId);
    // print(response.signature);
    setState(() {
      orderid=response.orderId;
      signature=response.signature;
      paymentId=response.paymentId;
    });
    _getInvoice1("ONLINE");
  }

  void handlerErrorFailure(PaymentSuccessResponse response){
    print("Pament error");
    print(response.orderId);
    print(response.signature);
    print(response.paymentId);
    showLongToast(' Payment Error');

  }

  void handlerExternalWallet(PaymentSuccessResponse response){
    print("External Wallet");
    showLongToast("External Wallet");
  }

  void openCheckout(){


//    var options1 = {
//      'key': 'rzp_live_y9LCkyj468leuC',
//      'amount': finalamount*100, //in the smallest currency sub-unit.
//      'name':Constant.name,
//      'order_id': invoiceid, // Generate order_id using Orders API
//      'description': 'Fine T-Shirt',
//      'prefill': {
//        'contact': mobile1,
//        'email': email1
//      }
//    };


//    rzp_live_vkeFphEQQ90LK1
    var options = {
      'key': razorpay_key,
      'amount': finalamount*100.0,
      "currency": "INR",
      'name': Constant.name,
      'description':prodctlist1[0].pname,
      'prefill': {'contact': mobile1, 'email': email1},
      'external': {
        'wallets': ['paytm']
      }
    };
/*     var options = {
      "key" : "[YOUR_API_KEY]",
      "amount" : "10000",
      "name" : "Sample App",
      "description" : "Payment for the some random product",
      "prefill" : {
        "contact" : "2323232323",
        "email" : "shdjsdh@gmail.com"
      },
      "external" : {
        "wallets" : ["paytm"]
      }
    };*/

    try{
      razorpay.open(options);

    }catch(e){
      print(e.toString());
    }

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home: Scaffold(

        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor:AppColors.tela,

          leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            "Checkout",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        body:Container(
          child: Builder(builder: (context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(
//                  Color:Colors.teal[50],

                  child: ListView(
                    children: <Widget>[

                      selectedAddressSection(),
                      standardDelivery(),
                      checkoutItem(),
                      priceSection()
                    ],
                  ),
                ),
                flex: 30,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    gateway=='no'?SizedBox(height: 35,):Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.checkoup_paybuttoncolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24))),
            ),
                              onPressed: () {
                                // _getInvoice1("UPI/QRCODE");

                                  openCheckout();

//                      Navigator.push(context,
//                          new MaterialPageRoute(builder: (context) => CheckOutPage()));
                              },

//                          padding: EdgeInsets.only(top: 12, left: 60, right: 60, bottom: 12),

                              child: Text(
                                "Pay Online", style: CustomTextStyle.textFormFieldMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),

                              ),
                            ),
                          ),
                          /*Container(
                            child: RaisedButton(
                              onPressed: () {
                                _getInvoice1("THROUGH ACCOUNTS");
//                      Navigator.push(context,
//                          new MaterialPageRoute(builder: (context) => CheckOutPage()));
                              },
                              color: AppColors.checkoup_paybuttoncolor,
//                          padding: EdgeInsets.only(top: 12, left: 60, right: 60, bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(24))),
                              child: Text(
                                "THROUGH ACCOUNTS", style: CustomTextStyle.textFormFieldMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),

                              ),
                            ),
                          ),*/
                        ],
                      ),

                    ),

                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),),
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 18, right: 20,),
                      child:  Card(

                        elevation: 0.0,
                        child: Row(
                          mainAxisAlignment:codp=='yes'? MainAxisAlignment.start: MainAxisAlignment.center,
                          children: <Widget>[

                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "\u{20B9} ${finalamount.toStringAsFixed(2)}", style: CustomTextStyle.textFormFieldMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),

                              ),
                            ),
                            codp=='yes'? Expanded(
                              child: Container(

                                margin: EdgeInsets.only(left: 10, right: 10,bottom: 10,top: 10),

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.checkoup_paybuttoncolor,
                                    padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(24))),
            ),
                                  onPressed: () {
                                      _getInvoice1("COD");
                                      setState(() {
                                        flag = false;
                                      });


//                      Navigator.push(context,
//                          new MaterialPageRoute(builder: (context) => CheckOutPage()));
                                  },

                                  child:flag? Text(
                                    "Cash on delivery", style: CustomTextStyle.textFormFieldMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),

                                  ):Center(child: CircularProgressIndicator()),
                                ),
                              ),
                            ):Row(),

                          ],
                        ),
                      ),


                    ),
                  ],
                ),
                flex: 12,
              )
            ],
          );
        }),),
      ),
    );
  }



  selectedAddressSection() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(

//              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),

          Text("Deliver TO :", style: TextStyle(color: Colors.black, fontSize: 18),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[


                ],
              ),
              createAddressText("Name: $name1", 16),
              createAddressText(address1!=null?address1+" "+address2:"address", 6),
              // createAddressText(address1!=null?address1:"address", 6),
              createAddressText(city1==null?'Banglore':'${city1}:${pin1} ', 6),
              createAddressText(state1!=null?"$state1":'Karnatka', 6),
              SizedBox(
                height: 6,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Mobile : ",
                      style: CustomTextStyle.textFormFieldMedium
                          .copyWith(fontSize: 12, color: Colors.grey.shade800)),
                  TextSpan(
                      text: mobile1!=null?mobile1:'9989898989',
                      style: CustomTextStyle.textFormFieldBold
                          .copyWith(color: Colors.black, fontSize: 12)),

                ]),
              ),

             /* Row(
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(left:0.0,top: 20.0,right: 0),
                      child: InkWell(
                        onTap: (){

                          showCalander();
                          // _showSelectionDialog(context);
                        },
                        child: Container(
                          // width: MediaQuery.of(context).size.width/1.5,
                          padding: const EdgeInsets.only(left:10.0,top: 0.0,right: 10),
                          margin: const EdgeInsets.only(left:0.0,top: 0.0,right: 0),


                          child:  Center(child:Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10,right: 10),
                                child: Text(
                                  textval.length>20?textval.substring(0,20)+"..": textval,

                                  overflow:TextOverflow.fade,
                                  // maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 12,color:AppColors.black,

                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child:Icon(Icons.expand_more, color: Colors.black,size: 30,)
                              )

                            ],
                          )  ),

                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                        ),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left:0.0,top: 20.0,right: 0),

                      child: InkWell(
                        onTap: (){

                          _displayDialog(context);
                          // _showSelectionDialog(context);
                        },
                        child: Container(

                          padding: const EdgeInsets.only(left:10.0,top: 0.0,right: 10),
                          margin: const EdgeInsets.only(left:0.0,top: 0.0,right: 0),
                          // width: MediaQuery.of(context).size.width/1.5,

                          child:  Center(child:Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10,right: 10),
                                child: Text(
                                  textval1.length>20?textval1.substring(0,20)+"..": textval1,

                                  overflow:TextOverflow.fade,
                                  // maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 12,color:AppColors.black,

                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child:Icon(Icons.expand_more, color: Colors.black,size: 30,)
                              )

                            ],
                          )  ),

                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                        ),
                      )
                  ),


                ],
              ),*/

              SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.grey.shade300,
                height: 1,
                width: double.infinity,
              ),
//              addressAction()
            ],
          ),
        ),
      ),
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: CustomTextStyle.textFormFieldMedium
            .copyWith(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  addressAction() {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(
            flex: 2,
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Edit / Change",
              style: CustomTextStyle.textFormFieldSemiBold
                  .copyWith(fontSize: 12, color: Colors.indigo.shade700),
            ),
            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 3,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          Spacer(
            flex: 3,
          ),
          TextButton(
            onPressed: () {},
            child: Text("Add New Address",
                style: CustomTextStyle.textFormFieldSemiBold
                    .copyWith(fontSize: 12, color: Colors.indigo.shade700)),
            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  /* standardDelivery() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border:
          Border.all(color: Colors.tealAccent.withOpacity(0.4), width: 1),
          color: Colors.tealAccent.withOpacity(0.2)),
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Radio(
            value: 1,
            groupValue: 1,
            onChanged: (isChecked) {},
            activeColor: Colors.tealAccent.shade400,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Standard Delivery",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "  Free Delivery",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                  color: Colors.black,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }*/

  checkoutItem() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: ListView.builder(
            itemBuilder: (context, position) {
              return checkoutListItem(position);
            },
            itemCount: WishlistState.prodctlist1.length>0? WishlistState.prodctlist1.length:0,
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.vertical,
          ),
        ),
      ),
    );
  }

  checkoutListItem(int position) {
    return Stack(
      children: <Widget>[

        Container(
//              padding: EdgeInsets.only(right: 8, top: 4),
          child: Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Text(WishlistState.prodctlist1[position].pname==null? 'name':WishlistState.prodctlist1[position].pname,
              maxLines: 2,
              softWrap: true,
              style:TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)
                  .copyWith(fontSize: 14),
            ),
          ),
        ),


        Container(
          margin: EdgeInsets.only(left: 10, right: 16, top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8, left: 0, top: 8, bottom: 8),
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.tela),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    color: Colors.blue.shade200,
                    image: DecorationImage(
                        fit: BoxFit.fill,

                        image: NetworkImage(Constant.Product_Imageurl+WishlistState.prodctlist1[position].pimage, )


                    )),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

//                      SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          // WishlistState.prodctlist1[position].pcolor!=null?  Text(
                          //   'COLOR: ${WishlistState.prodctlist1[position].pcolor}',
                          //   style:TextStyle( fontWeight: FontWeight.w400, color: Colors.black)
                          //       .copyWith(color: Colors.grey, fontSize: 14),
                          // ):Row(),
                          // WishlistState.prodctlist1[position].pcolor.length>0?   SizedBox(width: 20):Row(),

                          WishlistState.prodctlist1[position].pQuantity!=null? Text(
                            'Quantity: ${WishlistState.prodctlist1[position].pQuantity}',
                            style:TextStyle( fontWeight: FontWeight.w400, color: Colors.black)
                                .copyWith(color: Colors.grey, fontSize: 14),
                          ):Row(),
                        ],
                      ),


//                      SizedBox(height: 3),
//                      WishlistState.prodctlist1[position].psize!=null? Text(
//                        'Size: ${WishlistState.prodctlist1[position].psize}',
//                        style:TextStyle( fontWeight: FontWeight.w400, color: Colors.black)
//                            .copyWith(color: Colors.grey, fontSize: 14),
//                      ):Row(),


                      WishlistState.prodctlist1[position].shipping.length>0? Text(
                        'Shipping:  \u{20B9} ${WishlistState.prodctlist1[position].shipping}',
                        style:TextStyle( fontWeight: FontWeight.w400, color: Colors.black)
                            .copyWith(color: Colors.grey, fontSize: 14),
                      ):Row(),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              WishlistState.prodctlist1[position].pprice==null? '00.0':'\u{20B9} ${double.parse(WishlistState.prodctlist1[position].pprice).toStringAsFixed(2)}', style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w700,
                            )
                                .copyWith(color: Colors.green),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 100,
              )
            ],
          ),
        ),

      ],
    );


  }

  priceSection() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
//          decoration: BoxDecoration(
//              borderRadius: BorderRadius.all(Radius.circular(4)),
//              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Flexible(
//                    child: Padding(
//                      padding: EdgeInsets.only(right: 10.0),
//                      child:  TextFormField(
//                        controller:coupanController,
//                        keyboardType: TextInputType.number,
//                        validator: (String value){
//                          if(value.isEmpty){
//                            return " Apply Coupon Code";
//                          }
//                        },
//                        decoration: const InputDecoration(
//                            hintText: "Apply Coupon Code"),
////                        enabled: !_status,
//                      ),
//                    ),
////                    flex: 2,
//                  ),
//
//
//                  Expanded(
//                    child: Padding(
//                      padding: EdgeInsets.only(right: 0.0),
//                      child: Container(
//                          child:  Center(
//                            child: RaisedButton(
//                              child: new Text("Apply  Coupon"),
//                              textColor: Colors.white,
//                              color: AppColors.telamoredeep,
//                              onPressed: () {
//
////
//                              },
//                              shape: new RoundedRectangleBorder(
//                                  borderRadius: new BorderRadius.circular(20.0)),
//                            ),
//                          )),
//                    ),
////                    flex: 2,
//                  ),
//                ],
//              ),



              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child:  TextFormField(
                        controller:coupanController,
                        keyboardType:TextInputType.text,
                        validator: (String value){
                          if(value.isEmpty){
                            return " Apply Coupon Code";
                          }
                        },
                        decoration: const InputDecoration(
                            hintText: "Apply Coupon Code"),
//                        enabled: !_status,
                      ),
                    ),
//                    flex: 2,
                  ),


                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 0.0),
                      child: Container(
                          child:  Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                primary: AppColors.checkoup_paybuttoncolor,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(20.0)),
                              ),
                              child: new Text("Apply "),

                              onPressed: () {
                                if(coupanController.text.length>4) {
                                  getCoupan(coupanController.text).then((usersFromServe) {
                                    setState(() {
                                      Coupan coupan = usersFromServe;
                                      print(coupan.status);
                                      if(coupan.status=="true"){
                                        coupancode=coupanController.text;

                                        // print(coupan.data.couponCodes[0].userId+ "     .....user_id");
                                        // print(coupan.data.couponCodes[0].userId.length);


                                        String name=Constant.username;
                                        String  usernamevalue=coupan.data.couponCodes[0].userId;


                                        int length=coupan.data.couponCodes[0].userId.length;
                                        if(length>3) {

                                          print('${name.contains(usernamevalue)}+rahul');
                                          print(usernamevalue);
                                          print(name);
//                                            if('${Constant.username}'=='${coupan.data.couponCodes[0].userId}'){
                                          if(name.contains(usernamevalue)){

                                            if(coupan.data.couponCodes[0].type=="per"){
//                                              print("rahul");
                                              String val=calDiscount(calcutateAmount.toString(),coupan.data.couponCodes[0].val);
//                                         print(val);
                                              setState(() {
                                                difference=calcutateAmount-double.parse(val);
                                                if(difference>double.parse(coupan.data.couponCodes[0].maxVal)){
                                                  setState(() {
                                                    difference=double.parse(coupan.data.couponCodes[0].maxVal);
                                                    discountval_flag=true;
                                                    print(discountval_flag);
                                                    calcutateAmount=calcutateAmount-difference;
                                                    finalamount= finalamount-difference;

                                                  });
                                                }


                                              });


                                            }
                                            else{

                                              setState(() {
                                                // print(Constant.totalAmount);
                                                // print(double.parse(coupan.data.couponCodes[0].val));
                                                // print(Constant.totalAmount-double.parse(coupan.data.couponCodes[0].val));

                                                difference= double.parse(coupan.data.couponCodes[0].val);
                                                discountval_flag=true;
                                                print("fix");
                                                calcutateAmount=calcutateAmount-difference;
                                                finalamount= finalamount-difference;

                                                print(difference);
                                              });

                                            }

                                          }
                                          else{
                                            showLongToast("Invalied Or Expire Coupon");

                                          }
                                        }
                                        else{
                                          // print('${Constant.username==coupan.data.couponCodes[0].userId}+rahul123');

                                          if(coupan.data.couponCodes[0].type=="per"){
                                            // print(" calculated ${calcutateAmount.toString()}");

                                            String val=calDiscount(calcutateAmount.toString(),coupan.data.couponCodes[0].val);
                                            print(val);

                                            setState(() {
                                              // difference=calcutateAmount-double.parse(val);
                                              // discountval_flag=true;

                                              // print(discountval_flag);
                                              // print(difference);

                                              if(difference>double.parse(coupan.data.couponCodes[0].maxVal)){

                                                setState(() {
                                                  difference=double.parse(coupan.data.couponCodes[0].maxVal);
                                                  discountval_flag=true;
                                                  calcutateAmount=calcutateAmount-difference;
                                                  finalamount= finalamount-difference;

                                                });
                                              }
                                              else{
                                                calcutateAmount=calcutateAmount-difference;
                                                finalamount= finalamount-difference;

                                              }



                                            });
                                          }
                                          else{
                                            setState(() {
                                              difference= double.parse(coupan.data.couponCodes[0].val);
                                              discountval_flag=true;
                                              calcutateAmount=calcutateAmount-difference;
                                              finalamount= finalamount-difference;

                                              print(difference);

                                            });

                                          }


                                        }



                                        print(coupan.data.couponCodes[0].userId);
                                      }

                                      else{
                                        showLongToast("Invalied Or Expire Coupon");
                                      }
                                    });
                                  });
                                }
                                else{
                                  showLongToast("Invalied Or Expire Coupon");
                                }



//
                              },

                            ),
                          )),
                    ),
//                    flex: 2,
                  ),
                ],
              ),


              SizedBox(
                height: 25,
              ),
              Text(
                "PRICE DETAILS",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Total MRP",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "\u{20B9} ${calcutateAmount.toStringAsFixed(2)}",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Order Total",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "${Constant.itemcount}",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Delivery Charges",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(deliveryfee!=null?deliveryfee:
                    "00.00",
                      style: CustomTextStyle.textFormFieldSemiBold
                          .copyWith(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                ],
              ),


              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: CustomTextStyle.textFormFieldSemiBold
                        .copyWith(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    "${finalamount.toStringAsFixed(2)}",
                    style: CustomTextStyle.textFormFieldMedium
                        .copyWith(color: Colors.black, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  createPriceItem(String key, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            value,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }



// String invoicemenual;
  Future _getInvoice1(String paymode) async{

    var map = new Map<String, dynamic>();
    map['name']=name1;
    map['mobile']=user_name;
    map['email']= email1;
    map['address']= address1;
    map['pincode']= pin1;
    map['city']= city1;
    map['invoice_total']=calcutateAmount.toString();
    map['notes']= 'ghy';
    map['shop_id']= Constant.Shop_id.toString();
    map['PayMode']= paymode;
    map['user_id']= "user_id";
    map['shipping']= deliveryfee;
    map['mv']= prodctlist1[0].mv.toString();
    map['lat']=Constant.latitude.toString();
    map['lng']=Constant.longitude.toString();
    map['coupon']=coupancode!=null?coupancode:"";
    map['couponAmount']=difference.toString();
    map['adate'] =textval == "Select Date" || textval.isEmpty ? '':(Jiffy(textval, "dd/MM/yyyy").format("yyyy-MM-dd")).toString();
    map['atime'] =textval1 == "Select Time" ||textval1.isEmpty ? '' : textval1;
    map['fast_price']=Onedayprice!=null?Onedayprice.toString():"0.0";
    final response = await http.post(Constant.base_url+'api/order.php',body:map);

    if (response.statusCode == 200) {

//      final jsonBody = json.decode(response.body);
      Invoice1 user = Invoice1.fromJson(jsonDecode(response.body));
      // print("123"+user.Invoice);
      if(user.success.toString()== "true" )
      {
        print("12345"+user.Invoice);


        _uploadProducts(user.Invoice,paymode);
        setState(() {
          invoiceid=user.Invoice;

        });

      }
      else {
        showLongToast('Invoice is not generated');

      }

    } else
      throw Exception("Unable to generate Employee Invoice");
//    print("123  Unable to generate Employee Invoice");

  }


  Future _uploadProducts(String invoice, String paytype) async {
    // int pmv= prodctlist1[0].mv;
    //
    // print("Pmv12   "+pmv.toString()+ "   "+prodctlist1.length.toString());
    for (int i = 0; i <prodctlist1.length; i++) {


      /*     if(pmv==prodctlist1[i].mv) {
        setState(() {
          pmv=prodctlist1[i].mv;

          print("Pmv"+pmv.toString());
        });*/

      // print("WishlistState.prodctlist1[i].pimage");
      // print(WishlistState.prodctlist1[i].pimage);

      var map = new Map<String, dynamic>();
      // print(invoice);
      // print(WishlistState.prodctlist1[i].pid);
      // print(WishlistState.prodctlist1[i].pname);
      // print(WishlistState.prodctlist1[i].pQuantity);
      // print(WishlistState.prodctlist1[i].costPrice);
      // print(WishlistState.prodctlist1[i].discount);
      // print(WishlistState.prodctlist1[i].discountValue);
      // print(WishlistState.prodctlist1[i].adminper);
      // print(WishlistState.prodctlist1[i].adminpricevalue);
      // print(WishlistState.prodctlist1[i].cgst);
      // print(WishlistState.prodctlist1[i].sgst);
      // print(WishlistState.prodctlist1[i].pcolor);
      // print(WishlistState.prodctlist1[i].pimage);

      map['invoice_id'] = invoice;
      map['product_id'] = prodctlist1[i].pid;
      map['product_name'] = prodctlist1[i].pname;
      map['quantity'] = prodctlist1[i].pQuantity.toString();
      map['price'] = (int.parse(prodctlist1[i].costPrice) *
          prodctlist1[i].pQuantity).toString();
      map['user_per'] = prodctlist1[i].discount;
      map['user_dis'] =
          (double.parse(prodctlist1[i].discountValue) *
              prodctlist1[i].pQuantity)
              .toStringAsFixed(2)
              .toString();
      map['admin_per'] = prodctlist1[i].adminper;
      map['admin_dis'] = prodctlist1[i].adminpricevalue;
      map['shop_id'] = Constant.Shop_id;
      map['cgst'] = prodctlist1[i].cgst;
      map['sgst'] = prodctlist1[i].sgst;
      map['variant'] =
      prodctlist1[i].varient == null ? " " : WishlistState
          .prodctlist1[i].varient;
      map['color'] = prodctlist1[i].pcolor == null ||
          prodctlist1[i].pcolor.isEmpty
          ? ""
          : prodctlist1[i].pcolor;
      map['size'] = prodctlist1[i].psize == null ||
          prodctlist1[i].psize.isEmpty
          ? ""
          : prodctlist1[i].psize;
      map['refid'] = "0";
      map['image'] = prodctlist1[i].pimage;
      map['prime'] = "0";
      map['mv'] = prodctlist1[i].mv.toString();
      final response = await http.post(
          Constant.base_url + 'api/order.php', body: map);

      try {
        // print(response);
        if (response.statusCode == 200) {

//        final jsonBody = json.decode(response.body);
          ProductAdded1 user = ProductAdded1.fromJson(
              jsonDecode(response.body));

          setState(() {

            if (user.success.toString() == "true" &&
                i == (prodctlist1.length-1 ) &&
                paytype == 'ONLINE') {
              showLongToast(' Your  order is  sucessfull');
              dbmanager.deleteallProducts();
              Constant.itemcount = 0;
              Constant.carditemCount = 0;
              cartItemcount(Constant.carditemCount);
              pre.setString("mvid","");
              _afterPayment(orderid,signature,paymentId);

              // openCheckout();

              // Navigator.push(context,
              //   MaterialPageRoute(builder: (context) => ShowInVoiceId(user.Invoice)),);
            }

            else if (user.success.toString() == "true" &&
                i == (prodctlist1.length-1) &&
                paytype == 'COD') {
              showLongToast(' Your  order is  sucessfull');
              dbmanager.deleteallProducts();
              Constant.itemcount = 0;
              Constant.carditemCount = 0;
              cartItemcount(Constant.carditemCount);
              pre.setString("mvid","");

              Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ShowInVoiceId(user.Invoice)),);
            }
            else if (user.success.toString() == "true" &&
                i == (prodctlist1.length-1) &&
                paytype == 'UPI/QRCODE') {
              showLongToast(' Your  order is  sucessfull');
              dbmanager.deleteallProducts();
              Constant.itemcount = 0;
              Constant.itemcount = 0;
              Constant.itemcount = 0;
              pre.setString("mvid","");

//
              Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ShowInVoiceId1(user.Invoice)),);
            }
            else if (user.success.toString() == "true" &&
                i == (prodctlist1.length-1) &&
                paytype == 'THROUGH ACCOUNTS') {
              showLongToast(' Your  order is  sucessfull');
              dbmanager.deleteallProducts();
              Constant.itemcount = 0;
              Constant.itemcount = 0;
              pre.setString("mvid","");

//          openCheckout();
              Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ShowInVoiceId2(user.Invoice)),);
            }
            else {
              // showLongToast(' Somting went wrong');
            }

          });

        }
      }
      catch (Exception) {
        throw Exception("Unable to uplod product detail");
      }
      // }


      /*  else{
        setState(() {

          pmv=prodctlist1[i].mv;

          // print(' set state after if ${pmv}'+i.toString());
        });
          int p;
        for( p=0;p<i;p++){
          setState(() {
            prodctlist1.removeAt(0);
            print("list length"+prodctlist1.length.toString());

          });

        }

        if(p==i){

          _getInvoice1(paytype);
          break;


        }

      }*/





    }




  }

  void showLongToast(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future _afterPayment(String orderid,String signature,String paymentId) async {
    var map = new Map<String, dynamic>();

    print(mobile1);
    print(Constant.name);
    print(user_name);
    print(paymentId);
    print(orderid);
    print(signature);
    print(Constant.email);
    print(user_name);
    print(finalamount.toString());
    print(invoiceid);


    map['phone']=mobile1;
    map['name']=Constant.name;
    map['razorpay_payment_id']=paymentId!=null?paymentId:"";
    map['razorpay_order_id']= orderid!=null?orderid:"";
    map['razorpay_signature']= signature!=null?signature:"";
    map['email']= Constant.email;
    map['username']= user_name;
    map['price']= finalamount.toString();
    map['purpose']= invoiceid;
    final response = await http.post(
        Constant.base_url + 'verifyUser.php', body: map);

    try{
      if (response.statusCode == 200) {
        print("Your  order is  sucessfull");
        showLongToast(' Your  order is  sucessfull');
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => ShowInVoiceId(invoiceid)),);
      }


    }catch(Exception){}

  }
  bool checkBoxValue=false;
  double Onedayprice=0.00;
  String fast_text="";
  standardDelivery() {



//add this below the minimum fee
//     Onedayprice=double.parse(user1.fast_price);
//     fast_text=user1.fast_text;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border:
          Border.all(color: Colors.tealAccent.withOpacity(0.4), width: 1),
          color: Colors.tealAccent.withOpacity(0.2)),
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
           Checkbox(
              activeColor: AppColors.tela,
              value: checkBoxValue,
              onChanged: (bool newValue) {
                setState(() {
                  checkBoxValue = newValue;
                  print(checkBoxValue);
                  if(checkBoxValue){
                    finalamount = finalamount+Onedayprice;
                  }
                  else{
                    print(finalamount);
                    finalamount = finalamount-Onedayprice;
                  }

                  // checkBoxValue?finalamount+Onedayprice:finalamount-Onedayprice;

                });
              }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                fast_text,
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "${Onedayprice} \u{20B9} charges",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                  color: Colors.black,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }



  String calDiscount(String byprice, String discount2) {

    String returnStr;
    double discount = 0.0;
    returnStr = discount.toString();
    double byprice1= double.parse(byprice);
    double discount1= double.parse(discount2);

    discount = (byprice1 - (byprice1 * discount1) / 100.0);

    returnStr = discount.toStringAsFixed(2);
    return returnStr;
  }




  String textval="Select Date";
  String textval1="Select Time";


  _displayDialog(BuildContext context) async {
    String formattedDate1 = DateFormat('dd/MM/yyyy ').format(DateTime.now());
    var now = DateTime.now();
    print(DateFormat('HH').format(now));
    dynamic currentTime = await DateFormat('HH').format(now);
    // dynamic currentTime = await DateFormat.jm().format(DateTime.now());
    String compair= currentTime.toString().substring(0,2).replaceAll(":", "").trim();
    // print(compair);
    // print(formattedDate1);
    // print(compair);
    List<String>time;


    if(formattedDate1==textval) {

      // switch (int.parse(compair)) {
      //   case 9:
      //     time = ["12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 10:
      //     time = ["12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 11:
      //     time = ["11am to 12am", "12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 12:
      //     time = ["12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //     case 1:
      //     time = ["12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 2:
      //     time = [ "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 3:
      //     time = [ "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 4:
      //     time = [ "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 5:
      //     time = [ "4pm to 6pm", "6pm to 8pm"];
      //     break;
      //   case 6:
      //     time = ["6pm to 8pm"];
      //     break;
      //   case 7:
      //     time = ["6pm to 8pm"];
      //     break;
      //   case 8:
      //     time = ["No time is avaliable"];
      //     break;
      // }
      if (int.parse(compair)< 10) {
        time = ["10am to 12am", "12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      }
      else if (int.parse(compair)>9 && int.parse(compair) < 12) {

        time = ["12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      }
      else if (int.parse(compair) > 11 && int.parse(compair) < 14) {

        time = [ "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];
      }
      else if (int.parse(compair) >13 && int.parse(compair) < 16) {
        time = [ "4pm to 6pm", "6pm to 8pm"];
      }
      else if (int.parse(compair) > 15 && int.parse(compair) < 18) {
        time = ["6pm to 8pm"];
      }
      else
        time = ["No slot avaliable today"];
    }

    else{

      time = ["10am to 12am","12am to 2pm", "2pm to 4pm", "4pm to 6pm", "6pm to 8pm"];

    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable:true,
            title: Text('Select Time'),
            content: Container(
              width: double.maxFinite,
              height: time.length*50.0,
              child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: time.length == null
                      ? 0
                      : time.length,
                  itemBuilder: (BuildContext context, int index) {
                    return
                      Container(
                        width: time[index]!=0?130.0:230.0,
                        color: Colors.white,
                        margin: EdgeInsets.only(right: 10),

                        child: InkWell(
                          onTap: () {
                            setState(() {
                              textval1=time[index];Navigator.pop(context);


                            });

                          },
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10,right: 10,top:10,bottom: 10),
                                    child: Text(
                                      time[index],
                                      overflow:TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 15,color:AppColors.black,

                                      ),
                                    ),
                                  ),


                                ],
                              ),
                              Divider(

                                color: AppColors.black,
                              ),





                            ],
                          ),
                        ),







                      )
                    ;
                  }),
            ),
            actions: <Widget>[
              TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 30))))) {
      return true;
    }
    return false;
  }
  DateTime selectedDate;

  showCalander(){

    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      selectableDayPredicate: _decideWhichDayToEnable,
    ).then((date){
      setState(() {

        selectedDate=date;
        String formattedDate = DateFormat('dd/MM/yyyy ').format(selectedDate!=null?selectedDate:DateTime.now());
        textval=formattedDate;

        print(formattedDate);
      });
    });
  }

}