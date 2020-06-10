/**
 *
 *  SB_Ot_LcSObjectFieldPickList
 *    選択されてるオブジェクトで項目を選ぶ　動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.03.xx
 *
 **/
public abstract class SB_Ot_LcSObjectFieldPickList extends VisualEditor.DynamicPickList {
  protected VisualEditor.DesignTimePageContext context;
  protected SObjectType otype;
  protected Map<String, Schema.SObjectField> fieldMap;
  protected SB_Ot_SObjectConfig objConfig;
  // protected abstract String getItemName();
  protected abstract String getDefaultField();
  protected abstract Set<Schema.DisplayType> getEnableDisplayTypes();

  public SB_Ot_LcSObjectFieldPickList(VisualEditor.DesignTimePageContext context) {
    this.context = context;
  }

  public override VisualEditor.DataRow getDefaultValue() {
    VisualEditor.DataRow defaultValue;
    if (String.isNotBlank(getDefaultField())) {
      Schema.DescribeFieldResult dfr = this.fieldMap.get(getDefaultField()).getDescribe();
      defaultValue = new VisualEditor.DataRow(dfr.getLabel(), dfr.getName());
    }
    else {
      // デフォルト値なし (なし)がデフォルト
      defaultValue = createNoneValue();
    }
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    if (String.isBlank(getDefaultField())) {
      // デフォルト値なし のときだけ、(なし)選択可能
      result.addRow(createNoneValue());
    }
    if (this.objConfig == null) {
      // 対象オブジェクトでないときは、なし のみ選択可能
      return result;
    }
    for(String f : this.fieldMap.keySet()) {
      Schema.DescribeFieldResult dfr = this.fieldMap.get(f).getDescribe();
      if (!getEnableDisplayTypes().contains(dfr.getType())) {
        continue;
      }
      result.addRow(new VisualEditor.DataRow(dfr.getLabel(), dfr.getName()));
    }
    // result.sort(); System.ListException: One or more of the items in this list is not Comparable.
    return result;
  }

  private VisualEditor.DataRow createNoneValue() {
    return new VisualEditor.DataRow(Label.SB_Ot_Text_None, 'None');
  }

}