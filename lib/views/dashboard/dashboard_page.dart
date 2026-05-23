import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Lớp Mock cho OrderModel để giao diện hoạt động độc lập
class OrderModel {
  final String id;
  final DateTime orderDate;
  final int itemCount;
  final String orderStatus;
  final double totalAmount;

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.itemCount,
    required this.orderStatus,
    required this.totalAmount,
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

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    // Giả lập dữ liệu đơn hàng
    allOrders = [
      OrderModel(id: 'OD001', orderDate: DateTime.now().subtract(const Duration(hours: 2)), itemCount: 3, orderStatus: 'delivered', totalAmount: 215000),
      OrderModel(id: 'OD002', orderDate: DateTime.now().subtract(const Duration(hours: 5)), itemCount: 2, orderStatus: 'processing', totalAmount: 130000),
      OrderModel(id: 'OD003', orderDate: DateTime.now().subtract(const Duration(hours: 8)), itemCount: 1, orderStatus: 'pending', totalAmount: 89000),
      OrderModel(id: 'OD004', orderDate: DateTime.now().subtract(const Duration(days: 1)), itemCount: 4, orderStatus: 'delivered', totalAmount: 450000),
      OrderModel(id: 'OD005', orderDate: DateTime.now().subtract(const Duration(days: 2)), itemCount: 2, orderStatus: 'cancelled', totalAmount: 12000),
      OrderModel(id: 'OD006', orderDate: DateTime.now().subtract(const Duration(days: 3)), itemCount: 3, orderStatus: 'delivered', totalAmount: 310000),
      OrderModel(id: 'OD007', orderDate: DateTime.now().subtract(const Duration(days: 4)), itemCount: 1, orderStatus: 'delivered', totalAmount: 95000),
    ];

    totalOrders = allOrders.length;
    totalSale = allOrders.fold(0, (sum, order) => sum + order.totalAmount);
    soldProducts = allOrders.fold(0, (sum, order) => sum + order.itemCount);
    avgOrderValue = totalOrders == 0 ? 0 : totalSale / totalOrders;

    statusCount.clear();
    for (var order in allOrders) {
      final status = order.orderStatus;
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    recentOrders = allOrders.take(5).toList();

    setState(() {
      isLoading = false;
    });
  }

  String money(double value) {
    return NumberFormat("#,###").format(value);
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
      case 'created':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.blueGrey;
      case 'refunded':
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
                        title: "Phân Tích Doanh Thu Tuần",
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
                                        Text("#${o.id}"),
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
                                        Text(
                                          "${money(o.totalAmount)}đ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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

  Widget cardContainer({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3238),
            ),
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
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              money(value),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    days[value.toInt()],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
          spots: buildWeeklySpots(),
          isCurved: true,
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

  List<FlSpot> buildWeeklySpots() {
    Map<int, double> weekdaySales = {1: 150000, 2: 230000, 3: 450000, 4: 95000, 5: 310000, 6: 180000, 7: 500000};
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
    return Column(
      children: [
        _topProductRow("Burger Bò Đặc Biệt", "342 lượt bán", "4.8/5", Colors.orange),
        const Divider(height: 20),
        _topProductRow("Pizza Hải Sản Cao Cấp", "285 lượt bán", "4.7/5", Colors.blue),
        const Divider(height: 20),
        _topProductRow("Gà Rán Giòn Cay", "198 lượt bán", "4.9/5", Colors.purple),
      ],
    );
  }

  Widget _topProductRow(String name, String sales, String rating, Color color) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.fastfood, color: color),
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
