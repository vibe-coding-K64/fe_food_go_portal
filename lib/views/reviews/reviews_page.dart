import 'package:flutter/material.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  int _filterStar = 0;
  final List<Map<String, dynamic>> _reviews = [
    {'customer': 'Nguyễn Văn A', 'rating': 5, 'comment': 'Món ngon lắm, giao hàng nhanh!', 'date': '18/05/2025', 'replied': false, 'images': 2},
    {'customer': 'Trần Thị B', 'rating': 4, 'comment': 'Đồ ăn ngon nhưng giao hơi lâu một chút.', 'date': '17/05/2025', 'replied': true, 'images': 0},
    {'customer': 'Lê Văn C', 'rating': 2, 'comment': 'Thiếu món, phục vụ cần cải thiện thêm.', 'date': '16/05/2025', 'replied': false, 'images': 1},
    {'customer': 'Phạm Thị D', 'rating': 5, 'comment': 'Rất hài lòng, sẽ ủng hộ tiếp!', 'date': '15/05/2025', 'replied': true, 'images': 0},
  ];

  List<Map<String, dynamic>> get _filtered => _filterStar == 0
      ? _reviews
      : _reviews.where((r) => r['rating'] == _filterStar).toList();

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r['rating'] as int).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Đánh giá & Phản hồi', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
        const SizedBox(height: 4),
        const Text('Xem và phản hồi đánh giá từ khách hàng', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 20),
        // Summary
        Row(
          children: [
            _ratingCard(),
            const SizedBox(width: 16),
            Expanded(child: _starDistribution()),
          ],
        ),
        const SizedBox(height: 20),
        // Filter
        Row(
          children: [
            const Text('Lọc theo sao:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            ...[0, 5, 4, 3, 2, 1].map((star) {
              final isSelected = _filterStar == star;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(star == 0 ? 'Tất cả' : '★ $star'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filterStar = star),
                  selectedColor: const Color(0xFFFF6B35),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade300)),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _buildReviewCard(i, _filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _ratingCard() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(_avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(
              i < _avgRating.round() ? Icons.star : Icons.star_outline,
              color: Colors.amber, size: 18,
            )),
          ),
          const SizedBox(height: 4),
          Text('${_reviews.length} đánh giá', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _starDistribution() {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) counts[r['rating'] as int] = (counts[r['rating'] as int] ?? 0) + 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [5, 4, 3, 2, 1].map((star) {
          final count = counts[star] ?? 0;
          final ratio = _reviews.isEmpty ? 0.0 : count / _reviews.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text('$star ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: ratio, backgroundColor: Colors.grey.shade200, color: Colors.amber, minHeight: 8),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 20, child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(int index, Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFF3E0),
                child: Text(review['customer'].toString()[0],
                    style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(review['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < (review['rating'] as int) ? Icons.star : Icons.star_outline,
                  color: Colors.amber, size: 16,
                )),
              ),
              if (review['replied'])
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Đã phản hồi', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review['comment'], style: const TextStyle(fontSize: 14, height: 1.5)),
          if ((review['images'] as int) > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.photo_library_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${review['images']} ảnh đính kèm', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (!review['replied'])
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showReplyDialog(context, index),
                  icon: const Icon(Icons.reply_outlined, size: 16),
                  label: const Text('Phản hồi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, int index) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Phản hồi đánh giá'),
        content: SizedBox(
          width: 400,
          child: TextFormField(
            controller: ctrl,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cảm ơn bạn đã ủng hộ quán...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() => _reviews[index]['replied'] = true);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Gửi phản hồi'),
          ),
        ],
      ),
    );
  }
}
