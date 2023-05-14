// import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  MyWidget({super.key});
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final api = "https://jsonplaceholder.typicode.com/posts";
  final int limit = 20;
  late int page = 1;
  late bool _hasNextPage = true;
  late bool _isLoadMoreRunning = false;
  late bool isFirstLoadingRunning = false;
  late List<dynamic> data = [];
  late ScrollController sc;
  late bool isLoading;
  void _firstLoad() async {
    setState(() {
      isFirstLoadingRunning = true;
    });
    try {
      fetchData();
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isFirstLoadingRunning = false;
    });
  }

  void _loadMoare() async {
    if (_hasNextPage == true &&
        isFirstLoadingRunning == false &&
        _isLoadMoreRunning == false) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      page += 1;

      try {
        final dio.Response response =
            await dio.Dio().get(api, queryParameters: {
          '_page': page,
          '_limit': limit,
        });
        final List fetchPosts = response.data;

        if (response.statusCode == 200 && fetchPosts.isNotEmpty) {
          setState(() {
            data.addAll(fetchPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (e) {}
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void initState() {
    _firstLoad();
    sc = ScrollController()
      ..addListener(() {
        if (sc.position.maxScrollExtent == sc.offset) {
          _loadMoare();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (sc.offset >= sc.position.maxScrollExtent && !sc.position.outOfRange) {
  //     // user has scrolled to the bottom of the list, load more data
  //     setState(() {
  //       isLoading = true; // show a loading indicator
  //     });
  //     fetchData().then((newData) {
  //       setState(() {
  //         data.addAll(newData); // add the new data to the existing list
  //         isLoading = false; // hide the loading indicator
  //       });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: sc,
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final item = data[index];
                return ListTile(
                  leading: Text('${item['id']}'),
                  title: Text(item['title']),
                  subtitle: Text(item['body']),
                );
              },
            ),
          ),
          if (_isLoadMoreRunning)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_hasNextPage == false)
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              color: Colors.amber,
              child: const Center(
                  child: Text("You have fetched all of this content")),
            )
        ],
      ),
    );
  }

  void fetchData() async {
    final List<dynamic>? posts;
    final dio.Response response = await dio.Dio().get(api, queryParameters: {
      '_page': page,
      '_limit': limit,
    });
    if (response.statusCode == 200) {
      setState(() {
        data = response.data;
      });
    }
  }
}
