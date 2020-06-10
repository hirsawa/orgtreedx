/**
 *
 *  SB_Ot_LabelFormatter
 *    ラベル部を表示する用にフォーマットするクラス
 *
 * Copyright (C) 2018-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0      2019.03.xx
 *  @Version 1.1      2019.05.xx  ExtraLabelFormatter では オブジェクト名を出せるように
 *                    2020.01.xx  個人取引先のとき、レコードタイプ名 をだすように
 *
 **/
public with sharing class SB_Ot_LabelFormatter {

  private static SB_Ot_OrgTreeConfig treeConfig {
    get {
      if (treeConfig==null) {
        treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      }
      return treeConfig;
    }
    private set;
  }

  public interface LabelFormatter {
    String make(SObject obj);
  }

  // アカウント以外 ラベル に役職とか所有者とかつけるときのフォーマッタ
  public class ExtraLabelFormatter implements LabelFormatter {
    private List<String> fields;
    private String oName;
    // オブジェクトごとの定義からフォーマットを決める コンストラクタ
    public ExtraLabelFormatter(SB_Ot_SObjectConfig sobjConfig) {
      this.fields = new List<String>();
      // 役職
      if (treeConfig.showTitle && String.isNotBlank(sobjConfig.titleField)) {
        this.fields.add(sobjConfig.titleField);
      }
      // 氏名
      this.fields.add('name');
      // Email
      if (treeConfig.showEMail && String.isNotBlank(sobjConfig.emailField)) {
        this.fields.add(sobjConfig.emailField);
      }
      // オブジェクト名
      if (treeConfig.showSObject) {
        this.fields.add('sobject');
        this.oName = String.format(Label.SB_Ot_LabelSObjectFormat, new String[] { sobjConfig.getSObjectLabel() });
      }
      // 所有者
      if (treeConfig.showOwner && sobjConfig.otype != User.getSObjectType()) {
        this.fields.add('Owner.Name');
      }
    }

    public String make(SObject obj) {
      List<String> values = new List<String>();
      for (String f : fields) {
        if (f.endsWithIgnoreCase('.name')) {
          SObject o = obj.getSObject(f.removeEndIgnoreCase('.name'));
          if (o == null) {    // v1.0.1 2019.04.19 SB組織で、所有者 NULL ? の取引先責任者レコードがあった  0031000000x1qOWAAY
            continue;
          }
          String owner = (String)o.get('Name');
          if (String.isNotBlank(owner)) {
            values.add(String.format(Label.SB_Ot_LabelOwnerFormat, new String[] { owner }));
          }
        }
        else if (f == 'sobject') {
          // オブジェクト名
          values.add(this.oName);
        }
        else {
          String val = (String)obj.get(f);
          if (String.isNotBlank(val)) {
            values.add(val);
          }
        }
      }
      return String.join(values, ' ');
    }
  } // ExtraLabelFormatter

  // アカウント用のフォーマッタ
  public class AccountLabelFormatter implements LabelFormatter {
    private String orgField;
    private String deptField;
    public AccountLabelFormatter(SB_Ot_SObjectConfig sobjConfig) {
      this.orgField = sobjConfig.orgField;
      this.deptField = sobjConfig.deptField;  // null ではない。
    }
    public String make(SObject obj) {
      String result;
      String name; // 組織名部
      if (SB_Ot_Global.isEnablePersonAccount() && SB_Ot_Global.isPersonal(obj)) {
        // 個人取引先
        SObject rectype = obj.getSObject('RecordType');
        name = String.format(System.Label.SB_Ot_PersonalAccountRootLabel, new String[] { (String)rectype.get('Name') });
      }
      else {
        // 通常の取引先
        name = (String)obj.get(this.orgField);
        if (String.isBlank(name)) {
          name = (String)obj.get('Name');
        }
      }
      String dept = (String)obj.get(this.deptField);  // 部門名部
      if (treeConfig.accountDeptUsage == SB_Ot_OrgTreeConfig.DepartmentUsage.Label &&
          String.isNotBlank(dept)) {
        // 部署名があるとき
        result = String.format(Label.SB_Ot_OrgDeptLabelFormat, new String[] { name, dept }); // 組織名 > 部門名
      }
      else {
        result =  name;     // 組織名
      }
      if (isShowOwner()) {
        // 所有者を表示
        SObject o = obj.getSObject('Owner');
        String owner = (String)o.get('Name');
        if (String.isNotBlank(owner)) {
          result += ' ' + String.format(Label.SB_Ot_LabelOwnerFormat, new String[] { owner });
        }
      }
      return result;
    }

    // 所有者を表示？
    // 氏名と所有者を表示 かつ ツリーかグリッドでも表示 のとき
    private Boolean isShowOwner() {
      return treeConfig.showOwner &&
      (treeConfig.displayFormat == SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree || !treeConfig.gridLabelNoExtra);
    }
  }

  // ラベルは Name だけのフォーマッタ
  public class SimpleLabelFormatter implements LabelFormatter {
    public String make(SObject obj) {
      return (String)obj.get('Name');
    }
  }

  // LabelFormatter のインスタンスを生成する
  public static LabelFormatter createLabelFormatter(SB_Ot_SObjectConfig sobjConfig) {
    LabelFormatter result;
    if (sobjConfig.otype == Account.sObjectType) {
      // アカウント用
      result = new AccountLabelFormatter(sobjConfig);
    }
    else if (SB_Ot_LabelFormatter.treeConfig.displayFormat == SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree || !SB_Ot_LabelFormatter.treeConfig.gridLabelNoExtra) {
      // アカウント以外で、タイトルとか所有者とか出すのにも対応
      result = new ExtraLabelFormatter(sobjConfig);
    }
    else {
      // アカウント以外で、単に Name だけ
      result = new SimpleLabelFormatter();
    }
    return result;
  }

}