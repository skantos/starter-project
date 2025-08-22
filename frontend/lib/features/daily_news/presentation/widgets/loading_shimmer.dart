import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _ShimmerCard(),
        );
      }),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      height: MediaQuery.of(context).size.width / 2.4,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: double.infinity, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 16, width: double.infinity, color: Colors.grey.shade300),
                const Spacer(),
                Container(height: 12, width: 120, color: Colors.grey.shade300),
              ],
            ),
          )
        ],
      ),
    );
  }
}


