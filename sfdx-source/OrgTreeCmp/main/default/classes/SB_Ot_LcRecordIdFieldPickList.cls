/**
 *  SB_Ot_LcRecordIdFieldPickList
 *    レコードIDの選択肢
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.05.xx
 *  @Version 1.1    2019.11.xx Userレコード対応
 *
 **/
public class SB_Ot_LcRecordIdFieldPickList extends VisualEditor.DynamicPickList {
  private VisualEditor.DesignTimePageContext context;
  private Schema.SObjectType otype;
  private Map<String, Schema.SObjectField> fieldMap;

  public SB_Ot_LcRecordIdFieldPickList(VisualEditor.DesignTimePageContext context) {
    this.context = context;
    if (context.pageType == 'RecordPage') {
      this.otype = Schema.getGlobalDescribe().get(context.entityName);
      this.fieldMap = this.otype.getDescribe().fields.getMap();
    }
  }

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow result;
    if (this.otype!=null && SB_Ot_Global.enableOTypes.contains(this.otype)) {
      result = new VisualEditor.DataRow(this.otype.getDescribe().getLabel(), 'id');
    }
    else if (SB_Ot_Global.otConfig.Development__c && // UserInfo.getOrganizationName() == System.Label.SB_Ot_SunbridgeGroup &&
        (this.context.pageType == 'HomePage' || this.context.pageType == 'AppPage')) {
      result = new VisualEditor.DataRow(User.getSObjectType().getDescribe().getLabel(), 'user');
    }
    else {
      result = new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, 'none');
    }
    return result;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows result = new VisualEditor.DynamicPickListRows();
    if (SB_Ot_Global.enableOTypes.contains(this.otype)) {
      result.addRow(new VisualEditor.DataRow(this.otype.getDescribe().getLabel(), 'id'));
    }
    if (this.fieldMap != null) {
      for (String f : this.fieldMap.keySet()) {
        Schema.DescribeFieldResult dfr = this.fieldMap.get(f).getDescribe();
        if (dfr.getType() == Schema.DisplayType.REFERENCE && dfr.isAccessible() &&
          !dfr.isNamePointing() && !dfr.getReferenceTo().isEmpty()) { // 参照項目で 複数オブジェクト参照型でない
          if (SB_Ot_Global.enableOTypes.contains(dfr.getReferenceTo().get(0)) && dfr.getName()!='MasterRecordId') {
            // オブジェクト名 (項目名)
            String label = String.format('{0} ({1})', new String[] { dfr.getReferenceTo().get(0).getDescribe().getLabel(), dfr.getLabel() });
            result.addRow(new VisualEditor.DataRow(label, dfr.getName()));
          }
        }
      }
    }
    // ユーザ レコード用
    if (SB_Ot_Global.otConfig.Development__c && // UserInfo.getOrganizationName() == System.Label.SB_Ot_SunbridgeGroup &&
        (this.context.pageType == 'HomePage' || this.context.pageType == 'AppPage')) {
      result.addRow(new VisualEditor.DataRow(User.getSObjectType().getDescribe().getLabel(), 'user'));
    }
    if (result.size()==0 ) {
      result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, 'none'));
    }
    return result;
  }
}