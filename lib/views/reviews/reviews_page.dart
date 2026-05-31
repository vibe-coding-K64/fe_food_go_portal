import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../data/services/review_api_service.dart';
import 'package:intl/intl.dart';
import '../../data/models/store_model.dart';
import '../../data/services/store_api_service.dart';
import '../../data/services/auth_service.dart';
class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}


class _ReviewsPageState extends State<ReviewsPage> {
  int _filterStar = 0;
  List<Review> _reviews = [];
  bool _isLoading = true;
  final ReviewApiService _apiService = ReviewApiService();
  final StoreApiService _storeApiService = StoreApiService();
  final AuthService _authService = AuthService();
  String? _currentStoreId;
  Store? _currentStore;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      if (_currentStoreId == null) {
        _currentStoreId = await _authService.getStoreId();
      }
      if (_currentStoreId == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final storeFuture = _storeApiService.getStoreById(_currentStoreId!);
      final reviewsFuture = _apiService.getStoreReviews(_currentStoreId!);
      final results = await Future.wait([storeFuture, reviewsFuture]);
      
      setState(() {
        _currentStore = results[0] as Store;
        _reviews = results[1] as List<Review>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  List<Review> get _filtered => _filterStar == 0
      ? _reviews
      : _reviews.where((r) => r.rating.round() == _filterStar).toList();

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
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

  Map<int, int> get _ratingCounts {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      final int ratingInt = r.rating.round();
      if (counts.containsKey(ratingInt)) {
        counts[ratingInt] = (counts[ratingInt] ?? 0) + 1;
      }
    }
    return counts;
  }

  Widget _starDistribution() {
    final counts = _ratingCounts;
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

  Widget _buildReviewCard(int index, Review review) {
    bool hasReplied = review.merchantReply != null && review.merchantReply!.isNotEmpty;
    String dateStr = review.createdAt != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(review.createdAt!) 
        : 'Không rõ';

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
                child: Text(
                  review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating.round() ? Icons.star : Icons.star_outline,
                  color: Colors.amber, size: 16,
                )),
              ),
              if (hasReplied)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Đã phản hồi', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.5)),
          if (hasReplied) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(top: 12, left: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(_currentStore?.avtUrl ?? 'https://cdn-icons-png.flaticon.com/512/1904/1904428.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(_currentStore?.name ?? 'Cửa hàng FoodGo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE65100))),
                      const Spacer(),
                      if (review.repliedAt != null)
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(review.repliedAt!.toLocal()), style: const TextStyle(color: Colors.black45, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review.merchantReply!, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (!hasReplied && review.id != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showReplyDialog(context, index, review),
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

  void _showReplyDialog(BuildContext context, int index, Review review) {
    final ctrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Phản hồi đánh giá'),
            content: SizedBox(
              width: 400,
              child: TextFormField(
                controller: ctrl,
                maxLines: 4,
                autofocus: true,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Cảm ơn bạn đã ủng hộ quán...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx), 
                child: const Text('Hủy')
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (ctrl.text.trim().isEmpty) return;
                  setDialogState(() => isSubmitting = true);
                  try {
                    final updatedReview = await _apiService.replyReview(review.id!, ctrl.text.trim());
                    setState(() {
                      int targetIndex = _reviews.indexWhere((r) => r.id == review.id);
                      if (targetIndex != -1) {
                        _reviews[targetIndex] = updatedReview;
                      }
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    setDialogState(() => isSubmitting = false);
                    if (ctx.mounted) {
                      _showNotification(ctx, e.toString(), false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Gửi phản hồi'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showNotification(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: const Text('Đóng'),
            )
          ],
        ),
      )
    );
  }
}
