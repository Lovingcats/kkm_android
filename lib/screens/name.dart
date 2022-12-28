import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kkm/common/common.dart';
import 'package:kkm/data/my_loaction.dart';
import 'package:kkm/provider/user.dart';
import 'package:kkm/screens/bottom/bottom.dart';
import 'package:http/http.dart' as http;
import 'package:kpostal/kpostal.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class Name extends StatefulWidget {
  const Name({super.key});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final _nameController = TextEditingController();

  String postCode = '-';
  String address = '-';
  double latitude = 0.0;
  double longitude = 0.0;
  String kakaoLatitude = '-';
  String kakaoLongitude = '-';

  var dio = Dio();

  void errormessage() {
    Fluttertoast.showToast(
        msg: "회원가입에 실패하셨습니다. 다시 시도해주세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.sp);
  }

  void successmessage() {
    Fluttertoast.showToast(
        msg: "회원가입에 성공하셨습니다!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.sp);
  }

  void postrequest(var userdata) async {
    try {
      String uri = 'http://3.38.220.42:3031/user/join';
      // ignore: prefer_collection_literals
      Map<String, String> headers = <String, String>{
        'Authorization': 'Basic ${base64Encode(utf8.encode('user:password'))}'
      };

      var map = Map<String, dynamic>();
      print("user_id : 0");
      print('nickname : ${_nameController.text}');
      print('k_id : ${userdata.userId}');
      print('k_img_url : ${userdata.userImage}');
      print('lat : ${latitude}');
      print('lon : $longitude');
      print('address : $address');
      map['user_id'] = '0';
      map['nickname'] = _nameController.text;
      map['k_id'] = userdata.userId;
      map['k_img_url'] = userdata.userImage;
      map['lat'] = '$latitude';
      map['lon'] = '$longitude';
      map['address'] = address;
      map['kkm'] = '0';
      http.Response response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: map,
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        successmessage();
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Bottombar()));
      } else {
        errormessage();
      }
      // userdata.inputAccessToken();

    } catch (e) {
      print(e);
    }
  }

  void getLocation() async {
    MyLocation myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    latitude = myLocation.latitude2;
    longitude = myLocation.longitude2;
  }

  void FlutterDialog(var userdata) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: [
                Text("정말 닉네임을",
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _nameController.text,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.sp,
                          color: Colors.black),
                    ),
                    Text(
                      " 으로 하실 건가요?",
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                )
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "닉네임은 이후에 변경 가능합니다",
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff8E8E8F)),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("확인"),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KpostalView(
                        useLocalServer: true,
                        localPort: 1024,
                        callback: (Kpostal result) {
                          setState(() {
                            this.postCode = result.postCode;
                            this.address = result.address;
                            this.kakaoLatitude =
                                result.kakaoLatitude.toString();
                            this.kakaoLongitude =
                                result.kakaoLongitude.toString();
                          });

                          FlutterDialog1(userdata);
                          FlutterDialog1(userdata);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        });
  }

  void FlutterDialog1(var userdata) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: [
                Text("회원가입 하시겠습니까?",
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  address,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff8E8E8F)),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("확인"),
                onPressed: () {
                  postrequest(userdata);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserData>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 22.h,
              color: Colors.black,
            ),
          ),
          title: Text(
            "닉네임 설정",
            style: TextStyle(
                fontSize: 22.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
          elevation: 0.0,
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 195.h, bottom: 12.h, left: 22.w),
                    child: Text(
                      "닉네임을 설정해주세요",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff8E8E8F)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: const Color(0xffF5F5F5),
                      border: Border.all(
                        color: const Color(0xffF5F5F5),
                        width: 2.0.w,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(13.r))),
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 16.w,
                            top: _nameController.text == "" ? 0.h : 16.h),
                        hintText: '멋진 닉네임을 지어보세요!',
                        hintStyle: TextStyle(
                            fontSize: 16.sp, color: const Color(0xff8E8E8F)),
                        border: InputBorder.none,
                        suffixIcon: _nameController.text == ""
                            ? null
                            : IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _nameController.clear();
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                                icon: const Icon(Icons.cancel_outlined))),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 53.h),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(320.w, 50.h),
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        backgroundColor: CommonColor.blue),
                    onPressed: _nameController.text == ""
                        ? null
                        : () {
                            print("실행됨");
                            FlutterDialog(userData);
                          },
                    child: Text(
                      "다음",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
