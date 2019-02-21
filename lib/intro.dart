import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  @override
  createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  final pageController = PageController();
  bool searchingProxy = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        pageController.previousPage(curve: Curves.easeInOut, duration: Duration(milliseconds: 500));
      },
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        children: <Widget>[
          welcomePage(),
          Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Отказ от ответственности", style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ ГАРАНТИИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО КАКИМ-ЛИБО ИСКАМ, ЗА УЩЕРБ ИЛИ ПО ИНЫМ ТРЕБОВАНИЯМ, В ТОМ ЧИСЛЕ, ПРИ ДЕЙСТВИИ КОНТРАКТА, ДЕЛИКТЕ ИЛИ ИНОЙ СИТУАЦИИ, ВОЗНИКШИМ ИЗ-ЗА ИСПОЛЬЗОВАНИЯ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫХ ДЕЙСТВИЙ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ."),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Colors.blueAccent,
                      child: Text("Согласен", style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        pageController.nextPage(curve: Curves.easeInOut, duration: Duration(milliseconds: 500));
                      }
                    ),
                  )
                ]
              ),
            )
          ),
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            body: Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Прокси", style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Есть вероятность, что в вашей стране сайт 'flibusta.is' заблокирован, в таком случае рекомендую использовать зеркало расположенное по адресу 'flibusta.appspot.com'. Если у Вас к нему тоже не будет доступа, пожалуйста, напишите отзыв. Желаете ли Вы его использовать или сами разберётесь?"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white,
                          child: Text("Сам разберусь", style: TextStyle(color: Colors.black),),
                          onPressed: () async {
                            await LocalStore().setIntroComplete();
                            await LocalStore().setUseFreeProxy(false);
                            Navigator.of(context).pop(true);
                          }
                        ),
                        searchingProxy ? 
                          Container(child: CircularProgressIndicator(), alignment: Alignment(0, 0), width: 150.0) : 
                          RaisedButton(
                          color: Colors.blueAccent,
                          disabledColor: Colors.grey,
                          child: Text("Использовать", style: TextStyle(color: Colors.white),),
                          onPressed: searchingProxy ? null : () async {
                            await LocalStore().setUseFreeProxy(false);
                            await LocalStore().setFlibustaHostAddress("flibusta.appspot.com");
                            ProxyHttpClient().setFlibustaHostAddress("flibusta.appspot.com");
                            await LocalStore().setIntroComplete();
                            Navigator.of(context).pop(true);
                          }
                        ),
                      ],
                    ),
                  )
                ]
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget welcomePage() {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Добро пожаловать!", style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                color: Colors.blueAccent,
                child: Text("Далее", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  pageController.nextPage(curve: Curves.easeInOut, duration: Duration(milliseconds: 500));
                }
              ),
            )
          ]
        ),
      )
    );
  }
}