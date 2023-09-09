import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:recipe/BookmarksScreen.dart';
import 'package:recipe/bookmark_provider.dart';
import 'package:recipe/model/model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class First extends StatefulWidget {
  const First({super.key});

  @override
  _FirstState createState() => _FirstState();
}

class _FirstState extends State<First> {
  Map<String, List<String>> filterOptionsMap = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int recipesPerPage = 20; // Number of recipes to fetch per page
  int currentPage = 0;
  int minCalories = 0;
  int maxCalories = 9999;
  bool showCaloriesInput = false;
  bool isBMTapped = false;
  bool isSearchIconTapped = false;
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  List<String> filters = [
    'Allergies',
    'Diets',
    'Calories',
  ];

  Map<String, List<String>> selectedOptions = {
    'Allergies': [],
    'Diets': [],
  };

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);

    for (String filter in filters) {
      selectedOptions[filter] = [];
    }

    filterOptionsMap = {
      'Allergies': [
        'Celery-free',
        'Crustacean-free',
        'Dairy-free',
        'Egg-free',
        'Fish-free',
        'Gluten-free',
        'Lupine-free',
        'Mustard-free',
        'Peanut-free',
        'Sesame-free',
        'Shellfish-free',
        'Soy-free',
        'Tree-Nut-free',
        'Wheat-free',
      ],
      'Diets': [
        'Alcohol-free',
        'Balanced',
        'High-Fiber',
        'High-Protein',
        'Keto',
        'Kidney friendly',
        'Kosher',
        'Low-Carb',
        'Low-Fat',
        'Low potassium',
        'Low-Sodium',
        'No oil added',
        'No-sugar',
        'Paleo',
        'Pescatarian',
        'Pork-free',
        'Red meat-free',
        'Sugar-conscious',
        'Vegan',
        'Vegetarian',
      ],
    };
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  List<Model> originalRecipes = [];
  List<Model> recipes = [];
  String id = '4b74f361';
  String key = '5bf2222dec490b0ad056442afe57f189';

  Future<void> getrecipe(String query) async {
    setState(() {
      isLoading = true;
      currentPage = 0;
    });

    try {
      originalRecipes.clear(); // Clear the previous recipes
      await fetchAndParseRecipes(query);
      applyFilters(); // Apply filters after fetching recipes
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndParseRecipes(String query) async {
    String url =
        'https://api.edamam.com/search?q=$query&app_id=$id&app_key=$key'
        '&from=${currentPage * recipesPerPage}&to=${(currentPage + 1) * recipesPerPage - 1}';

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsondata = jsonDecode(response.body);

    jsondata["hits"].forEach((element) {
      double rawCalories = element['recipe']['calories'];
      int parsedCalories = rawCalories.round();

      List<String> allergiesList =
          List<String>.from(element['recipe']['allergies'] ?? []);
      List<String> dietsList =
          List<String>.from(element['recipe']['dietLabels'] ?? []);

      Model model = Model(
        image: element['recipe']['image'],
        source: element['recipe']['source'],
        label: element['recipe']['label'],
        url: element['recipe']['url'],
        calories: parsedCalories,
        allergies: allergiesList,
        diets: dietsList,
      );

      originalRecipes.add(model);
      setState(() {
        recipes.add(model);
      });
    });

    currentPage++; // Move to the next page for the next fetch
  }

  void applyFilters() {
    recipes.clear(); // Clear the current list of recipes
    for (Model recipe in originalRecipes) {
      // Check if the recipe meets the selected options criteria
      bool isAllergyMatch = (selectedOptions['Allergies']?.isEmpty ?? true) ||
          recipe.allergies.any((allergy) =>
              selectedOptions['Allergies']?.contains(allergy) ?? false);

      bool isDietMatch = (selectedOptions['Diets']?.isEmpty ?? true);

      bool isCaloriesMatch =
          recipe.calories >= minCalories && recipe.calories <= maxCalories;

      if (isAllergyMatch && isDietMatch && isCaloriesMatch) {
        recipes.add(recipe);
      }
    }
  }

  void _onFilterChanged() {
    applyFilters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  for (String filter in filters)
                    if (filter == 'Calories')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionTile(
                            title: Text(
                              filter,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: fromController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'From',
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.isNotEmpty) {
                                                  minCalories =
                                                      int.parse(value);
                                                } else {
                                                  minCalories = 0;
                                                }
                                                print(
                                                    'minCalories: $minCalories');
                                                _onFilterChanged();
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: TextField(
                                            controller: toController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'To',
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.isNotEmpty) {
                                                  maxCalories =
                                                      int.parse(value);
                                                } else {
                                                  maxCalories = 9999;
                                                }
                                                print(
                                                    'maxCalories: $maxCalories');
                                                _onFilterChanged();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionTile(
                            title: Text(
                              filter,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            children: [
                              for (String option
                                  in filterOptionsMap[filter] ?? [])
                                CheckboxListTile(
                                  title: Text(option),
                                  value: selectedOptions[filter]
                                          ?.contains(option) ??
                                      false,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value != null) {
                                        if (value) {
                                          selectedOptions[filter]?.add(option);
                                        } else {
                                          selectedOptions[filter]
                                              ?.remove(option);
                                        }
                                        _onFilterChanged();
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10, bottom: 10),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Text('Submit'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              _searchFocusNode.unfocus();
            },
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.shade100,
                      Colors.purpleAccent.shade700,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text(
                              "Recipe Search",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontFamily: 'Pacifico',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isBMTapped = true;
                                  });
                                  Future.delayed(Duration(milliseconds: 100),
                                      () {
                                    setState(() {
                                      isBMTapped = false;
                                    });
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookmarksScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    child: Icon(
                                      Icons.bookmark,
                                      color: Colors.white,
                                      size: 26.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Search recipes...',
                                hintStyle: TextStyle(color: Colors.black54),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      isSearchIconTapped = true;
                                    });
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    setState(() {
                                      isSearchIconTapped = false;
                                    });
                                    if (_searchController.text.isNotEmpty) {
                                      await getrecipe(_searchController.text);
                                      setState(() {});
                                    } else {}
                                  },
                                  child: Ink(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .transparent, // Set your desired background color
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 12),
                                      decoration: BoxDecoration(
                                        color: isSearchIconTapped
                                            ? Colors.grey
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: const Icon(Icons.search,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const SizedBox(
                      height: 16,
                    ),
                    isLoading
                        ? const Center(
                            child: LinearProgressIndicator(),
                          )
                        : Expanded(
                            child: GridView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisSpacing: 60,
                              ),
                              children: List.generate(recipes.length, (index) {
                                return GridTile(
                                  child: Tile(
                                    title: recipes[index].label,
                                    desc: recipes[index].source,
                                    imgurl: recipes[index].image,
                                    url: recipes[index].url,
                                    cal: recipes[index].calories,
                                  ),
                                );
                              }),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                  //  )
                ))));
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();

    super.dispose();
  }
}

class Tile extends StatefulWidget {
  final String? title;
  final String? desc;
  final String? imgurl;
  final String? url;
  final int? cal;

  const Tile({
    Key? key,
    required this.title,
    required this.desc,
    required this.imgurl,
    required this.url,
    required this.cal,
  }) : super(key: key);

  @override
  State<Tile> createState() => Tilestate();
}

class Tilestate extends State<Tile> {
  bool isBookmarked = false;
  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      throw "URL is empty or null";
    }

    final Uri uri = Uri.parse(url);
    if (!await launch(
      uri.toString(),
      forceSafariVC: false,
      universalLinksOnly: true,
    )) {
      throw "Can't launch URL";
    }
  }

  void _shareRecipe() {
    Share.share('Check out this recipe: ${widget.title}\n${widget.url}');
  }

  Future<void> toggleBookmark() async {
    BookmarkProvider bookmarkProvider =
        Provider.of<BookmarkProvider>(context, listen: false);

    if (!bookmarkProvider.isBookmarked(widget.url!)) {
      // Add recipe URL and title to bookmarks
      bookmarkProvider.addBookmark(widget.url!, widget.title!);
    } else {
      // Remove recipe URL and title from bookmarks
      bookmarkProvider.removeBookmark(widget.url!);
    }
  }

  @override
  void initState() {
    super.initState();
    loadBookmarkStatus();
  }

  Future<void> loadBookmarkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isBookmarked = prefs.containsKey(widget.url!);
    });
  }

  @override
  Widget build(BuildContext context) {
    BookmarkProvider bookmarkProvider = Provider.of<BookmarkProvider>(context);
    bool isBookmarked = bookmarkProvider.isBookmarked(widget.url!);
    return GestureDetector(
      onDoubleTap: () {
        _launchURL(widget.url);
      },
      onLongPress: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share Recipe'),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _shareRecipe(); // Share the recipe URL
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: <Widget>[
              Image.network(
                widget.imgurl ?? 'fallback_image_url',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      widget.title ?? 'Not found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.desc ?? 'Not found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4), // Add spacing for calories
                    Text(
                      'Calories: ${widget.cal ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: toggleBookmark,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
