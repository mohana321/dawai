import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royalmart/Auth/signin.dart';
import 'package:royalmart/BottomNavigation/wishlist.dart';
import 'package:royalmart/General/AppConstant.dart';
import 'package:royalmart/dbhelper/CarrtDbhelper.dart';
import 'package:royalmart/dbhelper/database_helper.dart';
import 'package:royalmart/model/CategaryModal.dart';
import 'package:royalmart/model/productmodel.dart';
import 'package:royalmart/screen/SearchScreen.dart';
import 'package:royalmart/screen/detailpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Sbcategory extends StatefulWidget {
  final String  title;
  final String id;
  const Sbcategory(this.title,this.id) : super();
  @override
  _Sbcategory createState() => _Sbcategory();
}

class _Sbcategory extends State<Sbcategory> {



  double sgst1,cgst1 ,dicountValue,admindiscountprice;

  bool product=false;
  List<Products> products = List();
  bool flag= true;
  double mrp,totalmrp=000;
  int _count =1;
  List<Products> products1 = List();

  String textval="Select varient";

  int _current=0;
  List<Categary> list1 = List();
  void gatinfoCount() async {
    SharedPreferences pref= await SharedPreferences.getInstance();

    int Count=pref.getInt("itemCount");
    setState(() {
      if(Count==null){
        Constant.carditemCount=0;
      }else {
        Constant.carditemCount = Count;
      }
//      print(Constant.carditemCount.toString()+"itemCount");
    });



  }

  @override
  void initState() {
    super.initState();
    gatinfoCount();

    DatabaseHelper.getData(widget.id).then((usersFromServe){
      if(this.mounted) {
        setState(() {
          list1 = usersFromServe;
          if(list1.length==0)
          {
            flag=false;

          }
          print(list1.length);

        });    }     });


    getlist(countval);

    _scrollController.addListener(() {
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
        setState(() {
          countval=countval+10;
          getlist(countval);
        });

      }

    });


  }

  int countval=0;
  ScrollController _scrollController= new ScrollController();

  getlist(int lim){

    catby_productData(widget.id,lim.toString()).then((usersFromServe){
      setState(() {
        products1.addAll(usersFromServe);
        if(products1.length==0){
          product=true;
          print(product);
        }

      });
    });


  }

  @override
  void dispose() {
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tela,
        leading: Padding(padding: EdgeInsets.only(left: 0.0),
            child:InkWell(
              onTap: (){
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  SystemNavigator.pop();
                }
              },

              child: Icon(
                Icons.arrow_back,size: 30,
                color: Colors.white,
              ),

            )
        ),



        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(widget.title.isEmpty?"Products":widget.title,
                  maxLines: 2,

                  // overflow:TextOverflow.ellipsis ,
                  style: TextStyle(color: AppColors.white),),
              ),
            ),


            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserFilterDemo()),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(Icons.search,color: Colors.white,size: 30,),
                      ),
//                    showCircle(),
                    ],
                  ),

                ),
                SizedBox(width: 12,),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WishList()),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 13),
                        child: Icon(Icons.add_shopping_cart,color: Colors.white,),
                      ),
                      showCircle(),
                    ],
                  ),
                )
              ],
            ),

          ],
        ),





      ),


      // Navigator.push(context, MaterialPageRoute(builder: (context) => Sbcategory(cat.pCats, i)),);
      body: Container(
        height: double.infinity,
        child: flag?list1.length>0?Container(

        // color: Colors.black,
          child: GridView.builder(
            physics:ClampingScrollPhysics() ,
            controller: new ScrollController(keepScrollOffset: false),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 10, right: 10,top: 10),

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:  2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,

              childAspectRatio: 16/6.5,

            ),
            itemBuilder: (context, index) {
              Categary item = list1[index];
              return InkWell(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Screen2(item.pcatId,item.pCats)),);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Sbcategory(item.pCats,item.pcatId)),);

                },
                child: Card(
                  elevation: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.tela,width: 1.5),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image:item.img.length>0? NetworkImage(Constant.base_url + "manage/uploads/p_category/" + item.img,):AssetImage("assets/images/logo.png"),
                              )
                          ),
                          margin: EdgeInsets.only(left: 5,right: 10),
                          /*  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: new SizedBox(
                                        width: 40.0,
                                        height: 40.0,
                                        child:item.img.length>0?Image.network(Constant.base_url + "manage/uploads/p_category/" + item.img, fit: BoxFit.fill):Image.asset("assets/images/logo.png"),
                                      ),
                                    ),
                                  ),*/
                        ),
                        Expanded(

                          child: Text(item.pCats,
                            maxLines: 2,
                            style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700, letterSpacing: 1.5,color: AppColors.darkGray),),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: list1.length == null
                ? 0
                : list1.length,
          )):Center(child: CircularProgressIndicator()):

      !product?products1.length>0?Column(
        children: [
          Expanded(
            child: Container(

                child:
                /*GridView.count(
                  controller: _scrollController,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  padding: EdgeInsets.only(top: 8, left: 6, right: 6, bottom: 0),
                  children: List.generate(products1.length, (index) {
                    return Container(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProductDetails(products1[index])),
                            );                                      },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: (MediaQuery.of(context).size.width / 2 - 14),
                                width: double.infinity,
                                child: products1[index].img!=null
                                    ?Image.network(Constant.Base_Imageurl+products1[index].img,fit: BoxFit.fill,)
                          */
                /*      CachedNetworkImage
                                  (
                                  fit: BoxFit.cover,
                                  imageUrl:Constant.Base_Imageurl+products1[index].img,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()
                                  ),
                                  errorWidget: (context, url, error) => new Icon(Icons.error),
                                )*/

                /*
                                    :Image.asset("assets/images/logo.png",fit:BoxFit.fill),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: ListTile(
                                  title: Text(
                                    products1[index].productName,
                                    overflow:TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,color:AppColors.telamoredeep,   fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0, bottom: 1),
                                            child: Text('\u{20B9} ${calDiscount(products1[index].buyPrice,products1[index].discount)}', style: TextStyle(
                                              color: AppColors.sellp,
                                              fontWeight: FontWeight.w700,
                                            )),
                                          ),
                                          Expanded(
                                            child: Text('(\u{20B9} ${products1[index].buyPrice})',
                                              overflow:TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.italic,
                                                  color: Theme.of(context).accentColor,
                                                  decoration: TextDecoration.lineThrough
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),*/

                ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  primary: false,
                  scrollDirection: Axis.vertical,
                  itemCount:products1.length,

                  itemBuilder: (BuildContext context, int index) {


                    return
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 6,bottom: 6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(16))),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(products1[index])),);
                              },
                              child: Container(

                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(14)),
                                          color: Colors.blue.shade200,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,

                                            image: products1[index].img!=null?NetworkImage(Constant.Product_Imageurl+products1[index].img ):AssetImage("assets/images/logo.png"),


                                          )),
                                    ),

                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(


                                              child:
                                              Text(products1[index].productName==null? 'name':products1[index].productName,

                                                overflow: TextOverflow.fade,
                                                style:TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black)
                                                    .copyWith(fontSize: 14),
                                              ),

                                            ),
                                            SizedBox(height: 6),

                                            Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2.0, bottom: 1),
                                                  child: Text('\u{20B9} ${calDiscount(products1[index].buyPrice,products1[index].discount)} ${products1[index].unit_type!=null?products1[index].unit_type:""}', style: TextStyle(
                                                    color: AppColors.sellp,
                                                    fontWeight: FontWeight.w700,
                                                  )),
                                                ),
                                                SizedBox(width: 20,),
                                                Expanded(
                                                  child: Text('(\u{20B9} ${products1[index].buyPrice})',
                                                    overflow:TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontStyle: FontStyle.italic,
                                                        color: AppColors.mrp,
                                                        decoration: TextDecoration.lineThrough
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),

                                            products1[index].p_id==null?Container(): Padding(
                                                padding: const EdgeInsets.only(left:6.0,top: 8.0),
                                                child: InkWell(
                                                  onTap: (){

                                                    _displayDialog(context,products1[index].productIs,index);
                                                    // _showSelectionDialog(context);
                                                  },
                                                  child: Container(

                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey)
                                                    ),

                                                    width: MediaQuery.of(context).size.width/2,
                                                    padding: const EdgeInsets.only(left:5.0,top: 0.0,right:5.0,),
                                                    margin: const EdgeInsets.only(top: 5.0,),



                                                    child:  Center(child:Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10,right: 0),
                                                          child: Text(
                                                            // textval.length>15?textval.substring(0,15)+"..": textval,
                                                            products1[index].youtube.length>1? products1[index].youtube.length>15?products1[index].youtube.substring(0,15)+"..":products1[index].youtube: textval,

                                                            overflow:TextOverflow.fade,
                                                            // maxLines: 2,
                                                            style: TextStyle(
                                                              fontSize: 15,color:AppColors.black,

                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding: EdgeInsets.only(left: 0),
                                                            child:Icon(Icons.expand_more, color: Colors.black,size: 30,)
                                                        )

                                                      ],
                                                    )  ),


                                                  ),
                                                )
                                            ),


                                            Container(
                                              margin: EdgeInsets.only(left: 0.0,right: 8),
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    SizedBox(width: 0.0,height: 10.0,),

                                                    Container(
                                                      margin: EdgeInsets.only(left: 0.0,right: 10),
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            SizedBox(width: 0.0,height: 10.0,),

                                                            Container(
                                                              alignment:
                                                              Alignment.bottomCenter,
                                                              margin: EdgeInsets.only(
                                                                  left: 0.0, right: 10),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                                  children: <Widget>[
                                                                    Card(
                                                                      color:
                                                                      AppColors.white,
                                                                      elevation: 0.0,
                                                                      shape: RoundedRectangleBorder(
                                                                        side: BorderSide(
                                                                          color: AppColors
                                                                              .tela,
                                                                        ),
                                                                        borderRadius: BorderRadius.all(Radius.circular(15),),
                                                                      ),
                                                                      clipBehavior:
                                                                      Clip.antiAlias,
                                                                      child: Padding(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(4.0),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                          children: <
                                                                              Widget>[
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                print(products1[
                                                                                index]
                                                                                    .count);
                                                                                if (products1[index].count !=
                                                                                    "1" &&
                                                                                    int.parse(products1[index].count) >
                                                                                        1) {
                                                                                  setState(
                                                                                          () {
//                                                                                _count++;

                                                                                        String
                                                                                        quantity =
                                                                                            products1[index].count;
                                                                                        print(int.parse(
                                                                                            products1[index].moq));
                                                                                        int totalquantity =
                                                                                            int.parse(quantity) -
                                                                                                int.parse(products1[index].moq);
                                                                                        products1[index].count =
                                                                                            totalquantity.toString();
                                                                                      });
                                                                                }

//
                                                                              },
                                                                              child: Container(
                                                                                  height: 20,
                                                                                  width: 20,
                                                                                  child: Material(
                                                                                    color: AppColors
                                                                                        .white,
                                                                                    elevation:
                                                                                    0.0,
                                                                                    shape:
                                                                                    RoundedRectangleBorder(
                                                                                      side:
                                                                                      BorderSide(
                                                                                        color:
                                                                                        Colors.white,
                                                                                      ),
                                                                                      borderRadius:
                                                                                      BorderRadius.all(
                                                                                        Radius.circular(17),
                                                                                      ),
                                                                                    ),
                                                                                    clipBehavior:
                                                                                    Clip.antiAlias,
                                                                                    child: InkWell(
                                                                                        onTap: () {
                                                                                          print(products1[index].count);
                                                                                          if (products1[index].count != "1") {
                                                                                            setState(() {
//                                                                                _count++;

                                                                                              String quantity = products1[index].count;
                                                                                              print(int.parse(products1[index].moq));
                                                                                              int totalquantity = int.parse(quantity) - int.parse(products1[index].moq);
                                                                                              products1[index].count = totalquantity.toString();
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.only(
                                                                                            top: 8.0,
                                                                                          ),
                                                                                          child: Icon(
                                                                                            Icons.maximize,
                                                                                            size: 20,
                                                                                            color: AppColors.tela,
                                                                                          ),
                                                                                        )),
                                                                                  )),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(
                                                                                  top: 0.0,
                                                                                  left:
                                                                                  15.0,
                                                                                  right:
                                                                                  8.0),
                                                                              child: Center(
                                                                                child: Text(
                                                                                    products1[index].count !=
                                                                                        null
                                                                                        ? products1[index].count ==
                                                                                        "1"
                                                                                        ? "1"
                                                                                        : '${products1[index].count}'
                                                                                        : '$_count',
                                                                                    style: TextStyle(
                                                                                        color: AppColors
                                                                                            .tela,
                                                                                        fontSize:
                                                                                        15,
                                                                                        fontFamily:
                                                                                        'Roboto',
                                                                                        fontWeight:
                                                                                        FontWeight.bold)),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                                margin: EdgeInsets
                                                                                    .only(
                                                                                    left:
                                                                                    3.0),
                                                                                height: 20,
                                                                                width: 20,
                                                                                child:
                                                                                Material(
                                                                                  color: AppColors
                                                                                      .white,
                                                                                  elevation:
                                                                                  0.0,
                                                                                  shape:
                                                                                  RoundedRectangleBorder(
                                                                                    side:
                                                                                    BorderSide(
                                                                                      color:
                                                                                      Colors.white,
                                                                                    ),
                                                                                    borderRadius:
                                                                                    BorderRadius.all(
                                                                                      Radius.circular(
                                                                                          17),
                                                                                    ),
                                                                                  ),
                                                                                  clipBehavior:
                                                                                  Clip.antiAlias,
                                                                                  child:
                                                                                  InkWell(
                                                                                    onTap:
                                                                                        () {
                                                                                      if (int.parse(products1[index].count) <=
                                                                                          int.parse(products1[index].quantityInStock)) {
                                                                                        setState(() {
//                                                                                _count++;

                                                                                          String quantity = products1[index].count;
                                                                                          int totalquantity = int.parse(quantity) + 1;

                                                                                          // int totalquantity=int.parse(quantity=="1"?"0":quantity)+int.parse(products1[index].moq);
                                                                                          products1[index].count = totalquantity.toString();
                                                                                        });
                                                                                      } else {
                                                                                        showLongToast('Only  ${products1[index].count}  products in stock ');
                                                                                      }
                                                                                    },
                                                                                    child:
                                                                                    Icon(
                                                                                      Icons.add,
                                                                                      size:
                                                                                      20,
                                                                                      color:
                                                                                      AppColors.tela,
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // SizedBox(width: 25,),
                                                                  ]),
                                                            ),


                                                          ]
                                                      ) ,
                                                    ),
                                                    // SizedBox(width: 25,),

                                                    Container(
                                                        margin: EdgeInsets.only(left: 5.0),
                                                        height: 40,
                                                        width:60,

                                                        child:
                                                        Card(

                                                          elevation: 0.0,
                                                          shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                              color: AppColors.tela,
                                                            ),
                                                            borderRadius: BorderRadius.all(Radius.circular(15),),
                                                          ),


                                                          clipBehavior: Clip.antiAlias,
                                                          child: InkWell(
                                                            onTap: () {
                                                              if(Constant.isLogin){


                                                                String  mrp_price=calDiscount(products1[index].buyPrice,products1[index].discount);
                                                                totalmrp= double.parse(mrp_price);


                                                                double dicountValue=double.parse(products1[index].buyPrice)-totalmrp;
                                                                String gst_sgst=calGst(mrp_price,products1[index].sgst);
                                                                String gst_cgst=calGst(mrp_price,products1[index].cgst);

                                                                String  adiscount=calDiscount(products1[index].buyPrice,products1[index].msrp!=null?products1[index].msrp:"0");

                                                                admindiscountprice=(double.parse(products1[index].buyPrice)-double.parse(adiscount));



                                                                String color="";
                                                                String size="";
                                                                _addToproducts(products1[index].productIs,products1[index].productName,products1[index].img,int.parse(mrp_price),int.parse(products1[index].count),color,size,products1[index].productDescription,gst_sgst,gst_cgst,
                                                                    products1[index].discount,dicountValue.toString(), products1[index].APMC, admindiscountprice.toString(),products1[index].buyPrice,products1[index].shipping,products1[index].quantityInStock,products1[index].youtube,products1[index].mv);


//                                                               setState(() {
// //                                                                              cartvalue++;
//                                                                 Constant.carditemCount++;
//                                                                 cartItemcount(Constant.carditemCount);
//
//                                                               });

//                                                                Navigator.push(context,
//                                                                  MaterialPageRoute(builder: (context) => MyApp1()),);

                                                              }
                                                              else{


                                                                Navigator.push(context,
                                                                  MaterialPageRoute(builder: (context) => SignInPage()),);
                                                              }

//

                                                            },
                                                            child:Padding(padding: EdgeInsets.only(left: 5,top: 3.5,bottom: 3.5,right: 5),
                                                                child:Center(

                                                                  child:Text("ADD",style: TextStyle(color: AppColors.tela,fontSize: 12,fontWeight: FontWeight.bold),),
                                                                  // Icon(Icons.add_shopping_cart,color: Colors.white,),

                                                                )),),
                                                        )),






                                                  ]
                                              ) ,
                                            ),

                                          ],
                                        ),


                                      ),
                                    )
                                  ],
                                ),
                              ),







                            ),
                          ),
                          // double.parse(products1[index].discount)>0?  showSticker(index,products1):Row()

                        ],
                      );
                  },
                )
            ),
          ),

          Constant.carditemCount>0? InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishList()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)

                  )
              ),
              margin: EdgeInsets.only(left: 5,right: 5),
              height: 60,

              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                      width: 60,
                      padding: EdgeInsets.only(left: 10,right: 20),
                      child:Icon(Icons.add_shopping_cart_outlined ,size: 20,color: AppColors.white,)),
                  Container(
                    margin: EdgeInsets.only(right: 5,top: 3,bottom: 3),
                    width: 1,
                    height: 60,
                    color: AppColors.white,
                  ),

                  Container(child: SizedBox(
                      width: MediaQuery.of(context).size.width/3,
                      child: Text('( ${Constant.carditemCount} ) items count',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: AppColors.white),)),),
                  Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width/3,
                          child: Text('Proceed to cart',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: AppColors.white),)),
                      Padding(padding: EdgeInsets.only(left: 0),
                        child: Icon(Icons.arrow_forward_ios,color: AppColors.white,size: 15,),)
                    ],
                  )

                ],
              ),
            ),
          ):Row()
        ],
      ):Center(child: CircularProgressIndicator()):Container(
        child: Center(child: Text("No Product is Found"),),
      ),)
    );
  }


  String calDiscount(String byprice, String discount2) {
    String returnStr;
    double discount = 0.0;
    returnStr = discount.toString();
    double byprice1= double.parse(byprice);
    double discount1= double.parse(discount2);

    discount = (byprice1 - (byprice1 * discount1) / 100.0);

    returnStr = discount.toStringAsFixed(Constant.val);
    print(returnStr);
    return returnStr;
  }

  int total;

  _displayDialog(BuildContext context, String id, int index1) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable:true,
            title: Text('Select Varant'),
            content: Container(
              width: double.maxFinite,
              height: 200,
              child: FutureBuilder(
                  future: getPvarient(id),
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      return  ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length == null
                              ? 0
                              : snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return
                              Container(
                                width: snapshot.data[index]!=0?130.0:230.0,
                                color: Colors.white,
                                margin: EdgeInsets.only(right: 10),

                                child: InkWell(
                                  onTap: () {
                                    setState(() {

                                      products1[index1].buyPrice=snapshot.data[index].price;
                                      products1[index1].discount=snapshot.data[index].discount;


                                      // total= int.parse(snapshot.data[index].price);
                                      // String  mrp_price=calDiscount(snapshot.data[index].price,snapshot.data[index].discount);
                                      // totalmrp= double.parse(mrp_price);
                                      products1[index1].youtube=snapshot.data[index].variant;

                                      Navigator.pop(context);

                                    });

                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 10,right: 10),
                                        child: Text(
                                          snapshot.data[index].variant,
                                          overflow:TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 15,color:AppColors.black,

                                          ),
                                        ),
                                      ),
                                      Divider(

                                        color: AppColors.black,
                                      ),





                                    ],
                                  ),
                                ),







                              )
                            ;
                          });

                    }
                    return Center(child: CircularProgressIndicator());


                  }
              )


              ,
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

  final DbProductManager dbmanager = new DbProductManager();

  ProductsCart products2;
//cost_price=buyprice
  void _addToproducts(String pID,String p_name,String image,int price, int quantity,String c_val,String p_size,String p_disc,String sgst,String cgst,String discount,
      String dis_val,String adminper, String adminper_val,String cost_price,String shippingcharge,String  totalQun,String varient,String mv)
  {


    ProductsCart st = new ProductsCart(pid: pID, pname:p_name,  pimage:image,
        pprice:(price*quantity).toString(), pQuantity:quantity, pcolor:c_val??"", psize:p_size??"", pdiscription: p_disc,sgst: sgst,cgst: cgst, discount: discount,
        discountValue:dis_val, adminper:adminper,adminpricevalue:adminper_val,costPrice:cost_price,shipping: shippingcharge,totalQuantity: totalQun,varient:varient,mv: int.parse(mv));
    dbmanager.getProductList1(pID).then((usersFromServe) {
      if (this.mounted) {
        setState(() {
          if (usersFromServe.length > 0) {
            products2 = usersFromServe[0];
            st.quantity = products2.quantity + st.quantity;
            st.pprice = (double.parse(products2.pprice )+ (totalmrp*quantity)).toString();

            // st.quantity++;
            if (st.quantity <= int.parse(totalQun)) {
              dbmanager.updateStudent1(st).then((id) => {
                showLongToast(' products added your cart'),
              });
            }
            else{
              showLongToast(' products added your cart');
            }
          } else {

            dbmanager.insertStudent(st).then((id)
            => {
              // showLongToast("Products is upadte to cart ${id}' "),
              setState(() {
                Constant.carditemCount++;
                cartItemcount(Constant.carditemCount);
              })
            });

          }
        });
      }
    });



  }
  String calGst(String byprice, String sgst) {
    String returnStr;
    double discount = 0.0;
    if(sgst.length>1) {
      returnStr = discount.toString();
      double byprice1 = double.parse(byprice);
      print(sgst);

      double discount1 = double.parse(sgst);

      discount = ((byprice1 * discount1) / (100.0 + discount1));

      returnStr = discount.toStringAsFixed(2);
      print(returnStr);
      return returnStr;
    }
    else {
      return '0';
    }
  }

}