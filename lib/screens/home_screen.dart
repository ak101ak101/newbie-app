

import 'dart:async';
import 'dart:core';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newbie/screens/home_screen.dart';
import 'package:newbie/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:newbie/screens/chartbar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
   const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
 int _selectedIndex = 0;

 final pages = [

   const Home(),
   const Take(),
const Give(),

 ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(items:  const [
          BottomNavigationBarItem(icon:Icon(Icons.home),label:"Home"),
          BottomNavigationBarItem(icon:Icon(Icons.arrow_circle_down_outlined),label:"Take"),
BottomNavigationBarItem(icon:Icon(Icons.arrow_circle_up_outlined),label:"Give"),
        ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: (index){
          if(index==0) {
            setState(() {
            _selectedIndex = 0;});

          }
          if(index == 1){
            setState(() {
            _selectedIndex = 1;});

          }
          if(index == 2){
            setState(() {
            _selectedIndex = 2;});

          }

          },
        ),
        drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text("Akshat"),
                  accountEmail: Text("akshatdot@gmail.com"),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Image.asset("assets/images/pp.jpeg", width: 50, height: 50),
                  ),
                ),
                ListTile(
                    leading: Icon(Icons.home),
                    title: Text("home"),
                    onTap: () {
                      Home();
                    }),
                ListTile(
                    leading: Icon(Icons.pending_outlined),
                    title: Text("Take"),
                    onTap: () {
                      Take();
                    }),
                ListTile(
                  leading: Icon(Icons.done_all_outlined),
                  title: Text("Give"),
                  onTap: () {
                    Give();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      print("Signed Out");
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                    },
                    );
                  }
                ),

              ],
            )),
        appBar: AppBar(title: Text("Expense Calculator")),
        body:pages[_selectedIndex]

// bottomNavigationBar:     Container(
//   padding:const EdgeInsets.all(10),
//     child:  ElevatedButton(
//     child: Text("Logout"),
//     onPressed: () {
//       FirebaseAuth.instance.signOut().then((value) {
//         print("Signed Out");
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context) => SignInScreen()));
//       }
//       );
//     }
//
// ),
//     )
    );
  }
}

int c = 1;

class transaction {
  final int id;
  final String title;
  final double amt;
  final DateTime date;
  transaction(
      {required this.id,
        required this.title,
        required this.amt,
        required this.date});
}

Future<Stream<List<transaction>>>  getUserTaskLists() async {
  User? user = FirebaseAuth.instance.currentUser;
  String? idd = user?.uid;
  Stream<QuerySnapshot> stream =
  FirebaseFirestore.instance.collection(
      "users").doc(idd).collection("items").snapshots();
  Stream<List<transaction>> transa =   stream.asyncMap(
          (qShot) => qShot.docs.map(
              (ata) => transaction(title:ata["title"]
              ?? "",amt:ata["amount"]?? 0.0,date:DateTime.parse(ata["Date"])??DateTime.now(),id:2)
      ).toList()
  );

  return transa;
}

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList>  {
  final titlecontroller = TextEditingController();
  final amtcontroller = TextEditingController();
  DateTime selecteddate = DateTime(1999);
  User? user = FirebaseAuth.instance.currentUser;
  late String? idd = user?.uid;

  late Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance.collection(
       "users").doc(idd).collection("items").snapshots();




 late  Stream<List<transaction>> list = snapshot.map((data)=>
      data.docs.where((d) =>  DateTime.parse(d["Date"]).isAfter(  DateTime.now().subtract(
        const Duration(days: 7),),)).map((ata)=>transaction(title:ata["title"]
      ?? "",amt:ata["amount"]?? 0.0,date:DateTime.parse(ata["Date"])??DateTime.now(),id:2)).toList());

  // data!.docs.map((ata)=>transaction(title:ata["title"]
  // ?? "",amt:ata["amount"]?? 0.0,date:DateTime.parse(ata["Date"])??DateTime.now(),id:2)).toList();

  void _presentdatepicker() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        lastDate: DateTime.now(),
        firstDate: DateTime(2010))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selecteddate = pickedDate;
      });
    });
  }

  Future<void> addnewtx(String txtitle, double amont, DateTime chosendate) async {

    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    DocumentReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection("users").doc(uid).collection("items").doc();
    users.set({
      'id':users.id,
      'title':txtitle,
      'amount': amont,
      'Date':chosendate.toString(),
      'Day':DateFormat.E().format(chosendate),
    });
 titlecontroller.clear();
 amtcontroller.clear();
  }



  Function get aad => addnewtx;
  @override
  Widget build(BuildContext context)  {
    return SingleChildScrollView(
        child: Container(
            child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Card(
                        child: Container(
                          width: double.infinity,
                          child:StreamBuilder(stream:list, builder:(BuildContext context,AsyncSnapshot<List<transaction>> snapshot){if(snapshot.hasData)return Chart(snapshot.data!);else return Center(child:CircularProgressIndicator());}),

                      ),),
                      TextField(
                          controller: titlecontroller,
                          decoration: InputDecoration(labelText: 'Item name')),
                      TextField(
                          controller: amtcontroller,
                          decoration: InputDecoration(labelText: 'Enter Amount'),
                          keyboardType: TextInputType.number,

                      ),

                      Container(
                        height: 70,
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Text(selecteddate == DateTime.now()
                                ? 'No date chosen'
                                : 'Picked Date : ${DateFormat.yMd().format(selecteddate)}'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              primary: Colors.blue,
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            child: Text("Chose date"),
                            onPressed: _presentdatepicker,
                          ),
                        ]),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                     child: FloatingActionButton(
                        onPressed: () {
                          if(titlecontroller.text.isNotEmpty){
                          aad(titlecontroller.text,
                              double.parse(amtcontroller.text), selecteddate);}
                          else{
                            Fluttertoast.showToast(
                                msg: "Field cannot be empty",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },

                        child: const Text("add"),
                      ),
                      ),



                    ]
                )
            )
        ));
  }
}

class Chart extends StatefulWidget {
  final List<transaction> recenttrans;
  // ignore: use_key_in_widget_constructors
  Chart(this.recenttrans);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Map<String, Object>> get grouptranslist {
    return List.generate(7, (index) {
      final weekday = DateTime.now().subtract(
        Duration(days: index),
      );
      double total = 0.0;
      for (var i = 0; i < widget.recenttrans.length; i++) {
        if (widget.recenttrans[i].date.day == weekday.day &&
            widget.recenttrans[i].date.month == weekday.month &&
            widget.recenttrans[i].date.year == weekday.year) {
          total += widget.recenttrans[i].amt;
        }
      }
      return {'day': DateFormat.E().format(weekday), 'amt': total};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 6,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: grouptranslist.map((data) {
                double a = (data['amt'] as num).toDouble();
                return Flexible(
                  fit: FlexFit.tight,
                  child: chartbar((data['day'] as String), a,
                      tspending == 0 ? 0.0 : a / tspending),
                );
              }).toList(),
            ),
          ),
        ),
        Text('Total weekly spending = $tspending',
            style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }

  double get tspending {
    return grouptranslist.fold(0.0, (sum, item) {
      return sum + (item['amt'] as num).toDouble();
    });
  }
}


//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           child: Text("Logout"),
//           onPressed: () {
//             FirebaseAuth.instance.signOut().then((value) {
//               print("Signed Out");
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => SignInScreen()));
//             });
//           },
//         ),
//       ),
//     );
//   }
// }


class UserInformation extends StatefulWidget {
  const UserInformation({super.key});



  @override
  _UserInformationState createState() => _UserInformationState();
}


class _UserInformationState extends State<UserInformation> {
  @override
  initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
 late String? idd = user?.uid;
  late  Stream<QuerySnapshot> itemslist=FirebaseFirestore.instance.collection(
  "users").doc(idd).collection("items").snapshots();





  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: itemslist,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
    {

      if (snapshot.hasError) {
        return Text('Something went wrong');
      }


      // snapshot.data!.docs.map()forEach(data)=>(
      // transa.add(transaction(title:data["title"]?? "",amt:data["amount"]?? 0.0,date:DateTime.parse(data["Date"])??DateTime.now(),id:2));
      // );
      if(!snapshot.hasData || snapshot.data?.size == 0) {

        print("no data $snapshot.hasData");
        return Container(child:Text("No data"));
      }
      else {
      print("hellllooo $snapshot.hasData");
      print(snapshot.data!.docs.first["title"]);

      return ListView(
        children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String,
              dynamic>;

          print(data["title"]);
          data.forEach((key, value) { });
          return ListTile(
              leading: CircleAvatar(
                  radius: 30,
                  child:
                  FittedBox(child: Text(data["Day"]))),
              title: Text(
                  data["title"] +
                      " \n" +
                      "Cost=" +
                      data["amount"].toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.purple)),
              subtitle:
              Text(data["Date"]),

              trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: ()  {
                 DocumentReference docref =FirebaseFirestore.instance.collection(
                        "users").doc(idd).collection("items").doc(data["id"]);
                 docref.delete();
                 const TransactionList();
                  }
                // _deletetrans(tx.id.toString())),
              )
          );
        }
        ).toList(),
      );
      }
        },
    );
  }
//   Future<List<transaction>> getlist()async{
//     return  transa = itemslist.data!.docs.map((ata)=>transaction(title:ata["title"]
//         ?? "",amt:ata["amount"]?? 0.0,date:DateTime.parse(ata["Date"])??DateTime.now(),id:2)).toList();
// }
}

class Take extends StatefulWidget{
const Take({super.key});

@override
_Take createState() =>_Take();

}

class _Take extends State<Take>{
  @override
  initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child:Icon(Icons.add),
          onPressed: () {
            setState(() {takealertboc(context);});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title:Text("Lent Money Manage"),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.pending_rounded), text: "To take"),
            Tab(icon: Icon(Icons.done_all), text: "Taken"),
          ]),
        ),
        body: TabBarView(
          children: [
            ToTake(),
            Taken(),
          ],
        ),
      ),
    );
  }

}

class Home extends StatefulWidget{
  const Home({super.key});

  @override
  _Home createState() =>_Home();

}

class _Home extends State<Home>{
  @override
  initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Column(children:<Widget>[
        SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // ignore: prefer_const_literals_to_create_immutables
            children: <Widget>[
              SingleChildScrollView(
                child:TransactionList(),),




            ]
        ),


        ),
        const Expanded(
          child:UserInformation(),),
      ]
      );

  }

}


class Give extends StatefulWidget{
  const Give({super.key});

  @override
  _Give createState() =>_Give();

}

class _Give extends State<Give>{
  @override
  initState() {
    super.initState();
  }
  var textcoontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return  DefaultTabController(
      length: 2,
      child: Scaffold(
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.add),
        onPressed: () {
          setState(() {alertboc(context);});
           },
      ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title:Text("Borrowed Money Manage"),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.pending_rounded), text: "To give"),
            Tab(icon: Icon(Icons.done_all), text: "Given"),
          ]),
        ),
        body: TabBarView(
          children: [
            ToGive(),
            Given(),
          ],
        ),
      ),
    );
  }

}

class Given extends StatefulWidget{
  const Given({super.key});

  @override
  _Given createState() =>_Given();

}

class _Given extends State<Given>{
  @override
  initState() {
    super.initState();
  }
  User? user = FirebaseAuth.instance.currentUser;
  late String? idd = user?.uid;
  late  Stream<QuerySnapshot> itemslist=FirebaseFirestore.instance.collection(
      "users").doc(idd).collection("given").snapshots();





  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: itemslist,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
      {

        if (snapshot.hasError) {
          return Text('Something went wrong');
        }


        // snapshot.data!.docs.map()forEach(data)=>(
        // transa.add(transaction(title:data["title"]?? "",amt:data["amount"]?? 0.0,date:DateTime.parse(data["Date"])??DateTime.now(),id:2));
        // );
        if(!snapshot.hasData || snapshot.data?.size == 0) {

          print("no data $snapshot.hasData");
          return Container(child:Text("No data"));
        }
        else {
          print("hellllooo $snapshot.hasData");


          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String,
                  dynamic>;




              return ListTile(
                  leading: CircleAvatar(
                      radius: 30,
                      child:
                      FittedBox(child: Text(data["amount"]))),
                  title: Text(
                      data["name"] +
                          " \n" +
                          "Description: " +
                          data["desc"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.purple)),
                  subtitle:
                  Text("Given on "+data["date"]),

              );

            }
            ).toList(),
          );

        }
      },
    );
  }

}
class ToGive extends StatefulWidget{
  const ToGive({super.key});

  @override
  _ToGive createState() =>_ToGive();

}

class _ToGive extends State<ToGive>{
  @override
  initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  late String? idd = user?.uid;
  late  Stream<QuerySnapshot> itemslist=FirebaseFirestore.instance.collection(
      "users").doc(idd).collection("give").snapshots();





  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: itemslist,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
      {

        if (snapshot.hasError) {
          return Text('Something went wrong');
        }


        // snapshot.data!.docs.map()forEach(data)=>(
        // transa.add(transaction(title:data["title"]?? "",amt:data["amount"]?? 0.0,date:DateTime.parse(data["Date"])??DateTime.now(),id:2));
        // );
        if(!snapshot.hasData || snapshot.data?.size == 0) {

          print("no data $snapshot.hasData");
          return Container(child:Text("No data"));
        }
        else {
          print("hellllooo $snapshot.hasData");


          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String,
                  dynamic>;

              print(data["name"]);


                return ListTile(
                    leading: CircleAvatar(
                        radius: 30,
                        child:
                        FittedBox(child: Text(data["amount"]))),
                    title: Text(
                        data["name"] +
                            " \n" +
                            "Description: " +
                            data["desc"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.purple)),
                    subtitle:
                    Text("Added on "+data["date"]),

                    trailing: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          DocumentReference docref = FirebaseFirestore.instance
                              .collection(
                              "users").doc(idd).collection("given").doc();
                          docref.set({
                            'id':docref.id,
                            'name': data["name"],'desc':data["desc"],'amount':data["amount"],
                            'given':true,'date':DateTime.now().toString()});
                          DocumentReference docrefdel = FirebaseFirestore.instance
                              .collection(
                              "users").doc(idd).collection("give").doc(data["id"]);
                          docrefdel.delete();
                        }
                      // _deletetrans(tx.id.toString())),
                    )
                );

            }
            ).toList(),
          );

        }
      },
    );
  }
}

class Taken extends StatefulWidget{
  const Taken({super.key});

  @override
  _Taken createState() =>_Taken();

}

class _Taken extends State<Taken>{
  @override
  initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  late String? idd = user?.uid;
  late  Stream<QuerySnapshot> itemslist=FirebaseFirestore.instance.collection(
      "users").doc(idd).collection("taken").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: itemslist,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
      {

        if (snapshot.hasError) {
          return Text('Something went wrong');
        }


        // snapshot.data!.docs.map()forEach(data)=>(
        // transa.add(transaction(title:data["title"]?? "",amt:data["amount"]?? 0.0,date:DateTime.parse(data["Date"])??DateTime.now(),id:2));
        // );
        if(!snapshot.hasData || snapshot.data?.size == 0) {

          print("no data $snapshot.hasData");
          return Container(child:Text("No data"));
        }
        else {
          print("hellllooo $snapshot.hasData");


          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String,
                  dynamic>;


              print(data["name"]);


              return ListTile(
                  leading: CircleAvatar(
                      radius: 30,
                      child:
                      FittedBox(child: Text(data["amount"]))),
                  title: Text(
                      data["name"] +
                          " \n" +
                          "Description: " +
                          data["desc"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.purple)),
                  subtitle:
                  Text("Taken on "+data["date"]),


              );

            }
            ).toList(),
          );

        }
      },
    );
  }

}
class ToTake extends StatefulWidget{
  const ToTake({super.key});

  @override
  _ToTake createState() =>_ToTake();

}

class _ToTake extends State<ToTake>{
  @override
  initState() {
    super.initState();
  }
    User? user = FirebaseAuth.instance.currentUser;
    late String? idd = user?.uid;
    late  Stream<QuerySnapshot> itemslist=FirebaseFirestore.instance.collection(
        "users").doc(idd).collection("take").snapshots();

    @override
    Widget build(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: itemslist,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
        {

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }


          // snapshot.data!.docs.map()forEach(data)=>(
          // transa.add(transaction(title:data["title"]?? "",amt:data["amount"]?? 0.0,date:DateTime.parse(data["Date"])??DateTime.now(),id:2));
          // );
          if(!snapshot.hasData || snapshot.data?.size == 0) {

            print("no data $snapshot.hasData");
            return Container(child:Text("No data"));
          }
          else {
            print("hellllooo $snapshot.hasData");


            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String,
                    dynamic>;

                print(data["name"]);


                return ListTile(
                    leading: CircleAvatar(
                        radius: 30,
                        child:
                        FittedBox(child: Text(data["amount"]))),
                    title: Text(
                        data["name"] +
                            " \n" +
                            "Description: " +
                            data["desc"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.purple)),
                    subtitle:
                    Text("Added on "+data["date"]),

                    trailing: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          DocumentReference docref = FirebaseFirestore.instance
                              .collection(
                              "users").doc(idd).collection("taken").doc();
                          docref.set({
                            'id':docref.id,
                            'name': data["name"],'desc':data["desc"],'amount':data["amount"],
                            'taken':true,'date':DateTime.now().toString()});
                          DocumentReference docrefdel = FirebaseFirestore.instance
                              .collection(
                              "users").doc(idd).collection("take").doc(data["id"]);
                          docrefdel.delete();

                        }
                      // _deletetrans(tx.id.toString())),
                    )
                );

              }
              ).toList(),
            );

          }
        },
      );
    }

}


Future alertboc(context) async {
  var namecontroller = TextEditingController() ;
  var desccontroller = TextEditingController() ;
  var amountcontroller = TextEditingController() ;
  var emailcontroller = TextEditingController() ;
  return showDialog(
  
      builder: (context) => AlertDialog(
    title: const Text('TextField in Dialog'),
    content: Column(
      mainAxisSize:MainAxisSize.min,
        children:<Widget>[
          TextField(

      onChanged: (value) { },
      controller: namecontroller,
      decoration: InputDecoration(hintText: "Name of person to give",labelText:"Enter name"),
    ),
          TextField(

            onChanged: (value) { },
            controller: desccontroller,
            decoration: InputDecoration(hintText: "Reason for borrowing",labelText:"Enter Description"),
          ),
          TextField(

            onChanged: (value) { },
            controller: amountcontroller,
            decoration: InputDecoration(hintText: "Amount to give",labelText:"Enter Amount"),
              keyboardType: TextInputType.number

          ),
          TextField(

            onChanged: (value) { },
            controller: emailcontroller,
            decoration: InputDecoration(hintText: "Email if user use the app",labelText:"Enter Email"),
          ),
  ]
    ),
   actions:[
     TextButton(onPressed: () {
       Navigator.of(context).pop();
     }, child: Text("Cancel"),

     ),
     TextButton(onPressed: () async {
       final User? user = FirebaseAuth.instance.currentUser;
       final uid = user?.uid;
       final email = user?.email;
       DocumentReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection("users").doc(uid).collection("give").doc();
       if(amountcontroller.text.isNotEmpty  && namecontroller.text.isNotEmpty) {
         users.set({
         'id':users.id,
         'name':namecontroller.text,
         'amount':amountcontroller.text,
         'desc':desccontroller.text,
         'email':emailcontroller.text,
         'date':DateTime.now().toString(),
         'given':false
       }


       );
         sendtakedata(namecontroller.text, emailcontroller.text, amountcontroller.text, desccontroller.text,email!);
       }
       else{
         Fluttertoast.showToast(
             msg: "Fields cannot be null",
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.CENTER,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.black,
             textColor: Colors.white,
             fontSize: 16.0
         );
       }
       Navigator.of(context).pop();
     }, child: Text("Add"),),
   ],
  ),
    context: context,
  );
}


Future takealertboc(context) async {
  var namecontroller = TextEditingController() ;
  var desccontroller = TextEditingController() ;
  var amountcontroller = TextEditingController() ;
  var emailcontroller = TextEditingController() ;
  return showDialog(

    builder: (context) => AlertDialog(
      title: const Text('TextField in Dialog'),
      content: Column(
          mainAxisSize:MainAxisSize.min,
          children:<Widget>[
            TextField(

              onChanged: (value) { },
              controller: namecontroller,
              decoration: InputDecoration(hintText: "Name of person to take",labelText:"Enter name"),
            ),
            TextField(

              onChanged: (value) { },
              controller: desccontroller,
              decoration: InputDecoration(hintText: "Reason for lending",labelText:"Enter Description"),
            ),
            TextField(

              onChanged: (value) { },
              controller: amountcontroller,
              decoration: InputDecoration(hintText: "Amount to take",labelText:"Enter Amount"),
                keyboardType: TextInputType.number,

            ),
            TextField(

              onChanged: (value) { },
              controller: emailcontroller,
              decoration: InputDecoration(hintText: "Email if user use the app",labelText:"Enter Email"),
            ),
          ]
      ),
      actions:[
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: Text("Cancel"),

        ),
        TextButton(onPressed: () async {
          final User? user = FirebaseAuth.instance.currentUser;
          final uid = user?.uid;
          final email = user?.email;
          DocumentReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection("users").doc(uid).collection("take").doc();
          if(amountcontroller.text.isNotEmpty  && namecontroller.text.isNotEmpty) {
            users.set({
              'id':users.id,
              'name':namecontroller.text,
              'amount':amountcontroller.text,
              'desc':desccontroller.text,
              'email':emailcontroller.text,
              'date':DateTime.now().toString(),
              'taken':false
            }


            );
            sendgivedata(namecontroller.text, emailcontroller.text, amountcontroller.text, desccontroller.text,email!);
          }
          else{
            Fluttertoast.showToast(
                msg: "Fields cannot be null",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          Navigator.of(context).pop();
        }, child: Text("Add"),),
      ],
    ),
    context: context,
  );
}

Future<void> sendgivedata(String name,String email,String amount,String desc,String semail) async {
  // Get docs from collection reference
  final fireStore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await fireStore.collection('users').where("email",isEqualTo:email).get();

  // Get data from docs and convert map to List

    // print(data["email"]);

// allData.takeWhile((value) => value == "nam@gmail.com");


  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  Map<String, String?> map = Map.fromIterable(allData,
      key: (item) => 'uid',
      value: (item) =>  item['id'],
  );
  print(map);
if(map["uid"] != null) {
  DocumentReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection("users").doc(map["uid"]).collection("give").doc();

  users.set({
    'id':users.id,
    'name':name,
    'amount':amount,
    'desc':desc,
    'email':semail,
    'date':DateTime.now().toString(),
    'given':false
  }


  );
}
else{

  Fluttertoast.showToast(
      msg: "User not found ",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
}
Future<void> sendtakedata(String name,String email,String amount,String desc,String semail) async {
  // Get docs from collection reference
  final fireStore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await fireStore.collection('users').where("email",isEqualTo:email).get();

  // Get data from docs and convert map to List

  // print(data["email"]);

// allData.takeWhile((value) => value == "nam@gmail.com");


  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  Map<String, String?> map = Map.fromIterable(allData,
    key: (item) => 'uid',
    value: (item) =>  item['id'],
  );
  print(map);
  if(map["uid"] != null) {
    DocumentReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection("users").doc(map["uid"]).collection("take").doc();

    users.set({
      'id':users.id,
      'name':name,
      'amount':amount,
      'desc':desc,
      'email':semail,
      'date':DateTime.now().toString(),
      'taken':false
    }


    );
  }
  else{

    Fluttertoast.showToast(
        msg: "User not found ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}