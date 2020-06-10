/**
 *  SB_Ot_LcTreeGridColumnsCreater
 *    treeGrid の columns 属性 の値
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0    2019.03.xx
 *  @Version 1.1    2019.05.xx  項目API名に基づかずに識別する
 *
 **/
public with sharing class SB_Ot_LcTreeGridColumnsCreater {
  public class SB_Ot_LcTreeGridColumnsCreaterException extends Exception {}

  public class ColumnData {
    @AuraEnabled public String label;  //  Required. The text label displayed in the column header.
    @AuraEnabled public String fieldName;  //  Required. The name that binds the columns properties to the accountAssociation data. Each columns property must correspond to an item in the data array.
    @AuraEnabled public String type;  //  Required. The data type to be used for data formatting. For more information, see Formatting with Data Types.
    @AuraEnabled public integer initialWidth;  // The width of the column when it's initialized, which must be within the minColumnWidth and maxColumnWidth values, or within 50px and 1000px if they are not provided.
    @AuraEnabled public TypeAttributes typeAttributes;  //  Provides custom formatting with component attributes for the data type. For example, currencyCode for the currency type. For more information, see Formatting with Data Types.
    @AuraEnabled public CellAttributes cellAttributes;  //  Provides additional customization, such as appending an icon to the output. For more information, see Appending an Icon to Column Data
    @AuraEnabled public boolean sortable;  // Specifies whether sorting by columns is enabled. The default is false.
    @AuraEnabled public List<Action> actions;  //  Appends a dropdown menu of actions to a column. You must pass in a list of label-name pairs.
    @AuraEnabled public String iconName;  //  The Lightning Design System name of the icon. Names are written in the format standard:opportunity. The icon is appended to the left of the header label.
    @AuraEnabled public String fieldApi;   // 項目API名 treeGrid では不用だけど
    public ColumnData() {}
    public ColumnData(String label, String fieldName, String type, Integer initialWidth, Boolean sortable, String iconName, String fieldApi) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
      this.initialWidth = initialWidth;
      this.sortable = sortable;
      this.iconName = iconName;
      this.fieldApi = fieldApi;
    }
    public ColumnData(String label, String fieldName, String type, Integer initialWidth, Boolean sortable, String fieldApi) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
      this.initialWidth = initialWidth;
      this.sortable = sortable;
      this.fieldApi = fieldApi;
    }
  }

  //action  Displays a dropdown menu using lightning:buttonMenu with actions as menu items  rowActions (required), menuAlignment (defaults to right)
  //button  Displays a button using lightning:button  disabled, iconName, iconPosition, label, name, title, variant
  //currency  Displays a currency using lightning:formattedNumber currencyCode, currencyDisplayAs
  //date  Displays a date and time based on the locale using lightning:formattedDateTime  day, era, hour, hour12, minute, month, second, timeZone, timeZoneName, weekday, year
  //email Displays an email address using lightning:formattedEmail  N/A
  //location  Displays a latitude and longitude of a location using lightning:formattedLocation latitude, longitude
  //number  Displays a number using lightning:formattedNumber minimumIntegerDigits, minimumFractionDigits, maximumFractionDigits, minimumSignificantDigits, maximumSignificantDigits
  //percent Displays a percentage using lightning:formattedNumber Same as number type
  //phone Displays a phone number using lightning:formattedPhone  N/A
  //text  Displays text using lightning:formattedText N/A
  //url Displays a URL using lightning:formattedUrl label, target


  //TYPE ATTRIBUTES
  public class TypeAttributes {
    // action
    @AuraEnabled public String rowActions;
    @AuraEnabled public String menuAlignment;
    // URL => lightning:formattedUrl
    @AuraEnabled public Field label;   // The text to display in the link.
    @AuraEnabled public String target; // Specifies where to open the link. Options include _top, _parent, _self, and _top. GripTree では機能しない？
    @AuraEnabled public Field tooltip;  // The text to display when the mouse hovers over the link.
    // currency => lightning:formattedNumber
    @AuraEnabled public String currencyCode; // Only used if style='currency', this attribute determines which currency is displayed. Possible values are the ISO 4217 currency codes, such as 'USD' for the US dollar.
    @AuraEnabled public String currencyDisplayAs; // Determines how currency is displayed. Possible values are symbol, code, and name. This value defaults to symbol.
    // number, percent  => lightning:formattedNumber
    @AuraEnabled public Integer minimumIntegerDigits;  // The minimum number of integer digits that are required. Possible values are from 1 to 21.
    @AuraEnabled public Integer minimumFractionDigits; // The minimum number of fraction digits that are required.
    @AuraEnabled public Integer maximumFractionDigits; // The maximum number of fraction digits that are allowed.
    @AuraEnabled public Integer minimumSignificantDigits;  // The minimum number of significant digits that are required. Possible values are from 1 to 21.
    @AuraEnabled public Integer maximumSignificantDigits;  // The maximum number of significant digits that are allowed. Possible values are from 1 to 21.
    // location => lightning:formattedLocation
    @AuraEnabled public Decimal latitude;  // The latitude value of the geolocation. Latitude values must be within -90 and 90.
    @AuraEnabled public Decimal longitude; // The longitude value of the geolocation. Longitude values must be within -180 and 180.

    public TypeAttributes() {
    }

    public TypeAttributes(Field label) {
      this.label = label;
    }

    public TypeAttributes(Url url) {
      this.label = url.label;
      this.tooltip = url.tooltip;
      this.target = url.target;
    }

  }

  public class Field {
    @AuraEnabled public String fieldName;
    public Field(String fieldName) {
      this.fieldName = fieldName;
    }
  }

  public class Url {
    @AuraEnabled public Field label;
    @AuraEnabled public Field tooltip;
    @AuraEnabled public String target;
    public Url(String label, String target) {
      this.label = new Field(label);
      this.target = target;
    }
    public Url(String label, String tooltip, String target) {
      this.label = new Field(label);
      this.tooltip = new Field(tooltip);
      this.target = target;
    }
  }

  public class CellAttributes {
    @AuraEnabled public String iconName;       // Required. The Lightning Design System name of the icon, for example, utility:down.
    @AuraEnabled public String iconLabel;      //The label for the icon to be displayed on the right of the icon.
    @AuraEnabled public String iconPosition;       // The position of the icon relative to the data. Valid options include left and right. This value defaults to left.
  }

  public abstract class Action {
    @AuraEnabled public String label;  //  Required. The label that's displayed for the action.
    @AuraEnabled public String name; //   Required. The name of the action, which identifies the selected action.
  }


  public class HeaderAction extends Action {
    // public String label;  // Required. The label that's displayed for the action.
    // public String name; //  Required. The name of the action, which identifies the selected action.
    @AuraEnabled public String checked;  // Specifies whether a check mark is shown to the left of the action label. If true, a check mark is shown to the left of the menu item. If false, a check mark is not shown but there is space to accommodate one.
    @AuraEnabled public String disabled; //  Specifies whether the action can be selected. If true, the action item is shown as disabled. This value defaults to false.
    @AuraEnabled public String iconName; //  The name of the icon to be displayed to the right of the action item.
  }

  public class RowLevelAction extends Action {
    // public String label;      // Required. The label that's displayed for the action.
    // public String name;     //  Required. The name of the action, which identifies the selected action.
    @AuraEnabled public String disabled;     //  Specifies whether the action can be selected. If true, the action item is shown as disabled. This value defaults to false.
    @AuraEnabled public String iconName;     //  The name of the icon to be displayed to the right of the action item.
  }

  public static List<ColumnData> create(Schema.SObjectType otype, Set<String> hideFields) {
    ColumnDataListBuilder builder;
    if (otype == Contact.sObjectType || otype == Account.sObjectType) {
      builder = new PcColumnDataListBuilder();
    }
    else if (otype != null){
      builder = new ColumnDataListBuilder(otype);
    }
    else {
      //  複数オブジェクトのとき
      // builder = new MultiColumnDataListBuilder();
      throw new SB_Ot_LcTreeGridColumnsCreaterException('can not create ColumnData List');
    }
    if (hideFields!=null) {
      builder.addHideFields(hideFields);
    }
    return builder.create();
  }

  // TreeGrid 用の カラムリストを作るクラス
  private virtual class ColumnDataListBuilder {
    protected SObjectType otype;
    // protected SB_Ot_SObjectConfig objConfig;
    // protected Map<String, Schema.SObjectField> fieldMap;
    protected List<ColumnData> columnDatas;
    protected Set<String> colFields;     // Account,Contact2つのオブジェクトで同じ カラムが入る可能性ががあるので、リストから削除するため
    protected Set<String> hideFields;     // 設定にあっても、表示しない列
    public ColumnDataListBuilder() {
      this.columnDatas = new List<ColumnData>();
      this.colFields = new Set<String>();
      this.hideFields = new Set<String>();
    }
    public ColumnDataListBuilder(SObjectType otype) {
      this.otype = otype;
      // this.objConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
      // this.fieldMap = otype.getDescribe().fields.getMap();
      this.columnDatas = new List<ColumnData>();
      this.colFields = new Set<String>();
      this.hideFields = new Set<String>();
    }

    public void addHideField(String hideField) {
      this.hideFields.add(hideField);
    }
    public void addHideFields(Set<String> hideFields) {
      this.hideFields.addAll(hideFields);
    }
    public virtual List<ColumnData> create() {
      // 先頭のラベルのカラム定義
      appendLabelColumn(this.otype);
      // データ部のカラム定義
      SB_Ot_SObjectConfig objConfig = SB_Ot_SObjectConfig.getSObjectConfig(this.otype);
      appendSObjectColumns(objConfig.gridFields, this.otype);
      return this.columnDatas;
    }

    // 先頭のラベルのカラム定義
    protected virtual void appendLabelColumn(SObjectType otype) {
      Map<String, Schema.SObjectField> fieldMap = otype.getDescribe().fields.getMap();
      String firstLabel = String.format(System.Label.SB_Ot_GridFirstLabelFormat, new String[] { fieldMap.get('Name').getDescribe().getLabel() });
      ColumnData nameColumn = new ColumnData(firstLabel,
                        'linkTo', 'url', SB_Ot_Global.otConfig.GridLabelInitialWidth__c.intValue(), true, 'standard:person_account', 'Name');
      nameColumn.typeAttributes = new TypeAttributes(new Field('label'));
      this.columnDatas.add(nameColumn);
    }
    // //  同じ カラム が既にあったら、削除する。2つのオブジェクトのときよう。後の方で表示するため。 OwnerNameくらいだけど。
    // protected virtual void removeAlready(String field) {
    //   if (this.colFields.containsKey(field)) {
    //     Integer n = this.colFields.get(field);
    //     this.columnDatas.remove(n);
    //   }
    // }
    // protected void appendSObjectColumns0(SB_Ot_SObjectConfig objConfig, Map<String, Schema.SObjectField> fieldMap) {
    //   for (String f : objConfig.gridFields) {
    //     removeAlready(f);
    //     Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
    //     ColumnData nameColumn;
    //     switch on dfr.getType() {
    //       when Reference {
    //         String objname = dfr.isCustom() ? dfr.getName() : dfr.getName().removeEndIgnoreCase('Id');
    //         String name = objname + 'Name';
    //         String link = objname + 'LinkTo';
    //         String icon =  'standard:' + (f == 'ownerid' ? 'user' : dfr.getReferenceTo()[0].getDescribe().getName().toLowerCase());
    //         nameColumn = new ColumnData(dfr.getLabel().removeEndIgnoreCase('Id').trim(), link, 'url', null, true, icon, f);
    //         nameColumn.typeAttributes = new TypeAttributes();
    //         nameColumn.typeAttributes.label = new Label(name);
    //         nameColumn.typeAttributes.tooltip = dfr.getLabel().removeEndIgnoreCase('Id').trim();
    //       }
    //       when Email {
    //         nameColumn = new ColumnData(dfr.getLabel(), dfr.getName(), 'email', null, true, null, f);
    //       }
    //       when Phone {
    //         nameColumn = new ColumnData(dfr.getLabel(), dfr.getName(), 'phone', null, true, null, f);
    //       }
    //       when Currency {
    //         nameColumn = new ColumnData(dfr.getLabel(), dfr.getName(), 'currency', null, true, null, f);
    //         nameColumn.typeAttributes = new TypeAttributes();
    //         nameColumn.typeAttributes.currencyCode = UserInfo.getDefaultCurrency();
    //       }
    //       when Percent {
    //         nameColumn = new ColumnData(dfr.getLabel(), dfr.getName(), 'percent', null, true, null, f);
    //       }
    //       when else {
    //         nameColumn = new ColumnData(dfr.getLabel(), dfr.getName(), 'text', null, true, null, f);
    //       }
    //     }
    //     this.columnDatas.add(nameColumn);
    //     this.colFields.put(f, this.columnDatas.size()-1);
    //   }
    // }
    // データ部のカラム定義
    protected void appendSObjectColumns(List<String> fields, Schema.SObjectType otype) {
      Map<String, Schema.SObjectField> fieldMap = otype.getDescribe().fields.getMap();
      for (Integer n = 0; n < fields.size(); n++) {
        String f = fields.get(n);
        if (this.colFields.contains(f) || this.hideFields.contains(f)) {
          continue;
        }
        ColumnData nameColumn;
        String colId = f.removeStart('smartviscaf__').removeEnd('__c');   // == 'ownerid' ? 'owner' : 'col' + String.valueOf(n);  // OwnerId は共通の識別子にする
        if (f == 'contactrole') {
          nameColumn = new ColumnData(System.Label.SB_Ot_ContactRole, colId, 'text', null, true, null, f); // Describeでとれなさそうなので、ラベルで
        }
        else {
          Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
          switch on dfr.getType() {
            when Reference {
              String name = colId;
              String link = colId + 'LinkTo';
              String icon =  'standard:' + (f == 'ownerid' ? 'user' : dfr.getReferenceTo()[0].getDescribe().getName().toLowerCase());
              String col = dfr.getLabel().removeEndIgnoreCase('Id').trim();
              nameColumn = new ColumnData(col, link, 'url', null, true, icon, f);
              nameColumn.typeAttributes = new TypeAttributes(new Url(name, col, SB_Ot_Global.otConfig.GridUrlTarget__c));
            }
            when location {
              String link = colId + 'LinkTo';
              String col = dfr.getLabel();
              nameColumn = new ColumnData(col, link, 'url', null, true, null, f);
              nameColumn.typeAttributes = new TypeAttributes(new Url(colId, col, SB_Ot_Global.otConfig.GridUrlTarget__c));

            }
            when URL {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'url', null, true, null, f);
            }
            when Email {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'email', null, true, null, f);
            }
            when Phone {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'phone', null, true, null, f);
            }
            when Currency {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'currency', null, true, null, f);
              nameColumn.typeAttributes = new TypeAttributes();
              nameColumn.typeAttributes.currencyCode = UserInfo.getDefaultCurrency();
            }
            when Percent {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'percent', null, true, null, f);
            }
            when Boolean {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'boolean', null, true, null, f);
            }
            when Integer, Long, Double {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'number', null, true, null, f);
            }
            when else {
              nameColumn = new ColumnData(dfr.getLabel(), colId, 'text', null, true, null, f);
            }
          }
        }

        this.colFields.add(f);
        this.columnDatas.add(nameColumn);
      }
    }
  } // private virtual class ColumnDataListBuilder

  // 親子関係の2つオブジェクト用の TreeGrid 用の カラムリストを作る
  private class PcColumnDataListBuilder extends ColumnDataListBuilder {
    // private SObjectType pOtype;
    // private SB_Ot_SObjectConfig pObjConfig;
    // private Map<String, Schema.SObjectField> pFieldMap;
    //  otype は 子
    public PcColumnDataListBuilder() {
      super();
    }
    public override List<ColumnData> create() {
      // 先頭のラベルのカラム定義
      appendLabelColumn(Contact.getSObjectType());
      // データ部のカラム定義
      // コンタクトのカラム
      SB_Ot_SObjectConfig contObjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.sObjectType);
      appendSObjectColumns(contObjConfig.gridFields, Contact.sObjectType);
      // 組織 アカウントが後
      SB_Ot_SObjectConfig acntObjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.sObjectType);
      appendSObjectColumns(acntObjConfig.gridFields, Account.sObjectType);
      return this.columnDatas;
    }
  } // private class PcColumnDataListBuilder extends ColumnDataListBuilder


  // // 複数オブジェクト用の TreeGrid 用の カラムリストを作る
  // private class MultiColumnDataListBuilder extends ColumnDataListBuilder {
  //   private SB_Ot_MultiObjectConfig multiConfig;

  //   public MultiColumnDataListBuilder() {
  //     super();
  //     this.multiConfig = SB_Ot_MultiObjectConfig.getInstance();
  //   }
  //   public override List<ColumnData> create() {
  //     SObjectType personOtype;
  //     if (this.multiConfig.otype2Fields.containsKey(Contact.getSObjectType()) ||
  //       !this.multiConfig.otype2Fields.containsKey(Lead.getSObjectType())) {
  //       personOtype = Contact.getSObjectType();
  //     }
  //     else {
  //       personOtype = Lead.getSObjectType();
  //     }
  //     // 先頭のラベルのカラム定義
  //     appendLabelColumn(personOtype);
  //     // データ部のカラム定義
  //     appendGirdColumns();
  //     return this.columnDatas;
  //   }

  //   // protected override void appendLabelColumn() {
  //   //   Map<String, Schema.SObjectField> fieldMap = Contact.getSObjectType().getDescribe().fields.getMap();
  //   //   String firstLabel = String.format(System.Label.SB_Ot_GridFirstLabelFormat, new String[] { fieldMap.get('Name').getDescribe().getLabel() });
  //   //   ColumnData nameColumn = new ColumnData(firstLabel,
  //   //                     'linkTo', 'url', SB_Ot_Global.otConfig.GridLabelInitialWidth__c.intValue(), true, 'standard:person_account', 'Name');
  //   //   nameColumn.typeAttributes = new TypeAttributes();
  //   //   nameColumn.typeAttributes.label = new Label('label');
  //   //   this.columnDatas.add(nameColumn);
  //   // }

  //   // データ部のカラム定義
  //   private void appendGirdColumns() {
  //     List<ColumnData> subCols;
  //     for (SObjectType otype : this.multiConfig.otype2Fields.keySet()) {
  //       List<String> fields = this.multiConfig.otype2Fields.get(otype);
  //       // List<ColumnData> subCols = appendSObjectColumns(fields, otype);
  //       // this.columnDatas.addAll(subCols);
  //       subCols = createColumnDatas(subCols, fields, otype);
  //     }
  //     // 最終的に null 要素は削除して追加
  //     this.columnDatas.addAll(removeNullColumns(subCols));
  //   }

  //   private List<ColumnData> removeNullColumns(List<ColumnData> columns) {
  //     if (!columns.contains(null)) {
  //       return columns;
  //     }
  //     List<ColumnData> result = new List<ColumnData>();
  //     for (ColumnData col : columns) {
  //       if (col != null) {
  //         result.add(col);
  //       }
  //     }
  //     return result;
  //   }

  // } // private class MultiColumnDataListBuilder extends ColumnDataListBuilder

  public static List<ColumnData> createColumnDatas(List<ColumnData> prevDatas, List<String> fields, Schema.SObjectType otype) {
    System.assert(prevDatas == null || prevDatas.size() == fields.size());
    List<ColumnData> result = new ColumnData[fields.size()];
    Map<String, Schema.SObjectField> fieldMap = otype.getDescribe().fields.getMap();
    for (Integer n = 0; n < fields.size(); n++) {
      String f = fields.get(n);
      if (String.isBlank(f)) {
        // この列 は、このオブジェクトではない
        // if (prevDatas == null || prevDatas.get(n) == null) {
        // }
        if (prevDatas != null &&  prevDatas.get(n) != null) {
          // この列 は、設定済
          result.set(n, prevDatas.get(n));
        }
        continue;
      }
      ColumnData nameColumn;
      String colId = f.removeStart('smartviscaf__').removeEnd('__c');  // == 'ownerid' ? 'owner' : 'col' + String.valueOf(n);  // OwnerId は共通の識別子にする
      if (SB_Ot_MultiObjectConfig.SPECIAL_COLUMNS.containsKey(f)) {
        nameColumn = new ColumnData(SB_Ot_MultiObjectConfig.SPECIAL_COLUMNS.get(f).title, colId, 'text', null, true, null, f);
      }
      else {
        if (!fieldMap.containsKey(f)) { // ないほず
          throw new SB_Ot_LcTreeGridColumnsCreaterException(String.format('Invalid field {0} in {1}', new String[] {f, otype.getDescribe().getLabel() } ));
        }
        Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
        switch on dfr.getType() {
          when Reference {
            String name = colId;
            String link = colId + 'LinkTo';
            String icon =  'standard:' + (f == 'ownerid' ? 'user' : dfr.getReferenceTo()[0].getDescribe().getName().toLowerCase());
            String col = dfr.getLabel().removeEndIgnoreCase('Id').trim();
            nameColumn = new ColumnData(col, link, 'url', null, true, icon, f);
            nameColumn.typeAttributes = new TypeAttributes(new Url(name, col, SB_Ot_Global.otConfig.GridUrlTarget__c));
          }
          when Email {
            nameColumn = new ColumnData(dfr.getLabel(), colId, 'email', null, true, null, f);
          }
          when Phone {
            nameColumn = new ColumnData(dfr.getLabel(), colId, 'phone', null, true, null, f);
          }
          when Currency {
            nameColumn = new ColumnData(dfr.getLabel(), colId, 'currency', null, true, null, f);
            nameColumn.typeAttributes = new TypeAttributes();
            nameColumn.typeAttributes.currencyCode = UserInfo.getDefaultCurrency();
          }
          when Percent {
            nameColumn = new ColumnData(dfr.getLabel(), colId, 'percent', null, true, null, f);
          }
          when else {
            nameColumn = new ColumnData(dfr.getLabel(), colId, 'text', null, true, null, f);
          }
        }
      }
      result.set(n, nameColumn);
    }
    return result;
  }

}