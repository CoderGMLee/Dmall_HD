 (function(){
     if ("undefined" == typeof com) {
         com = {};
     }
     
     if ("undefined" == typeof com.dmall) {
         com.dmall = {};
     }

     /**
      * 当前类型封住了和App页面框架交互的接口
      */
     com.dmall.Navigator = {
         /**
          * 触发页面跳转
          * @param url 目标页面的URL,可携带参数,允许携带框架参数(参数名以@开头).例如: "app://page?param=value&@animate=pushleft" 或者 "http://dmall.com/page?param=value&@animate=pushleft"
          * @param pageCallback 页面回调函数
          *     页面回调函数将接受一个对象作为参数，该对象属性即为下一个页面返回的数据.
          *     例如:
          *     forward("app://page?param=value",function(data){
          *         var returnValue = data["returnKey"];
          *         // 处理页面回传参数
          *     });
          */
         forward : function(url,pageCallback) {
             if(pageCallback) {
                 com.dmall.Bridge.pageCallback = pageCallback;
             } else {
                 com.dmall.Bridge.pageCallback = function(){};
             }
             window.pageBridge.forward(url);
         },

         /**
          * 触发页面回退
          * @param param 可选返回参数，允许携带框架参数(参数名以@开头)。（例如"param=value&param2=value2&@animate=popright"）
          *     如果不传此参数，框架将在页面回退的同时不向上一个页面的回传数据。
          *     这样做的目的，是允许开发者在当前页面其他时机去主动调用callback回传数据，
          *     避免页面传参和页面回退动作绑死。
          */
         backward : function(param) {
            window.pageBridge.backward(param);
         },

         /**
          * 单独向上一个页面回传参数的接口
          * @param param 参数 （例如"param=value&param2=value2"）
          */
         callback : function(param) {
            window.pageBridge.callback(param);
         },

         /**
          * 触发流程压栈
          */
         pushFlow : function() {
            window.pageBridge.pushFlow();
         },

         /**
          * 触发流程弹栈
          * @param param 返回参数, 例如: "param=value&param2=value2"
          */
         popFlow : function (param) {
            window.pageBridge.popFlow(param);
         }
     };

     com.dmall.Bridge = {
         pageCallback : function(){},
         appPageCallback : function(param) {
             var map = {};
             var eles = param.split("&");
             for(var i in eles) {
                 var obj = eles[i];
                 var objEles = obj.split("=");
                 var key = decodeURI(objEles[0]);
                 var value = decodeURI(objEles[1]);
                 map[key] = value;
             }
             com.dmall.Bridge.pageCallback(map);
         }
     };
  
    gfun = function() {
        alert("gfun called!");
    };
 })();

