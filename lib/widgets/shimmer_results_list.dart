import 'package:amarp/constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerResultList extends StatelessWidget {
    const ShimmerResultList({
    Key? key,
    required this.count,
    }) : super(key: key);
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) => 
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              SizedBox(
                  width: deviceSize(context).width * 0.3,
                  height: 75,
                  child: Shimmer.fromColors(
                      baseColor:const Color.fromARGB(255, 228, 226, 226),
                      highlightColor: Colors.white70,
                      child: const Card(color: Colors.white)),
                ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: deviceSize(context).width * 0.4,
                      height: 20,
                      child: Shimmer.fromColors(
                          baseColor:const Color.fromARGB(255, 228, 226, 226),
                          highlightColor: Colors.white70,
                          child: const Card(color: Colors.white)),
                    ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                      width: deviceSize(context).width * 0.2,
                      height: 15,
                      child: Shimmer.fromColors(
                          baseColor:const Color.fromARGB(255, 228, 226, 226),
                          highlightColor: Colors.white70,
                          child: const Card(color: Colors.white)),
                    ),
                    SizedBox(
                      width: deviceSize(context).width * 0.2,
                      height: 15,
                      child: Shimmer.fromColors(
                          baseColor:const Color.fromARGB(255, 228, 226, 226),
                          highlightColor: Colors.white70,
                          child: const Card(color: Colors.white)),
                    ),
                  ],)
                ],
              ),


              Column(
                children: [
                  SizedBox(
                      width: deviceSize(context).width * 0.2,
                      height: 20,
                      child: Shimmer.fromColors(
                          baseColor:const Color.fromARGB(255, 228, 226, 226),
                          highlightColor: Colors.white70,
                          child: const Card(color: Colors.white)),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: deviceSize(context).width * 0.1,
                      height: 15,
                      child: Shimmer.fromColors(
                          baseColor:const Color.fromARGB(255, 228, 226, 226),
                          highlightColor: Colors.white70,
                          child: const Card(color: Colors.white)),
                    ),
                  const SizedBox(height: 15),
                ],
              ),
            ],
          ),
        )
      ,
    );
  }
}