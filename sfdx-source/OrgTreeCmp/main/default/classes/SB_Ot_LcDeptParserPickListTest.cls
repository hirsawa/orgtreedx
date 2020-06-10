/**
 *  SB_Ot_LcDeptParserPickListTest
 *
 *  SB_Ot_LcDeptParserPickList のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx
 *
 **/
@isTest
private class SB_Ot_LcDeptParserPickListTest {

  @isTest
  static void test_SB_Ot_LcDeptParserPickList() {
    SB_Ot_LcDeptParserPickList pickList = new SB_Ot_LcDeptParserPickList();
    System.assertEquals('separator', pickList.getDefaultValue().getValue());
    VisualEditor.DynamicPickListRows opts = pickList.getValues();
    System.assert(opts.size() > 0);
  }

}