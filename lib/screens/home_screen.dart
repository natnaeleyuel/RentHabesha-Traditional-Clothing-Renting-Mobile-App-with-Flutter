import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_habesha_flutter_app/routes/app_router.dart';

import '../bloc/clothing_bloc.dart';
import '../bloc/home_bloc.dart';
import '../core/models/clothing_model.dart';
import '../core/theme/colors.dart';
import '../core/widgets/bottom_navigationbar.dart';
import '../core/widgets/clothing_item_card.dart';
import '../repository/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter = "All";
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<HomeBloc>().add(const LoadClothingItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<HomeBloc>().add(ChangeFilter(search: query));
    }
  }

  final categories = ['Ethiopian Suit', 'Bernos', 'Habesha Kemis', 'Kaba', 'Netela'];
  final images = ['assets/images/img_nine.png', 'assets/images/bernos.png', 'assets/images/img_six.png', 'assets/images/kaba.png', 'assets/images/img_twelve.png'];

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _errorMessage = null;
    });
    context.read<HomeBloc>().add(ChangeFilter(type: filter == "All" ? null : filter));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ClothingBloc, ClothingState>(
          listener: (context, state) {
            if (state is ClothingDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clothing deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(10),
                ),
              );
              _loadInitialData();
            }
            if (state is EditClothingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clothing updated successfully')),
              );
              context.read<HomeBloc>().add(const LoadClothingItems());
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              setState(() => _errorMessage = state.message);
            } else if (state is HomeLoaded) {
              setState(() => _errorMessage = null);
            }
          }
        )
      ],
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading && state.clothingItems.isEmpty) {
              return _buildContent(context, clothingItems: [], isLoading: true);
            }

            return _buildContent(
              context,
              clothingItems: state is HomeLoaded ? state.clothingItems : [],
              isLoading: state is HomeLoading,
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required List<ClothingItem> clothingItems, bool isLoading = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.notifications, size: 28),
            ]
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => context.go(AppRoute.addClothing.path),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add New', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Text('Click to add clothes', style: TextStyle(fontSize: 16))
            ],
          ),

          const SizedBox(height: 10),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HomeBloc>().add(ChangeFilter(search: null));
                      },
                    ),
                  ),
                  onSubmitted: (_) => _applySearch(),
                )
              ),

              const SizedBox(width: 20),

              Container(
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/filter_icon.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _showFilterDialog(context),
                  padding: EdgeInsets.zero,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              TextButton(
                onPressed: () => _showAllCategory(context),
                child: const Text('See All ', style: TextStyle(fontSize: 16, color: AppColors.brand)),
              )
            ]
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage(images[index]), width: 40, height: 40),
                      Text(categories[index]),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height:15),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rent Now',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ),

          const SizedBox(height: 5),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                final filters = ["All", "Newest", "Men", "Women", "Child"];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filters[index]),
                    selected: _selectedFilter == filters[index],
                    onSelected: (bool selected) => _applyFilter(filters[index]),
                    backgroundColor: null,
                    showCheckmark: false,
                    side: BorderSide.none,
                    selectedColor: AppColors.brand,
                    labelStyle: TextStyle(
                      color: _selectedFilter == filters[index] ? Colors.white : null,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Stack(
              children: [
                if (_errorMessage != null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(const LoadClothingItems());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent) {
                        context.read<HomeBloc>().add(const LoadMoreClothingItems());
                      }
                      return false;
                    },
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: clothingItems.length,
                      itemBuilder: (context, index) {
                        final item = clothingItems[index];
                        return GestureDetector(
                          onLongPress: () => _showClothingOptions(context, item.id, item.owner.id),
                          onTap: () {
                            debugPrint('Navigation with ID: ${item.id}');
                            context.go(AppRoute.clothingDetails.path, extra: item.id);
                          },
                          child: ClothingItemCard(
                            imagePath: item.imageUrl,
                            title: item.title,
                            price: item.price,
                            clothingId: item.id,
                            ownerId: item.owner.id,
                            onTap: null,
                          )
                        );
                      },
                    ),
                  ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final filters = ["All", "Newest", "Men", "Women", "Child"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < filters.length; i++)
              RadioListTile<String>(
                title: Text(filters[i]),
                value: filters[i],
                groupValue: _selectedFilter,
                onChanged: (value) => _applyFilter(value!),)
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _applyFilter(_selectedFilter!);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAllCategory(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Categories'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final category in categories)
                ListTile(
                  title: Text(category),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClothingOptions(BuildContext context, String clothingId, String ownerId) async {
    try {
      final currentUserId = await context.read<AuthRepository>().getCurrentUserId();
      debugPrint('Current User: $currentUserId | Owner: $ownerId');

      if (currentUserId != ownerId) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not the owner'),
              duration: Duration(seconds: 2),
            ));
            return;
        }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          content: Row(
            children: [
              TextButton(
                child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 18)),
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.read<ClothingBloc>().add(DeleteClothing(clothingId));
                },
              ),

              const Spacer(),

              TextButton(
                child: const Text('Edit', style: TextStyle(color: AppColors.brand, fontSize: 18)),
                onPressed: () {
                  debugPrint('Navigation with ID: $clothingId');
                  context.go(AppRoute.editClothing.path, extra: clothingId);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ],
          ),
          duration: const Duration(seconds: 10),
        ),
      );





    } catch (e){
      debugPrint('Error showing options: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load options')),
      );
    }
  }
}