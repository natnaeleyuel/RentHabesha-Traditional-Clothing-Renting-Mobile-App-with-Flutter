import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/models/clothing_model.dart';
import '../core/theme/colors.dart';
import '../core/widgets/button.dart';
import '../core/widgets/top_navigation.dart';
import '../repository/add_clothing_repository.dart';
import '../routes/app_router.dart';

class ClothingDetailsScreen extends StatefulWidget {
  final String clothingId;
  const ClothingDetailsScreen({required this.clothingId, Key? key}) : super(key: key);

  @override
  State<ClothingDetailsScreen> createState() => _ClothingDetailsScreenState();
}

class _ClothingDetailsScreenState extends State<ClothingDetailsScreen> {
  bool _showFullDescription = false;
  int _quantity = 0;
  double _price = 0;
  double get totalPrice => _quantity * _price;

  late Future<ClothingItem> _clothingFuture;

  @override
  void initState() {
    super.initState();
    _clothingFuture = context.read<ClothingRepository>().getClothingById(widget.clothingId);
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        onBackPressed: () => context.go(AppRoute.home.path),
      ),
      body: FutureBuilder<ClothingItem>(
        future: _clothingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No clothing item found'));
          }

          final clothing = snapshot.data!;
          _price = double.tryParse(clothing.price) ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 10),

                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: clothing.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'http://0.0.0.0:5000${clothing.images[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "${clothing.type.toString()}'s",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  clothing.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Product Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clothing.description.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: _showFullDescription ? null : 2,
                      overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    if (clothing.description.toString().length > 100)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFullDescription = !_showFullDescription;
                          });
                        },
                        child: Text(
                          _showFullDescription ? 'Read less' : 'Read more',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Rental Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      'Price: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'ETB ${clothing.price}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      'Rental Period: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      clothing.rentalDuration.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quantity Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.brand,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementQuantity,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Total Price',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'ETB ${totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          CustomButton(
            onPressed: () {

            },
            text: 'Add to Cart',
          ),
        ],
      ),
    );
  }
}