/**
 *  SB_Ot_LcDisplayModePickListTest
 *
 *  SB_Ot_LcDisplayModePickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx
 *  @Version 1.1    2019.11.xx    Gridがデフォルト
 *
 **/
@isTest
private class SB_Ot_LcDisplayModePickListTest {

  @isTest
  static void test_SB_Ot_LcDisplayModePickList() {
    SB_Ot_LcDisplayModePickList pickList = new SB_Ot_LcDisplayModePickList();
    System.assertEquals('grid', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}