import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/controllers/mistake_repository.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake.dart';

class MistakeMainPage extends StatefulWidget {
  const MistakeMainPage({super.key});
  static const String routeName = '/mistake_main_page';

  @override
  State<MistakeMainPage> createState() => _MistakeMainPageState();
}

class _MistakeMainPageState extends State<MistakeMainPage> {
  late Future<List<ClassMistakeModel>> futureMistakeClass;
  final MistakeRepository mistakeRepository = MistakeRepository();
  String? selectedYear;
  String? selectedHocKy;
  Map<String, List<ClassMistakeModel>> cachedData = {};

  @override
  void initState() {
    super.initState();
    futureMistakeClass = fetchFilteredMistakeClassesByK('10');
    int currentMonth = DateTime.now().month;
    if (currentMonth >= 9 && currentMonth <= 12) {
      selectedHocKy = 'Học kỳ 1';
    } else {
      selectedHocKy = 'Học kỳ 2';
    }
  }

  Future<List<ClassMistakeModel>> fetchFilteredMistakeClassesByK(
      String classFilter) async {
    List<ClassMistakeModel> mistakes;
    if (selectedYear != null) {
      mistakes = await mistakeRepository
          .fetchFilteredMistakeClassesByK(classFilter: classFilter)
          .then(
            (mistakes) => mistakes
                .where((mistake) => mistake.academicYear == selectedYear)
                .toList(),
          );
    } else {
      mistakes = await mistakeRepository.fetchFilteredMistakeClassesByK(
          classFilter: classFilter);
    }

    setState(() {
      cachedData[classFilter] = mistakes;
    });
    return mistakes;
  }

  void updateClass(String classFilter) {
    setState(() {
      futureMistakeClass = fetchFilteredMistakeClassesByK(classFilter);
    });
  }

  Future<void> _refreshData(String classFilter) async {
    setState(() {
      futureMistakeClass = fetchFilteredMistakeClassesByK(classFilter);
    });
    await futureMistakeClass;
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;

    return AppBarWidget(
      titleString: 'Cập Nhật Vi Phạm',
      implementLeading: true,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Học kỳ',
                  items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'],
                  selectedItem: selectedHocKy,
                  onChanged: (newValue) {
                    setState(() {
                      selectedHocKy = newValue;
                      updateClass('10');
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Năm học',
                  items: years,
                  selectedItem: selectedYear,
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue;
                      updateClass('10');
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            style: const TextStyle(fontSize: 18, color: Color(0xFF2F4F4F)),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              hintStyle: const TextStyle(
                  color: Color(0xFF696969),
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.search_outlined,
                    color: Color(0xFF1E90FF), size: 24),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFD3D3D3), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF1E90FF), width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Lớp 10'),
                      Tab(text: 'Lớp 11'),
                      Tab(text: 'Lớp 12'),
                    ],
                    indicatorColor: Theme.of(context).primaryColor,
                    onTap: (index) {
                      String classFilter = (index + 10).toString();
                      updateClass(classFilter);
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildFutureBuilder(classFilter: '10'),
                        buildFutureBuilder(classFilter: '11'),
                        buildFutureBuilder(classFilter: '12'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFutureBuilder({required String classFilter}) {
    return RefreshIndicator(
      onRefresh: () => _refreshData(classFilter),
      child: FutureBuilder<List<ClassMistakeModel>>(
        future: fetchFilteredMistakeClassesByK(classFilter),
        builder: (context, snapshot) {
          final displayData =
              snapshot.connectionState == ConnectionState.waiting &&
                      cachedData[classFilter] != null
                  ? cachedData[classFilter]
                  : snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting &&
              cachedData[classFilter] == null) {
            return _buildLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString(), classFilter);
          }
          if (displayData == null || displayData.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: displayData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ItemClassModels(
                classMistakeModel: displayData[index],
                hocKy: selectedHocKy ?? 'Học kỳ 1',
                onRefresh: () => _refreshData(classFilter), // Truyền callback
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, String classFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Có lỗi xảy ra: $error', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshData(classFilter),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
