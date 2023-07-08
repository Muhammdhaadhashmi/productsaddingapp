import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Product.dart';
import 'desc_screen.dart';


class SearchProducts extends StatefulWidget {
  SearchProducts({super.key});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  TextEditingController _textEditingController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final firestore =
      FirebaseFirestore.instance.collection('products').snapshots();

  String name = '';

  List<Product> sub_category_model = [];
  List<Product> _searchResult = [];

  onSearchTextChanged(String text) async {
    //clear search data before typing
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    //use searchcontroller text and loop through list of api data and add the result to _searchResult

    sub_category_model.forEach((searchValue) {
      if (searchValue.name.toLowerCase().contains(text))
        _searchResult.add(searchValue);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Search'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _textEditingController,
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for Products',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            StreamBuilder(
              stream: firestore,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var data = snapshot.data!.docs
                    .where((doc) =>
                        doc['name'].toLowerCase().contains(name.toLowerCase()))
                    .toList();

                print(data.length);
                return Expanded(
                  child: GridView.builder(
                    itemCount: data.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.73),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return DescScreen(
                                        token: snapshot.data!.docs[index]
                                            ['token'],
                                        images: data[index]['image_urls'],
                                        name: data[index]['name'].toString(),
                                        description: data[index]['description']
                                            .toString(),
                                        current_bid: data[index]['current_bid']
                                            .toString(),
                                        email: data[index]['seller_email']
                                            .toString(),
                                        docId: data[index].reference.id,
                                      );
                                    },
                                  ));
                                },
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        snapshot
                                            .data!.docs[index]['image_urls'][2]
                                            .toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                snapshot.data!.docs[index]['name'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                snapshot.data!.docs[index]['description']
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat.yMMMd().format(
                                        snapshot.data!.docs[index]['date']
                                            .toDate(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Rs.${snapshot.data!.docs[index]['current_bid'].toString()}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
