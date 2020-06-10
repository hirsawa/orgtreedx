/**
 *
 *  SmartVisca
 *    SB_Ot_OrgTreeHelper.js
 *  Lightning Component による 組織ツリー
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx
 *
 **/
({

  createOrgTree : function(cmp, helper) {
    if (cmp.get("v.idField") === "none") {
      cmp.set("v.working", false);    //
      return;
    }
    cmp.set("v.working", true);    //
    cmp.set("v.errorMsg", "");
    var action = cmp.get("c.createOrgTree");
    var req = JSON.stringify({
      "selectedId": cmp.get("v.recordId"),    // 選択中のレコードID
      "idField": cmp.get("v.idField"),      // 参照するレコードIDの項目
      "displayFormat": cmp.get("v.displayFormat"),
      "dateRange": cmp.get("{!v.dateRange}"),   // 期日の範囲
      "otherCondition": cmp.get("{!v.otherCondition}"), // 対象レコードの条件
      "orgField": (cmp.get("v.orgField")==='None' ? null : cmp.get("v.orgField")), // 組織名の項目
      "deptField": (cmp.get("v.deptField")==='None' ? null : cmp.get("v.deptField")), // 部署名の項目
      "titleField": (cmp.get("v.titleField")==='None' ? null : cmp.get("v.titleField")), // 役職名の項目
      "gridFields": cmp.get("v.gridFields"), // グリッドに表示する項目
      "deptParser": cmp.get("v.deptParser"),  // 部門、部署の分割方法
      // 2019.01.14 MTG決定事項 カスタム設定を使うけど、 デフォルトなしのNULLで渡す。呼び出し元コンポーネントで指定してれば、NULLじゃない
      "showTitle": cmp.get("v.showTitle"),  // 役職を表示する
      "showOwner": cmp.get("v.showOwner"),   // 所有者を表示する
      "showEMail": cmp.get("v.showEMail"), // メアドを表示する
      "gridLabelNoExtra": cmp.get("v.gridLabelNoExtra"), // グリッドでは名称のみ
      "maxRecs" : cmp.get("v.maxRecs"), // 検索する名刺レコード数の上限値
      // 取引先 特有の設定項目
      "accountAssociation": cmp.get("v.accountAssociation"),    // 親・子の取引先を階層に含める
      "accountGridFields": cmp.get("v.accountGridFields"),  // 取引先 グリッドに表示する項目
      "accountDeptUsage": cmp.get("v.accountDeptUsage"), // 取引先 部門 の使用方法 階層化、表示
      // v1.1 複数オブジェクト対応
      // "multiObjectActive": cmp.get("v.multiObjectActive"), // 他オブジェクトによる構成を可能にする
      // "multiObject": cmp.get("v.multiObject"), // 対象の複数オブジェクト 未使用
      // "multiObjectGridFields": cmp.get("v.multiObjectGridFields"),   // 複数オブジェクト での グリッドに表示する項目
      // "requestObject": cmp.get("v.requestObject"), // 表示したいオブジェクト
    });

    action.setParams({
      "req" : req
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.success) {
          cmp.set("v.enableOperation", result.enableOperation); // 操作継続可能
          cmp.set("v.visibleFormatMenu", result.uiConfig.visibleFormatMenu); // 表示形式切り替え可能
          cmp.set("v.visibleParserMenu", result.uiConfig.visibleParserMenu); // 部署項目の分割方法の切り替えを可能にする
          cmp.set("v.gridShowNum", result.uiConfig.gridShowNum); // v1.2 グリッドで行番号を表示する
          // cmp.set("v.multiObjectActive", result.multiObjectActive); //
          cmp.set("v.targetId", result.targetId); // 階層構築に使ったレコードのID
          // if (result.multiObjectActive) { // 複数のオブジェクトによる構成  が有効
            // cmp.set("v.relateObjects", result.relateObjects); // 関連するオブジェクトでツリーを作るためのメニュー用
            // cmp.set("v.sourceObject", result.sourceObject); //
          // }
          // if (!result.enableMenu) {
          //   // カスタム設定優先なのでメニュー操作不可
          //   cmp.set("v.visibleFormatMenu", false);
          //   cmp.set("v.visibleParserMenu", false);
          // }
          if (result.summary) {
            cmp.set("v.summary", result.summary);
          }
          if (result.treeGridColumns) {
            // Grid用
            cmp.get("v.displayFormat", 'grid');
            cmp.set("v.gridColumns", result.treeGridColumns);
            var nestedData =[];
            this.adjustGridData(nestedData, result.items, cmp.get("v.recordId"), helper);

            cmp.set("v.gridData", nestedData);
            cmp.set("v.gridExpandedRows", result.branchIds);
            // var treeGrid = cmp.find('treeGrid');
            // treeGrid.expandAll(); // 全部開く
          }
          else {
            // Tree用
            cmp.get("v.displayFormat", 'tree');
            cmp.set("v.items", result.items);    // 対象の名刺一覧
            // cmp.set("v.rootLabel", result.rootLabel);    // ルートの名称 会社名 不要？
          }
          //
          // cmp.set('v.gridColumns', result.config.treeGridColumns);
          // var nestedData =[];
          // this.setGridData(nestedData, result.items, helper);
          // cmp.set('v.gridData', nestedData);
          // // var treeGrid = cmp.find('treeGrid');
          // // treeGrid.expandAll(); // 全部開く
          cmp.set("v.expanded", true);    //
          cmp.set("v.working", false);    //
        }
        else {
          // サーバーのAPIの処理でエラーがあった場合、画面に表示
          cmp.set("v.errorMsg", result.error);
          cmp.set("v.working", false);    //
        }
      }
      else {
        // 通信自体、API以前にエラー
        cmp.set("v.errorMsg", "Request failed.");
        cmp.set("v.working", false);    //
      }
    });
    $A.enqueueAction(action);
  },


  // // 対象のレコード に合致する候補の名刺を収集
  // createOrgTreeItems : function(cmp, helper) {
  // // createOrgTreeItems : function(cmp, targetId, showTitle) {
  //   cmp.set("v.working", true);    //
  //   var action = cmp.get("c.getOrgTreeItems");
  //   // 個別の引数にすると、Integer がうまく渡せないので シリアライズ して 文字列を引数にする
  //   var req = JSON.stringify({
  //     "targetId": cmp.get("v.recordId"),
  //     "displayFormat": cmp.get("v.displayFormat"),
  //     "accountAssociation": cmp.get("v.accountAssociation"),    // 階層に関連会社を含める
  //     "accountDeptUsage": cmp.get("v.accountDeptUsage"), //取引先 部門 の使用方法 階層化、表示
  //     "deptParser": cmp.get("v.deptParser"),  // 部門、部署の分割方法
  //     "showTitle": cmp.get("v.showTitle"),  // 役職を表示する
  //     // "showNamecard": cmp.get("v.showNamecard"), // 名刺参照項目を表示する
  //     "showOwner": cmp.get("v.showOwner"),   // 所有者を表示する
  //     "showEMail": cmp.get("v.showEMail"), // メアドを表示する
  //     "maxRecs" : cmp.get("v.maxRecs"), // 検索する名刺レコード数の上限値
  //   });
  //   action.setParams({
  //     "req" : req
  //   });
  //   action.setCallback(this, function(response) {
  //     var state = response.getState();
  //     if (cmp.isValid() && state === "SUCCESS") {
  //       var result = JSON.parse(response.getReturnValue());
  //       if (result.success) {
  //         // Tree用
  //         cmp.set("v.items", result.items);    // 対象の名刺一覧
  //         cmp.set("v.rootLabel", result.rootLabel);    // ルートの名称 会社名
  //         // Gridの処理
  //         cmp.set('v.gridColumns', result.config.treeGridColumns);
  //         var nestedData =[];
  //         this.setGridData(nestedData, result.items, helper);
  //         cmp.set('v.gridData', nestedData);
  //         var treeGrid = cmp.find('treeGrid');
  //         // treeGrid.expandAll(); // 全部開く
  //         cmp.set("v.working", false);    //

  //       }
  //       else {
  //         // エラーがあった場合、画面に表示
  //         cmp.set("v.errorMsg", result.error);
  //         cmp.set("v.working", false);    //
  //       }
  //     }
  //     else {
  //       cmp.set("v.errorMsg", "Request failed");
  //       cmp.set("v.working", false);    //
  //     }
  //   });
  //   $A.enqueueAction(action);
  // },

  gotoRecordDetail: function(recordId) {
    var navEvt = $A.get("e.force:navigateToSObject");
    if (!navEvt) {
      // LEXじゃない
      window.open("/" + recordId, "_top");
    }
    else {
      // LEX
      navEvt.setParams({
        "isredirect": true,    // ナビゲーション履歴の現在の URL を新しい URL に置き換える
        "recordId": recordId,
        "slideDevName": "detail"  // レコード詳細スライド
      });
      navEvt.fire();
    }
  },

  // setGridData: function(nestedData, items, helper) {
  //   items.forEach(function(item) {
  //     // var data;

  //     // if (item.info && item.info.name) {
  //     //   data = Object.assign(item);
  //     //   data = Object.assign(data, item.info);
  //     //   // data.name = item.info.name;
  //     // }
  //     // else {
  //     //   data = Object.assign(item);
  //     //   // data.name = item.label;
  //     // }
  //     if (item.info) {
  //       item.Name = item.info.name;
  //     }
  //     else {
  //       item.Name = item.label;
  //     }
  //     if (item.items)  {
  //       item._children = [];
  //       helper.setGridData(item._children, item.items, helper);
  //     }
  //     nestedData.push(item);
  //   });
  // },

  adjustGridData: function(nestedData, items, recordId, helper) {
    items.forEach(function(item) {
      if (item.values) {
        Object.assign(item, item.values);
      }
      // else {
      //   item.linkTo = '/one/one.app#/sObject/'+ recordId +'/view';
      // }
      if (item.items)  {
        item._children = [];
        helper.adjustGridData(item._children, item.items, recordId, helper);
      }
      nestedData.push(item);
    });
  },

})