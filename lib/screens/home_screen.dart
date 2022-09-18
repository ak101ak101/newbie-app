

import 'dart:async';
import 'dart:core';


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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(title: Text("Expense Calculator")),
        body:Column(children:<Widget>[
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
        ),

bottomNavigationBar:     Container(
  padding:const EdgeInsets.all(10),
    child:  ElevatedButton(
    child: Text("Logout"),
    onPressed: () {
      FirebaseAuth.instance.signOut().then((value) {
        print("Signed Out");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SignInScreen()));
      }
      );
    }

),
    ));
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
class rtransaction {
  final int id;
  final String title;
  final double amt;
  final String date;
  rtransaction(
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
    final newtx =
    transaction(title: txtitle, amt: amont, id: c, date: chosendate);
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
    setState(() {
      // transa.add(newtx);
      c++;
    });
  }

  void _deletetrans(String idd) {
    setState(() {

    });
  }
  //
  //  Stream<List<transaction>> get _recenttransactions {
  //
  //   return list.takeWhile((tx) {
  //
  //        return DateTime.parse(tx.date).isAfter(
  //           DateTime.now().subtract(
  //           Duration(days: 7),),);
  //     });
  //
  // }

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
                          child:StreamBuilder(stream:list, builder:(BuildContext context,AsyncSnapshot<List<transaction>> snapshot){if(snapshot.hasData)return Chart(snapshot.data!);else return CircularProgressIndicator();}),

                      ),),
                      TextField(
                          controller: titlecontroller,
                          decoration: InputDecoration(labelText: 'enter name')),
                      TextField(
                          controller: amtcontroller,
                          decoration: InputDecoration(labelText: 'enter amt')),
                      Container(
                        height: 70,
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Text(selecteddate == DateTime(1999)
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
                          aad(titlecontroller.text,
                              double.parse(amtcontroller.text), selecteddate);
                        },

                        child: const Text("add"),
                      ),
                      ),

                      Column(
                        children:<Widget> [

                        ]
                        // children: transa.map((tx) {
                        //   return Card(
                        //     elevation: 5,
                        //     margin: EdgeInsets.symmetric(
                        //         vertical: 8, horizontal: 5),
                        //     child: ListTile(
                        //       leading: CircleAvatar(
                        //           radius: 30,
                        //           child:
                        //           FittedBox(child: Text(tx.id.toString()))),
                        //       title: Text(
                        //           tx.title +
                        //               " \n" +
                        //               "Cost=" +
                        //               tx.amt.toString(),
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 20,
                        //               color: Colors.purple)),
                        //       subtitle:
                        //       Text(DateFormat('EEE,d/M/y').format(tx.date)),
                        //       trailing: IconButton(
                        //           icon: Icon(Icons.delete),
                        //           onPressed: () =>
                        //               _deletetrans(tx.id.toString())),
                        //     ),
                        //   );
                        // }).toList(),

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
