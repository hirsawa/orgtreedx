/**
 *
 *  SB_Ot_LcOtherConditionPickList
 *    その他の条件の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.11.xx
 *
 **/
public class SB_Ot_LcOtherConditionPickList extends VisualEditor.DynamicPickList {

  private VisualEditor.DynamicPickListRows pikcLists; // 選択肢のリスト
  private VisualEditor.DataRow defaultValue;  // デフォルト

  public SB_Ot_LcOtherConditionPickList(VisualEditor.DesignTimePageContext context) {
    this.pikcLists = new VisualEditor.DynamicPickListRows();
    Schema.SObjectType otype;
    List<Schema.SObjectType> haveOTypes = new List<Schema.SObjectType>();
    if (context.pageType == 'RecordPage') {
      // レコード詳細ページのとき
      otype = Schema.getGlobalDescribe().get(context.entityName);
      Map<String, Schema.SObjectField> fieldMap = otype.getDescribe().fields.getMap();
      for (String f : fieldMap.keySet()) {
        Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
        if (dfr.getType() == Schema.DisplayType.REFERENCE && dfr.isAccessible() &&
          !dfr.isNamePointing() && !dfr.getReferenceTo().isEmpty()) { // 参照項目で 複数オブジェクト参照型でない
          if (SB_Ot_Global.enableOTypes.contains(dfr.getReferenceTo().get(0)) && dfr.getName()!='MasterRecordId'
            && !haveOTypes.contains(dfr.getReferenceTo().get(0))) {
            // 選択可能な 対象の オブジェクト
            haveOTypes.add(dfr.getReferenceTo().get(0));
          }
        }
      }
    }
    // PickListを作る
    List<DataRowCreator> drCreators = new List<DataRowCreator>();
    if (haveOTypes.contains(Account.getSObjectType()) || haveOTypes.contains(Contact.getSObjectType()) || haveOTypes.contains(Lead.getSObjectType())) {
      // 取引先用の選択肢を作る
      drCreators.add(new ContactLeadDataRowCreator(haveOTypes));
    }
    if (haveOTypes.contains(SB_Ot_Global.getNameCardSObjectType())) {
      // 名刺用の選択肢を作る
      drCreators.add(new NamecardDataRowCreator());
    }
    // デフォルト選択肢も作っておく。メモリはちがうとこでラベルも違うけど。 value があってれば選択される模様。
    if (SB_Ot_Global.otConfig.Development__c && // UserInfo.getOrganizationName() == System.Label.SB_Ot_SunbridgeGroup &&
        (context.pageType == 'HomePage' || context.pageType == 'AppPage')) {
      // ホームページのとき
      // ユーザ レコード用の選択肢を創る
      drCreators.add(new UserDataRowCreator());
      // ユーザ レコード用のデフォルト選択肢
      this.defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_OnlyActiveUsers, 'active');
    }
    else {
      // レコード詳細用のデフォルト選択肢
      if (otype == SB_Ot_Global.getNameCardSObjectType()) {
        // 2020.04.xx v1.4 SV_ORGTREE-21 名刺レコード詳細画面の アプリケーションビルダの「対象レコードの条件」のデフォルトは「(名刺)最新の名刺のみ」にする
        // 名刺オブジェクトのレコードページ
        this.defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_LatestNameCards, 'latest');
      }
      //
      // else if (otype == Account.getSObjectType() || otype == Contact.getSObjectType()) {
      //   // 取引先か取引先責任者のレコードページ、
      //   // リードのレコードページはリードが対象外なので、デフォルトはなしで
      //   this.defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_HaveNameCardReference, 'haveNC');
      // }
      else {
        this.defaultValue = new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, 'none');
      }
    }
    //なし を作る
    this.pikcLists.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_Text_None, 'none'));
    for (DataRowCreator c : drCreators) {
      this.pikcLists.addAllRows(c.create());
    }
  }

  // デフォルト値
  public override VisualEditor.DataRow getDefaultValue() {
    return this.defaultValue;
  }

  // 選択肢のリスト
  public override VisualEditor.DynamicPickListRows getValues() {
    return this.pikcLists;
  }

  // 選択肢の ラベル と値 の組を保持するためのクラス
  private with sharing class LabelValue {
    public String label { get; private set; }
    public String value { get; private set; }
    public LabelValue(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  // 選択肢を作るクラス
  private abstract class DataRowCreator {
    protected List<LabelValue> conditions;
    protected String objNames; // ラベルに出す オブジェクト名
    public List<VisualEditor.DataRow> create() {
      List<VisualEditor.DataRow> result = new List<VisualEditor.DataRow>();
      for (LabelValue lv : conditions) {
        String text;
        if (String.isNotBlank(this.objNames)) {
          text = String.format('({0}) {1}', new String[]{ objNames, lv.label });
        }
        else {
          text = lv.label;
        }
        result.add(new VisualEditor.DataRow(text, lv.value));
      }
      return result;
    }
  }

  // Account,Contact,Lead 用 Leadはないけど、あってもいいように。
  private with sharing class ContactLeadDataRowCreator extends DataRowCreator {
    public ContactLeadDataRowCreator(List<Schema.SObjectType> otypes) {
      this.conditions = new List<LabelValue> { new LabelValue(System.Label.SB_Ot_HaveNameCardReference, 'haveNC'),
                                          new LabelValue(System.Label.SB_Ot_HaveLatestNameCardReference, 'haveLatestNC'),
                                          new LabelValue(System.Label.SB_Ot_HaveNoChangeLatestNameCardReference, 'haveNoChangeLatestNC') };
      List<String> oNames = new List<String>();
      if (otypes.contains(Account.getSObjectType()) || otypes.contains(Contact.getSObjectType()) ) {
        oNames.add(Account.getSObjectType().getDescribe().getLabel());
      }
      if (otypes.contains(Lead.getSObjectType())) {
        oNames.add(Lead.getSObjectType().getDescribe().getLabel());
      }
      this.objNames = String.join(oNames, ', ');
    }
  }

  // 名刺用
  private with sharing class NameCardDataRowCreator extends DataRowCreator {
    public NameCardDataRowCreator() {
      this.conditions = new List<LabelValue> { new LabelValue(System.Label.SB_Ot_LatestNameCards, 'latest'),
                                          new LabelValue(System.Label.SB_Ot_NoChangeLatestCards, 'noChangeLatest') };
      this.objNames = SB_Ot_Global.getNameCardSObjectType().getDescribe().getLabel();
    }
  }

  // ホームページ用 = ユーザオブジェクト用
  private with sharing class UserDataRowCreator extends DataRowCreator {
    public UserDataRowCreator() {
      this.conditions = new List<LabelValue> { new LabelValue(System.Label.SB_Ot_OnlyActiveUsers, 'active'),
                                          new LabelValue(System.Label.SB_Ot_OnlySameOrgUsers, 'sameOrg'),
                                          new LabelValue(System.Label.SB_Ot_OnlySameOrgActiveUsers, 'sameOrgActive') };
    }
  }

}