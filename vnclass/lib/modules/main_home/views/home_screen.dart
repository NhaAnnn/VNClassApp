import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar_container.dart';
import 'package:vnclass/modules/login/widget/item_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: AppBarContainer(
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      24,
                    ),
                  ),
                  child: ImageHelper.loadFromAsset(
                      AssetHelper.imageLogoSplashScreen),
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello Suong',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Position',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  FontAwesomeIcons.bell,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          implementLeading: true,
          child: Container(
            //margin: EdgeInsets.only(top: 20),
            color: ColorApp.primaryColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // TextField(
                  //   decoration: InputDecoration(
                  //     hintText: 'hl',
                  //     prefixIcon: Padding(
                  //       padding: EdgeInsets.all(12),
                  //       child: Icon(
                  //         FontAwesomeIcons.magnifyingGlass,
                  //         color: Colors.black,
                  //         size: 16,
                  //       ),
                  //     ),
                  //     filled: true,
                  //     fillColor: Colors.amberAccent,
                  //     border: OutlineInputBorder(
                  //       borderSide: BorderSide.none,
                  //       borderRadius: BorderRadius.all(
                  //         Radius.circular(
                  //           4,
                  //         ),
                  //       ),
                  //     ),
                  //     contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  ItemHome(
                    // onTap: () => Navigator.of(context)
                    //     .pushNamed(ClassGeneralMistake.routeName),
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham ss',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                  ItemHome(
                    icon: AssetHelper.imageLogoSplashScreen,
                    title: 'Cap Nhat Vi Pham',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
