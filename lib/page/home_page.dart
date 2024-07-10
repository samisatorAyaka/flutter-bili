import 'package:flutter/material.dart';
import 'package:flutter_bili_app/core/hi_state.dart';
import 'package:flutter_bili_app/http/core/hi_error.dart';
import 'package:flutter_bili_app/http/dao/home_dao.dart';
import 'package:flutter_bili_app/model/home_mo.dart';
import 'package:flutter_bili_app/navigator/hi_navigator.dart';
import 'package:flutter_bili_app/page/home_tab_page.dart';
import 'package:flutter_bili_app/page/profile_page.dart';
import 'package:flutter_bili_app/page/video_detail_page.dart';
import 'package:flutter_bili_app/provider/theme_provider.dart';
import 'package:flutter_bili_app/util/toast.dart';
import 'package:flutter_bili_app/util/view_util.dart';
import 'package:flutter_bili_app/widget/hi_tab.dart';
import 'package:flutter_bili_app/widget/loading_container.dart';
import 'package:flutter_bili_app/widget/navigation_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onJumpTo;

  const HomePage({Key? key, this.onJumpTo}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends HiState<HomePage>
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        WidgetsBindingObserver {
  var listener;
  late TabController _controller;
  List<CategoryMo> categoryList = [];
  List<BannerMo> bannerList = [];
  bool _isLoading = true;
  Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controller = TabController(length: categoryList.length, vsync: this);
    HiNavigator.getInstance().addListener(this.listener = (current, pre) {
      this._currentPage = current.page;
      print('home:current:${current.page}');
      print('home:pre:${pre.page}');
      if (widget == current.page || current.page is HomePage) {
        print('打开了首页:onResume');
      } else if (widget == pre?.page || pre?.page is HomePage) {
        print('首页:onPause');
      }
      //当页面返回到首页恢复首页的状态栏样式
      if (pre?.page is VideoDetailPage && !(current.page is ProfilePage)) {
        var statusStyle = StatusStyle.DARK_CONTENT;
        changeStatusBar(color: Colors.white, statusStyle: statusStyle);
      }
    });
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    HiNavigator.getInstance().removeListener(this.listener);
    _controller.dispose();
    super.dispose();
  }

  ///监听系统Dark Mode变化
  @override
  void didChangePlatformBrightness() {
    context.read<ThemeProvider>().darModeChange();
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(':didChangeAppLifecycleState:$state');
    switch (state) {
      case AppLifecycleState.inactive:
        // Handle inactive state
        break;
      case AppLifecycleState.resumed:
        // Handle resumed state
        changeStatusBar();
        break;
      case AppLifecycleState.paused:
        // Handle paused state
        break;
      case AppLifecycleState.detached:
        // Handle detached state
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state (add your logic here)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: LoadingContainer(
        isLoading: _isLoading,
        child: Column(
          children: [
            NavigationBarPlus(
              height: 50,
              child: _appBar(),
              color: Colors.white,
              statusStyle: StatusStyle.DARK_CONTENT,
            ),
            Container(
              decoration: bottomBoxShadow(context),
              child: _tabBar(),
            ),
            Flexible(
                child: TabBarView(
                    controller: _controller,
                    children: categoryList.map((tab) {
                      return HomeTabPage(
                          categoryName: tab.name,
                          bannerList: tab.name == '推荐' ? bannerList : null);
                    }).toList()))
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  ///自定义顶部tab
  _tabBar() {
    return HiTab(
      categoryList.map<Tab>((tab) {
        return Tab(
          text: tab.name,
        );
      }).toList(),
      controller: _controller,
      fontSize: 16,
      borderWidth: 3,
      unselectedLabelColor: Colors.black54,
      insets: 13,
    );
  }

  void loadData() async {
    try {
      HomeMo result = await HomeDao.get('推荐');
      print('loadData():$result');
      if (result.categoryList != null) {
        //tab长度变化后需要重新创建TabController
        _controller = TabController(
            length: result.categoryList?.length ?? 0, vsync: this);
      }
      setState(() {
        categoryList = result.categoryList ?? [];
        bannerList = result.bannerList ?? [];
        _isLoading = false;
      });
    } on NeedAuth catch (e) {
      print(e);
      showWarnToast(e.message);
      setState(() {
        _isLoading = false;
      });
    } on HiNetError catch (e) {
      print(e);
      showWarnToast(e.message);
      setState(() {
        _isLoading = false;
      });
    }
  }

  _appBar() {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (widget.onJumpTo != null) {
                widget.onJumpTo!(3);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image(
                height: 46,
                width: 46,
                image: AssetImage('images/avatar.png'),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.only(left: 10),
                height: 32,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.search, color: Colors.grey),
                decoration: BoxDecoration(color: Colors.grey[100]),
              ),
            ),
          )),
          Icon(
            Icons.explore_outlined,
            color: Colors.grey,
          ),
          InkWell(
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.notice);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.mail_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
