import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream:  Firestore.instance
              .collection('chats/IA7zmTas4qsnHmiNyd9z/messages')
              .snapshots(),
          builder: ( context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = snapshot.data.documents;
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => Container(
                padding: EdgeInsets.all(8),
                child: Text(documents[index]['text']),
              ),
            );
          },),


      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Firestore.instance
              .collection('chats/IA7zmTas4qsnHmiNyd9z/messages')
              .add({'text': 'This text added by clicking button'
          });
          }),
    );
  }
}