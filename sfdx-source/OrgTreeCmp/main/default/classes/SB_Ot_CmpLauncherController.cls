/**
 *
 * SB_Ot_CmpLauncherController
 *   Lightning Component 起動用 Lightning Application 起動用 VFページ 用 APEXコントローラ
 *
 *
 * Copyright (C) 2016-2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2018.01.xx
 *
 **/
public with sharing class SB_Ot_CmpLauncherController {
  public class SB_Ot_CmpLauncherControllerException extends Exception {}

  public Id targetId { get; private set; }          // 対象のレコードID 名刺とか 取引先とか、取引先責任者とか、ロードとか
  public String retUrl { get; private set; }     // Lightning Componet 名
  public String component { get; private set; }     // Lightning Componet 名
  // 管理パッケージの名前空間名を
  public String namespace_x { get; private set; }

  @TestVisible
  private static final Map<String, String> APPCD_COMPONENT = new Map<String, String> {
    'ot' => 'SB_Ot_OrgTree',      //
    'ot_ac' => 'SB_Ot_AccountContact',    //
    'ot_any' => 'SB_Ot_AnyObject'    //
  };
  //  コンストラクタ
  //    LEXで URLで起動させるため、IDを受ける用にVFの中にコンポーネントを展開するので、
  public SB_Ot_CmpLauncherController() {
    try {
      this.namespace_x = String.isNotBlank(SB_Ot_Global.getNamespacePrefix()) ?
            SB_Ot_Global.getNamespacePrefix() : 'c';
      this.namespace_x += ':';
      this.targetId = (Id)System.currentPageReference().getParameters().get('id');
      // SObjectType otype = this.targetId.getSObjectType();
      this.retUrl = (String)System.currentPageReference().getParameters().get('retUrl');
      String app = (String)System.currentPageReference().getParameters().get('app');
      if (app==null) {
        app = 'ot';
      }
      System.debug(app);
      this.component = APPCD_COMPONENT.get(app);
      System.debug(this.component);
      if (this.component == null && app.startsWithIgnoreCase('SB_Ot_')) {
        this.component = app;     // SB_Ot_ で始まってたら Lightningコンポーネントだと判断しちゃう。
      }
      else if (this.component == null) {
        throw new SB_Ot_CmpLauncherControllerException('Invalid URL Parameter.');
      }
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

}