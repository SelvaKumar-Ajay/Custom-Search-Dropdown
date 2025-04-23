import 'package:custom_dropdowns/custom_dropdown.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: const Text("Custom DropDown"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text("items as String"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomDropdown(
              itemLabelBuilder: (p0) => p0,
              items: const [
                "Cat",
                "Maa",
                "Apple",
                "Tiger",
                "Ramya",
                "Kalai",
                "Puli",
                "Vaal",
              ],
            ),
          ),
          const Text("items as Animal"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomDropdown<Animal>(
              itemLabelBuilder: (Animal item) => item.animal,
              items: [
                Animal(1, "Cat"),
                Animal(2, "Dog"),
                Animal(3, "Cow"),
                Animal(4, "Lion"),
                Animal(5, "Tiger"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Animal {
  final int id;
  final String animal;
  Animal(this.id, this.animal);
}
