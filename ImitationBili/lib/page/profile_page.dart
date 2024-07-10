import 'package:flutter/material.dart';
import 'package:flutter_bili_app/http/core/hi_error.dart'; // 导入自定义的网络请求错误类
import 'package:flutter_bili_app/http/dao/profile_dao.dart'; // 导入用户资料数据访问对象
import 'package:flutter_bili_app/model/profile_mo.dart'; // 导入用户资料数据模型
import 'package:flutter_bili_app/util/toast.dart'; // 导入消息提示工具
import 'package:flutter_bili_app/util/view_util.dart'; // 导入视图工具
import 'package:flutter_bili_app/widget/dark_mode_item.dart'; // 导入暗模式选项组件
import 'package:flutter_bili_app/widget/hi_banner.dart'; // 导入高斯模糊背景组件
import 'package:flutter_bili_app/widget/hi_blur.dart'; // 导入高斯模糊组件
import 'package:flutter_bili_app/widget/hi_flexible_header.dart'; // 导入可伸缩头部组件

/// 我的页面
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  ProfileMo? _profileMo; // 用户资料模型对象
  ScrollController _controller = ScrollController(); // 滚动控制器

  @override
  void initState() {
    super.initState();
    _loadData(); // 加载用户数据
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[_buildAppBar()]; // 构建AppBar
        },
        body: ListView(
          padding: EdgeInsets.only(top: 10),
          children: [..._buildContentList()], // 构建页面内容列表
        ),
      ),
    );
  }

  void _loadData() async {
    try {
      ProfileMo result = await ProfileDao.get(); // 获取用户资料
      print(result); // 打印获取的用户资料
      setState(() {
        _profileMo = result; // 更新用户资料模型对象
      });
    } on NeedAuth catch (e) {
      print(e); // 捕获需要授权异常并打印
      showWarnToast(e.message); // 显示警告提示信息
    } on HiNetError catch (e) {
      print(e); // 捕获网络异常并打印
      showWarnToast(e.message); // 显示警告提示信息
    }
  }

  _buildHead() {
    if (_profileMo == null) return Container(); // 如果用户资料为空，则返回空容器
    return HiFlexibleHeader(
        // 构建可伸缩头部
        name: _profileMo!.name, // 显示用户姓名
        face: _profileMo!.face, // 显示用户头像
        controller: _controller);
  }

  @override
  bool get wantKeepAlive => true;

  _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160, // 扩展高度
      pinned: true, // 标题栏是否固定
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax, // 折叠模式
        titlePadding: EdgeInsets.only(left: 0),
        title: _buildHead(), // 构建头部视图
        background: Stack(
          children: [
            Positioned.fill(child: cachedImage(// 加载缓存的图片
                'https://www.devio.org/img/beauty_camera/beauty_camera4.jpg')),
            Positioned.fill(child: HiBlur(sigma: 20)), // 高斯模糊背景
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildProfileTab()), // 构建用户资料选项卡
          ],
        ),
      ),
    );
  }

  _buildContentList() {
    if (_profileMo == null) {
      return []; // 如果用户资料为空，则返回空列表
    }
    return [
      DarkModelItem() // 构建暗模式选项
    ];
  }

  _buildProfileTab() {
    if (_profileMo == null) return Container(); // 如果用户资料为空，则返回空容器
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(color: Colors.white54),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconText('收藏', _profileMo!.favorite), // 构建收藏图标和文本
          _buildIconText('点赞', _profileMo!.like), // 构建点赞图标和文本
          _buildIconText('浏览', _profileMo!.browsing), // 构建浏览图标和文本
          _buildIconText('金币', _profileMo!.coin), // 构建金币图标和文本
          _buildIconText('粉丝', _profileMo!.fans), // 构建粉丝图标和文本
        ],
      ),
    );
  }

  _buildIconText(String text, int count) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(fontSize: 15, color: Colors.black87)), // 显示统计数字
        Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])), // 显示文本标签
      ],
    );
  }
}
