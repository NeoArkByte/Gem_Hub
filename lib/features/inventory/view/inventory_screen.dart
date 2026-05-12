import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/inventory/viewmodel/inventory_viewmodel.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(inventoryViewModelProvider.notifier).refreshInventory();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryViewModelProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Inventory'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        child: inventoryState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Failed to load inventory: $error')),
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No inventory available.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(inventoryViewModelProvider.notifier)
                    .refreshInventory();
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final gem = items[index];
                  return _InventoryCard(
                    gem: gem,
                    isDark: isDark,
                    onDelete: () async {
                      final success = await ref
                          .read(inventoryViewModelProvider.notifier)
                          .deleteGem(gem.id!);
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to delete inventory item'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final Gem gem;
  final bool isDark;
  final VoidCallback onDelete;

  const _InventoryCard({
    required this.gem,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gem.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gem.type.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: isDark ? Colors.red[300] : Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            gem.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Badge(label: gem.location, isDark: isDark),
              const SizedBox(width: 8),
              _Badge(label: '${gem.carat} ct', isDark: isDark),
              const SizedBox(width: 8),
              _Badge(
                label: '\$${gem.price.toStringAsFixed(2)}',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool isDark;

  const _Badge({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}
