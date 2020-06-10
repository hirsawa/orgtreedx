/**
 *
 *  SB_Ot_LcDeptParserPickList
 *    部門、部署のパース方法 の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 *
 **/
public class SB_Ot_LcDeptParserPickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_Space, 'separator');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_Space, 'separator'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_NewLine, 'line'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_Comparision, 'comparision'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_Regex, 'regex'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_DeptParser_NotParse, 'noop'));
    return result;
  }
}