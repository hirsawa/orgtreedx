/**
 *  SB_Ot_TitleOrderMakerTest
 *  
 *  SB_Ot_TitleOrderMaker のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx 
 *
 **/
@isTest
private class SB_Ot_TitleOrderMakerTest {


  @isTest
  static void test_titleOrder() {
    System.assert(SB_Ot_TitleOrderMaker.titleOrder.size()>0);
  }

  @isTest
  static void test_getTitleOrder() {
    for (String title : SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.keySet()) {
      System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.get(title), SB_Ot_TitleOrderMaker.getTitleOrder(title));
      if (!title.startsWith('副') && !SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.containsKey('副'+title)) {
        System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.get(title)+1, SB_Ot_TitleOrderMaker.getTitleOrder('副'+title));
      }
      if (!title.startsWith('副') && !SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.containsKey(title+'代理')) {
        System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.get(title)+1, SB_Ot_TitleOrderMaker.getTitleOrder(title+'代理'));
      }
    }
    System.assertEquals(999, SB_Ot_TitleOrderMaker.getTitleOrder(null));
    System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.size()+1, SB_Ot_TitleOrderMaker.getTitleOrder('副〇☓△'));
    System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.size()+1, SB_Ot_TitleOrderMaker.getTitleOrder('〇☓△代理'));
    System.assertEquals(SB_Ot_TitleOrderMaker.TITLE_ORDER_MAP.size(), SB_Ot_TitleOrderMaker.getTitleOrder('〇☓△長'));
    System.assertEquals(990, SB_Ot_TitleOrderMaker.getTitleOrder('○☓△※★!！'));
  }

}