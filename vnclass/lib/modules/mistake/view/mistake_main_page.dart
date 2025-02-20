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

  @override
  void initState() {
    super.initState();
    // Initialize with class 10 by default
    futureMistakeClass = fetchFilteredMistakeClassesByK('10');
    int currentMonth = DateTime.now().month;

    if (currentMonth >= 9 && currentMonth <= 12) {
      selectedHocKy = 'Học kỳ 1';
    } else {
      selectedHocKy = 'Học kỳ 2';
    }
  }

  Future<List<ClassMistakeModel>> fetchFilteredMistakeClassesByK(
      String classFilter) {
    if (selectedYear != null) {
      return mistakeRepository
          .fetchFilteredMistakeClassesByK(classFilter: classFilter)
          .then((mistakes) {
        return mistakes
            .where((mistake) => mistake.academicYear == selectedYear)
            .toList();
      });
    } else {
      return mistakeRepository.fetchFilteredMistakeClassesByK(
          classFilter: classFilter);
    }
  }

  void updateClass(String classFilter) {
    setState(() {
      futureMistakeClass = fetchFilteredMistakeClassesByK(classFilter);
    });
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
          SizedBox(height: 20),
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
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Năm học',
                  items: years,
                  selectedItem: selectedYear,
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue;
                      // Update data when year is changed
                      updateClass(selectedHocKy ??
                          '10'); // Default to class 10 if hocKy is null
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              filled: true,
              fillColor: Colors.white,

              // Thêm viền bên ngoài
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue, // Màu viền
                  width: 2.0, // Độ dày viền
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueAccent, // Màu viền khi focus
                  width: 2.0, // Độ dày viền
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: DefaultTabController(
              length: 3, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Lớp 10'),
                      Tab(text: 'Lớp 11'),
                      Tab(text: 'Lớp 12'),
                    ],
                    indicatorColor: Theme.of(context).primaryColor,
                    onTap: (index) {
                      // Fetch data based on selected tab
                      String classFilter =
                          (index + 10).toString(); // '10', '11', '12'
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
    return Center(
      child: FutureBuilder<List<ClassMistakeModel>>(
        future: fetchFilteredMistakeClassesByK(classFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Có lỗi xảy ra: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Không có dữ liệu');
          }

          return ListView(
            children: snapshot.data!
                .map((e) => ItemClassModels(
                      classMistakeModel: e,
                      hocKy: selectedHocKy ?? '1',
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
