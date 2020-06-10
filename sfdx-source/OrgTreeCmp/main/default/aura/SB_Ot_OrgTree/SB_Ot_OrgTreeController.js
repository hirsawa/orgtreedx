/**
 *
 *  SmartVisca
 *    SB_Ot_OrgTreeController.js
 *  Lightning Component による 組織ツリー
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx
 *
 **/
({
  // 画面 初期化 候補の名刺一覧取得
  doInit : function(cmp, event, helper) {
    var t = cmp.get("v.appTitle");
    if (!t) {
      var l = $A.get("$Label.c.SB_Ot_AppTitle");
      if (l !=='(no title)') {
        cmp.set("v.appTitle", l);    // アプリ タイトル
      }
    }
    helper.createOrgTree(cmp, helper);
  },

  // 選択されたノードが 氏名 だったら 該当の名刺レコード詳細画面へ遷移
  onSelect: function (cmp, event, helper) {
    var recordId = event.getParam('name');
    if (!recordId || recordId.startsWith('NR')) { // レコードではないやつ？
      return;
    }
    var clickToRecord = cmp.get("v.clickToRecord");
    if (clickToRecord) {
      var targetId = cmp.get("v.recordId");
      if (recordId === targetId) {
        return;
      }
      helper.gotoRecordDetail(recordId);
    }
    // //return name of selected tree item
    // var sleName = event.getParam('name');
    // var clickToRecord = cmp.get("v.clickToRecord");
    // if (sleName && clickToRecord) {
    //   // 選択された レコードへ
    //   var info = JSON.parse(sleName);
    //   var targetId = cmp.get("v.recordId");
    //   if (info.recordId === targetId) {
    //     return;
    //   }
    //   helper.gotoRecordDetail(info.recordId);
    //   // var navEvt = $A.get("e.force:navigateToSObject");
    //   // navEvt.setParams({
    //   //   "isredirect": false,    // ナビゲーション履歴の現在の URL を新しい URL に置き換える
    //   //   "recordId": info.recordId,
    //   //   "slideDevName": "detail"  // レコード詳細スライド
    //   // });
    //   // navEvt.fire();
    // }
  },

  // 戻る Lightning Out で
  onClose: function (cmp, event, helper) {
    var targetId = cmp.get("v.recordId");
    helper.gotoRecordDetail(targetId);

    // var navEvt = $A.get("e.force:navigateToSObject");
    // if (!navEvt) {
    //   // LEXじゃない
    //   window.open("/" + targetId, "_top");
    // }
    // else {
    //   // LEX
    //   navEvt.setParams({
    //     "isredirect": false,    // ナビゲーション履歴の現在の URL を新しい URL に置き換える
    //     "recordId": targetId,
    //     "slideDevName": "detail"  // レコード詳細スライド
    //   });
    //   navEvt.fire();
    // }
  },

  // // 全て開く
  // onExpandAll: function (cmp, event, helper) {
  //   var mode = cmp.get("v.displayFormat");
  //   if (mode === "Tree" ) {
  //     //  Tree
  //     var items = cmp.get("v.items");
  //     items.forEach(function(item) {
  //       cmp.changeTreeExpansion(item, true);
  //     });
  //     cmp.set("v.items", items);
  //   }
  //   else {
  //     // Grid
  //     var treeGrid = cmp.find('treeGrid');
  //     treeGrid.expandAll(); // 全部開く
  //   }
  // },

  // // 全て閉じる
  // onCollapseAll: function (cmp, event, helper) {
  //   var mode = cmp.get("v.displayFormat");
  //   if (mode === "Tree" ) {
  //     //  Tree
  //     var items = cmp.get("v.items");
  //     items.forEach(function(item) {
  //       cmp.changeTreeExpansion(item, false);
  //     });
  //     cmp.set("v.items", items);
  //   }
  //   else {
  //     // Grid
  //     var treeGrid = cmp.find('treeGrid');
  //     treeGrid.collapseAll(); // 全部開く
  //   }
  // },

  // 全開｜全閉
  toggleExpansion: function(cmp, event) {
    if (cmp.get("v.working")) {
      return;
    }
    var expanded = !cmp.get("v.expanded");
    var mode = cmp.get("v.displayFormat");
    if (mode === "Tree" ) {
      //  Tree
      var items = cmp.get("v.items");
      // items.forEach(function(item) {
      //   cmp.changeTreeExpansion(item, expanded);
      // });
      for (var i=0; i < items.length; i++) {
        cmp.changeTreeExpansion(items[i], expanded);
      }
      // cmp.set("v.items", null);
      // var root = cmp.get("v.rootLabel");    // ルートの名称 会社名
      cmp.set("v.items", items);
      // cmp.set("v.rootLabel", root);    // ルートの名称 会社名
    }
    else {
      // Grid
      var treeGrid = cmp.find("treeGrid");
      if (expanded) {
        treeGrid.expandAll(); // 全開
      }
      else {
        treeGrid.collapseAll(); // 全閉
      }
    }
    cmp.set("v.expanded", expanded);
  },

  //  Tree を全開｜全閉  cmp.changeTreeExpansion
  doChangeTreeExpansion: function(cmp, event) {
    var item;
    var expanded;
    var params = event.getParam("arguments");
    if (params) {
      item = params.item;
      expanded = params.expanded;
    }
    else {
      return;
    }

    item.expanded = expanded;
    if (!item.items) {
      return;
    }
    // item.items.forEach(function(item) {
    //   cmp.changeTreeExpansion(item, b);
    // });
    for (var i=0; i < item.items.length; i++) {
      cmp.changeTreeExpansion(item.items[i], expanded);
    }

  },

  // フォントサイズ変更
  onChangeFont : function(cmp, event) {
    if (cmp.get("v.working")) {
      return;
    }
    var b = !cmp.get("v.smallFont");
    cmp.set("v.smallFont", b);
    var area = cmp.find("displyaArea");
    $A.util.toggleClass(area, "smallFont");
  },

  // //
  // selectObject: function(cmp, event, helper) {
  //   var obj = event.getParam("value");
  //   if (obj === cmp.get("v.sourceObject")) {
  //     return;
  //   }
  //   cmp.set("v.requestObject", obj);
  //   helper.createOrgTree(cmp, helper);
  // },

  // ツリーとグリッドの切り替え メニューから
  selectMode: function(cmp, event, helper) {
    var mode = event.getParam("value");
    if (mode === cmp.get("v.displayFormat")) {
      return;
    }
    cmp.set("v.displayFormat", mode);
    helper.createOrgTree(cmp, helper);
  },

  selectParser: function(cmp, event, helper) {
    var parser = event.getParam("value");
    if (parser === cmp.get("v.deptParser")) {
      return;
    }
    cmp.set("v.deptParser", parser);
    helper.createOrgTree(cmp, helper);
  },

  // グリッド の ブランチを 開閉
  onGridToddle: function (cmp, event, helper) {
    var nodeId = event.getParam('name');
    var gridExpandedRows = cmp.get("v.gridExpandedRows");
    var index = gridExpandedRows.indexOf(nodeId);
    if (index != -1) {
      gridExpandedRows.slise(index+1, 1);
    }
    else {
      gridExpandedRows.push(nodeId);
    }
    cmp.set("v.gridExpandedRows", gridExpandedRows);
  },

})