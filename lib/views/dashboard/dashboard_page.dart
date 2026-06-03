import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/order_api_service.dart';
import '../../data/services/product_api_service.dart';

// Lớp Mock cho OrderModel để giao diện hoạt động độc lập
class OrderModel {
  final String id;
  final String code;
  final DateTime orderDate;
  final int itemCount;
  final String orderStatus;
  final double totalAmount;
  final int paymentStatus;

  OrderModel({
    required this.id,
    required this.code,
    required this.orderDate,
    required this.itemCount,
    required this.orderStatus,
    required this.totalAmount,
    required this.paymentStatus,
  });
}

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});
  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  bool isLoading = true;
  double totalSale = 0;
  double avgOrderValue = 0;
  int totalOrders = 0;
  int soldProducts = 0;
  Map<String, int> statusCount = {};
  List<OrderModel> recentOrders = [];
  List<OrderModel> allOrders = [];
  List<Map<String, dynamic>> topProducts = [];
  String _chartPeriod = 'Tuần';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    loadDashboard();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) loadDashboard(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDashboard({bool isPolling = false}) async {
    if (!isPolling && mounted) setState(() => isLoading = true);
    try {
      final storeId = await AuthService().getStoreId();
      if (storeId == null) throw 'Không tìm thấy storeId';

      final realOrders = await OrderApiService().getOrdersByStoreId(storeId);
      final storeProducts = await ProductApiService().getAllProducts(storeId);
      
      Map<String, Map<String, dynamic>> itemCountsMap = {};
      
      allOrders = realOrders.map((o) {
        int itemsCount = 0;
        for (var item in o.items) {
          itemsCount += item.quantity;
          
          if (!itemCountsMap.containsKey(item.name)) {
            // Find product in storeProducts
            final matchedProd = storeProducts.where((p) => p.name == item.name).firstOrNull;
            itemCountsMap[item.name] = {
              'name': item.name,
              'sales': 0,
              'imageUrl': matchedProd?.imageUrl ?? item.imageUrl, // Fallback to item image
              'rating': matchedProd?.rating ?? 5.0, // Default to 5.0 if not found
            };
          }
          itemCountsMap[item.name]!['sales'] = (itemCountsMap[item.name]!['sales'] as int) + item.quantity;
        }
        // Tính doanh thu: Tổng tiền món ăn trừ đi voucher (không tính phí ship)
        double income = o.totalAmount - o.discountAmount;
        
        return OrderModel(
          id: o.id ?? '',
          code: o.code,
          orderDate: o.createdAt ?? DateTime.now(),
          itemCount: itemsCount,
          orderStatus: o.status, 
          totalAmount: income,
          paymentStatus: o.paymentStatus,
        );
      }).toList();

      var sortedProducts = itemCountsMap.values.toList()
        ..sort((a, b) => (b['sales'] as int).compareTo(a['sales'] as int));
      topProducts = sortedProducts.take(3).toList();

      totalOrders = allOrders.length;
      final completedPaidOrders = allOrders.where((o) => (o.orderStatus == 'Hoàn thành' || o.orderStatus == '3') && o.paymentStatus == 2).toList();
      totalSale = completedPaidOrders.fold(0, (sum, order) => sum + order.totalAmount);
      soldProducts = completedPaidOrders.fold(0, (sum, order) => sum + order.itemCount);
      avgOrderValue = completedPaidOrders.isEmpty ? 0 : totalSale / completedPaidOrders.length;

      statusCount.clear();
      for (var order in allOrders) {
        final status = order.orderStatus;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
      
      // Sắp xếp đơn hàng mới nhất lên đầu
      allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      recentOrders = allOrders.take(5).toList();

    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String money(double value) {
    return NumberFormat("#,###").format(value);
  }

  String formatCompact(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(value % 1000000000 == 0 ? 0 : 1)}B';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    return value.toStringAsFixed(0);
  }

  String translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return "Mới tạo";
      case 'pending':
        return "Chờ xử lý";
      case 'processing':
        return "Đang chuẩn bị";
      case 'shipped':
        return "Đang giao";
      case 'delivered':
        return "Đã giao";
      case 'cancelled':
      case 'canceled':
        return "Đã hủy";
      case 'returned':
        return "Trả hàng";
      case 'refunded':
        return "Hoàn tiền";
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created': case 'mới tạo':
        return Colors.blue;
      case 'pending': case 'chờ xử lý': case 'chờ xác nhận':
        return Colors.orange;
      case 'processing': case 'đang chuẩn bị':
        return Colors.purple;
      case 'shipped': case 'đang giao':
        return Colors.indigo;
      case 'delivered': case 'đã giao': case 'hoàn thành':
        return Colors.green;
      case 'cancelled': case 'canceled': case 'đã hủy':
        return Colors.red;
      case 'returned': case 'trả hàng':
        return Colors.blueGrey;
      case 'refunded': case 'hoàn tiền':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TIÊU ĐỀ DASHBOARD
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  "Quản Trị Quán Ăn",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            /// 4 THẺ THỐNG KÊ NẰM TRÊN 1 HÀNG NGANG
            Row(
              children: [
                Expanded(
                  child: statCard(
                    "Tổng Doanh Thu",
                    money(totalSale),
                    Icons.monetization_on_rounded,
                    [Colors.blue, Colors.blueAccent],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: statCard(
                    "Giá Trị TB",
                    money(avgOrderValue),
                    Icons.auto_graph_rounded,
                    [Colors.purple, Colors.deepPurpleAccent],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: statCard(
                    "Tổng Đơn",
                    totalOrders.toString(),
                    Icons.shopping_bag_rounded,
                    [Colors.orange, Colors.orangeAccent],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: statCard(
                    "Đã Bán",
                    soldProducts.toString(),
                    Icons.inventory_2_rounded,
                    [Colors.teal, Colors.greenAccent],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            /// BỐ CỤC CHI TIẾT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CỘT TRÁI
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      cardContainer(
                        title: "Phân Tích Doanh Thu",
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _chartPeriod,
                              isDense: true,
                              items: ['Tuần', 'Tháng', 'Năm'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _chartPeriod = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: 300,
                          child: LineChart(mainLineData()),
                        ),
                      ),
                      const SizedBox(height: 25),
                      cardContainer(
                        title: "Đơn Hàng Gần Đây",
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.grey[50],
                            ),
                            horizontalMargin: 10,
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Mã Đơn",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Ngày",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Số Lượng",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Trạng Thế",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Tổng Tiền",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: recentOrders
                                .map(
                                  (o) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text("#${o.code}"),
                                      ),
                                      DataCell(
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm').format(o.orderDate),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(o.itemCount.toString()),
                                        ),
                                      ),
                                      DataCell(statusChip(translateStatus(o.orderStatus))),
                                      DataCell(
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${money(o.totalAmount)}đ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              o.paymentStatus == 2 ? 'Đã thanh toán' : 'Chưa thanh toán',
                                              style: TextStyle(
                                                color: o.paymentStatus == 2 ? Colors.green : Colors.orange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      cardContainer(
                        title: "Sản Phẩm Bán Chạy",
                        child: _buildTopProducts(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 25),

                /// CỘT PHẢI
                Expanded(
                  flex: 2,
                  child: cardContainer(
                    title: "Thống Kê Trạng Thái",
                    child: Column(
                      children: [
                        SizedBox(
                          height: 280,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              sections: buildStatusSections(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...statusCount.entries
                            .map((e) => statusRow(translateStatus(e.key), e.value))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ===== CÁC COMPONENT GIAO DIỆN =====
  Widget statCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 50, color: Colors.white.withOpacity(0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cardContainer({required String title, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3238),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget statusChip(String status) {
    Color color = getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget statusRow(String status, int count) {
    Color color = getStatusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// ===== DATA & CHARTS =====
  LineChartData mainLineData() {
    return LineChartData(
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey[100], strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == meta.max) return const SizedBox(); // Prevent overlapping at the top
              return Text(
                formatCompact(value),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1, // Fix repeating labels
            getTitlesWidget: (value, meta) {
              List<String> titles;
              if (_chartPeriod == 'Năm') {
                titles = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"];
              } else if (_chartPeriod == 'Tháng') {
                titles = ["Tuần 1", "Tuần 2", "Tuần 3", "Tuần 4"];
              } else {
                titles = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
              }
              if (value.toInt() >= 0 && value.toInt() < titles.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    titles[value.toInt()],
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: buildChartSpots(),
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: const LinearGradient(colors: [Colors.blue, Colors.cyan]),
          barWidth: 4,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.15),
                Colors.blue.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> buildChartSpots() {
    if (_chartPeriod == 'Năm') return buildYearlySpots();
    if (_chartPeriod == 'Tháng') return buildMonthlySpots();
    return buildWeeklySpots();
  }

  List<FlSpot> buildYearlySpots() {
    Map<int, double> monthlySales = {for (int i = 1; i <= 12; i++) i: 0};
    DateTime now = DateTime.now();
    for (var order in allOrders) {
      if ((order.orderStatus == 'Hoàn thành' || order.orderStatus == '3') && order.paymentStatus == 2) {
        if (order.orderDate.year == now.year) {
          monthlySales[order.orderDate.month] = (monthlySales[order.orderDate.month] ?? 0) + order.totalAmount;
        }
      }
    }
    return List.generate(12, (index) => FlSpot(index.toDouble(), monthlySales[index + 1]!));
  }

  List<FlSpot> buildMonthlySpots() {
    Map<int, double> weeklySales = {1: 0, 2: 0, 3: 0, 4: 0};
    DateTime now = DateTime.now();
    for (var order in allOrders) {
      if ((order.orderStatus == 'Hoàn thành' || order.orderStatus == '3') && order.paymentStatus == 2) {
        if (order.orderDate.year == now.year && order.orderDate.month == now.month) {
          int week = ((order.orderDate.day - 1) / 7).floor() + 1;
          if (week > 4) week = 4; // Group days 29, 30, 31 into week 4
          weeklySales[week] = (weeklySales[week] ?? 0) + order.totalAmount;
        }
      }
    }
    return List.generate(4, (index) => FlSpot(index.toDouble(), weeklySales[index + 1]!));
  }

  List<FlSpot> buildWeeklySpots() {
    Map<int, double> weekdaySales = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    for (var order in allOrders) {
      if ((order.orderStatus == 'Hoàn thành' || order.orderStatus == '3') && order.paymentStatus == 2) {
        if (order.orderDate.isAfter(startOfWeek) || order.orderDate.isAtSameMomentAs(startOfWeek)) {
          int weekday = order.orderDate.weekday; // 1 = T2, 7 = CN
          weekdaySales[weekday] = (weekdaySales[weekday] ?? 0) + order.totalAmount;
        }
      }
    }

    return List.generate(
      7,
      (index) => FlSpot(index.toDouble(), weekdaySales[index + 1]!),
    );
  }

  List<PieChartSectionData> buildStatusSections() {
    return statusCount.entries.map((e) {
      return PieChartSectionData(
        color: getStatusColor(e.key),
        value: e.value.toDouble(),
        title:
            '${((e.value / (totalOrders == 0 ? 1 : totalOrders)) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTopProducts() {
    if (topProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20), 
          child: Text("Chưa có đơn hàng nào")
        )
      );
    }
    List<Widget> children = [];
    final colors = [Colors.orange, Colors.blue, Colors.purple];
    for (int i = 0; i < topProducts.length; i++) {
      final p = topProducts[i];
      children.add(_topProductRow(
        p['name'], 
        "${p['sales']} lượt bán", 
        "${p['rating']}/5", 
        colors[i % colors.length],
        p['imageUrl']
      ));
      if (i < topProducts.length - 1) children.add(const Divider(height: 20));
    }
    return Column(children: children);
  }

  Widget _topProductRow(String name, String sales, String rating, Color color, String? imageUrl) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              )
            : Icon(Icons.fastfood, color: color),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                sales,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
