import 'package:flutter/material.dart';
import 'package:royalmart/General/AppConstant.dart';
import 'package:royalmart/dbhelper/database_helper.dart';
import 'package:royalmart/model/CategaryModal.dart';
import 'package:royalmart/screen/SubCategry.dart';
import 'package:royalmart/screen/secondtabview.dart';
import 'package:royalmart/screen/SearchScreen.dart';

class Cgategorywise extends StatefulWidget {
  final String id;
  Cgategorywise(this.id);

  @override
  _CgategorywiseState createState() => _CgategorywiseState();
}

class _CgategorywiseState extends State<Cgategorywise> {
  List<Categary> cat_list = [];
  List<Categary> sub_cat_list = [];

  getlistval(String id) {
    getData(id).then((usersFromServe) {
      if (this.mounted) {
        setState(() {
          sub_cat_list = usersFromServe;

//        }
        });
      }
    });
  }

  bool flag = false;

  void initState() {
    getData(widget.id).then((usersFromServe) {
      if (this.mounted) {
        setState(() {
          cat_list = usersFromServe;
          // cat_list.length>0?getlistval(cat_list[0].pcatId):"";
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 50, bottom: 50),
                width: double.infinity,
                child: Container(
                  margin: EdgeInsets.only(top: 0, bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Material(
                      color: Colors.white,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserFilterDemo()),
                            );
                          },
                          child: TextField(
                            enabled: false,
                            obscureText: false,
                            decoration: InputDecoration(
                                hintText:
                                    "                        Search for any product",
                                hintStyle: TextStyle(
                                    fontSize: 14.0, color: AppColors.darkGray),
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.darkGray,
                                )),
                          )),
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                  future: getData(""),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: GridView.builder(
                          physics: ClampingScrollPhysics(),
                          controller:
                              new ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 11 / 8,
                          ),
                          itemBuilder: (context, index) {
                            Categary item = snapshot.data[index];
                            return InkWell(
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => Screen2(item.pcatId,item.pCats)),);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Sbcategory(item.pCats, item.pcatId)),
                                );
                              },
                              child: Card(
                                elevation: 7.0,
                                shadowColor: AppColors.tela,
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 5,
                                            right: 10,
                                            top: 10,
                                            bottom: 10),
                                        child: Card(
                                          elevation: 7.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: item.img.length > 0
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.network(
                                                    Constant.base_url +
                                                        "manage/uploads/p_category/" +
                                                        item.img,
                                                  ),
                                                )
                                              : Image.network(
                                                  "assets/images/logo.png"),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.pCats,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                              color: AppColors.darkGray),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: snapshot.data.length == null
                              ? 0
                              : snapshot.data.length,
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ],
          ),
        ),
      ),
    );
  }

  int val = -1;
  int grid = -1;
  ShowColor(int index) {
    setState(() {
      val = index;
    });
  }

  GridShowColor(int index) {
    setState(() {
      grid = index;
    });
  }

  Widget show_catnam() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.tela1), color: AppColors.white),
      width: 120,
      child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          scrollDirection: Axis.vertical,
          itemCount: cat_list.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Screen2(
                                  cat_list[index].pcatId,
                                  cat_list[index].pCats)),
                        );
                        ShowColor(index);
                      },
                      child: Container(
                        color: val == index ? AppColors.tela1 : AppColors.white,
                        width: 93,
                        height: 40,
                        child: Center(
                          child: Text(
                            cat_list[index].pCats,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: val == index
                                    ? AppColors.white
                                    : AppColors.black),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          getlistval(cat_list[index].pcatId);
                          flag = true;
                          ShowColor(index);
                        });
                      },
                      child: Container(
                          // padding:EdgeInsets.all(1),
                          child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 25,
                        color: AppColors.black,
                      )),
                    )
                  ],
                ),
                Divider(
                  color: AppColors.tela1,
                ),
              ],
            );
          }),
    );
  }

  Widget show_cat_subnam() {
    return Container(
      // width: 150,
      margin: EdgeInsets.only(left: 100),
      child: ListView.builder(
          // separatorBuilder: (context, index) => Divider(
          //   color: Colors.grey,
          // ),
          shrinkWrap: true,
          primary: false,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: sub_cat_list.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 5, right: 5),
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    // color: Colors.grey,
                    child: ListTile(
                      title: Text(
                        sub_cat_list[index].pCats,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.black, fontSize: 12),
                      ),
                      trailing: Icon(
                        grid != index
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: AppColors.black,
                      ),
                      onTap: () {
                        if (grid != index) {
                          GridShowColor(index);
                        } else {
                          setState(() {
                            grid = -1;
                          });
                        }
                      },
                    )

                    // Text(sub_cat_list[index].pCats,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: AppColors.black),) ,
                    ),
                Divider(
                  color: AppColors.black,
                ),
                grid == index
                    ? Container(
                        color: AppColors.tela1,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        // height: 90,
                        child: FutureBuilder(
                            future: getData(sub_cat_list[index].pcatId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                  child: GridView.builder(
                                    physics: ClampingScrollPhysics(),
                                    controller: new ScrollController(
                                        keepScrollOffset: false),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(
                                      left: 6,
                                      right: 6,
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 2,
                                      crossAxisSpacing: 2,
                                      childAspectRatio: 0.7,
                                    ),
                                    itemBuilder: (context, index) {
                                      Categary item = snapshot.data[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Screen2(
                                                    item.pcatId, item.pCats)),
                                          );
                                        },
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.white,
                                                  child: ClipOval(
                                                    child: new SizedBox(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      child: item.img.length > 0
                                                          ? Image.network(
                                                              Constant.base_url +
                                                                  "manage/uploads/p_category/" +
                                                                  item.img,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "assets/images/logo.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  item.pCats,
                                                  maxLines: 2,
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: snapshot.data.length == null
                                        ? 0
                                        : snapshot.data.length,
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            }),
                      )
                    : Row(),
              ],
            );
          }),
    );
  }
}
