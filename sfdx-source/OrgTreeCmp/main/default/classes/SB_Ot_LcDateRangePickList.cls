/**
 *
 *  SB_Ot_LcDateRangePickList
 *    期日の範囲（最終更新日or 名刺交換日)の範囲の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.11.xx
 *
 **/
public class SB_Ot_LcDateRangePickList extends VisualEditor.DynamicPickList {

  // AppBuilderの編集画面で 対象レコードの期日の範囲 の選択肢で特定の見せ方をする年
  private static final Map<Integer, String> QUERY_DATERANE_CY = new Map<Integer, String> {
    0 => System.Label.SB_Ot_ThisYear,
    1 => System.Label.SB_Ot_ThisAndLastYear,
    2 => System.Label.SB_Ot_ThisAndLast2Year
  };

  // AppBuilderの編集画面で 対象レコードの期日の範囲 の選択肢で特定の見せ方をする年度
  private static final Map<Integer, String> QUERY_DATERANE_FY = new Map<Integer, String> {
    0 => System.Label.SB_Ot_ThisFiscalYear,
    1 => System.Label.SB_Ot_ThisAndLastFiscalYear,
    2 => System.Label.SB_Ot_ThisAndLast2FiscalYear
  };

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, '-1');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, '-1'));
    for (Integer n = 0; n <= SB_Ot_Global.otConfig.MaxDateRange__c ; n++) {
      result.addRow(new VisualEditor.DataRow(getDataRowLabel(n), String.valueOf(n)));
    }
    return result;
  }

  private String getDataRowLabel(Integer n) {
    if (SB_Ot_Global.otConfig.DateRageUseFiscalYear__c && QUERY_DATERANE_FY.containsKey(n)) {
      return QUERY_DATERANE_FY.get(n);
    }
    else if (!SB_Ot_Global.otConfig.DateRageUseFiscalYear__c && QUERY_DATERANE_CY.containsKey(n)) {
      return QUERY_DATERANE_CY.get(n);
    }
    return String.format(SB_Ot_Global.otConfig.DateRageUseFiscalYear__c ? System.Label.SB_Ot_WithinFiscalYears : System.Label.SB_Ot_WithinYears, new String[]{ String.valueOf(n) });
  }

}