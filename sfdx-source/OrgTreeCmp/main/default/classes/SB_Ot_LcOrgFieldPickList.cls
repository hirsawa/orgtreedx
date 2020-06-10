/**
 *  SB_Ot_LcOrgFieldPickList
 *      組織名項目の選択肢
 *
 *
 **/
public class SB_Ot_LcOrgFieldPickList extends SB_Ot_LcSObjectFieldPickList {
  public SB_Ot_LcOrgFieldPickList(VisualEditor.DesignTimePageContext context) {
    super(context);
    if (context.entityName == 'Contact') {
      // Contact でなく Account で組織名の項目を指定する
      this.otype = Account.getSObjectType();
    }
    else {
      this.otype = Schema.getGlobalDescribe().get(context.entityName);
    }
    this.fieldMap = otype.getDescribe().fields.getMap();
    try {
      this.objConfig = SB_Ot_SObjectConfig.getSObjectConfig(this.otype);
    }
    catch(Exception e) {
      System.debug(LoggingLevel.INFO, e.getMessage());
    }
  }

  protected override String getDefaultField() {
    if (this.objConfig == null) {
      return null;
    }
    return this.objConfig.orgField;
  }

  protected override Set<Schema.DisplayType> getEnableDisplayTypes() {
    return new Set<Schema.DisplayType> { Schema.DisplayType.STRING };
  }
}