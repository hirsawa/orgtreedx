/**
 *
 *  SB_Ot_ContactRoleFormatter
 *    取引先責任者の役割を表示用にフォーマットする
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.11.xx
 *
 **/

public with sharing class SB_Ot_ContactRoleFormatter {

  private static final Set<Schema.SObjectType> ROLE_WITH_PRIMARY = new Set<Schema.SObjectType> {
    Contact.getSObjectType(), Opportunity.getSObjectType(), Contract.getSObjectType()
  };

  private static final Map<Schema.SObjectType, String> OTYPE_RELATION = new Map<Schema.SObjectType, String> {
    Contact.getSObjectType() => 'AccountContactRoles',
    Opportunity.getSObjectType() => 'OpportunityContactRoles',
    Contract.getSObjectType() => 'ContractContactRoles',
    Case.getSObjectType() => 'CaseContactRoles'
  };

  // private static final Map<String, Schema.SObjectType> RELATION_OTYPE = new Map<String, Schema.SObjectType> {
  //   'AccountContactRoles' => AccountContactRole.getSObjectType(),
  //   'OpportunityContactRoles' => OpportunityContactRole.getSObjectType(),
  //   'ContractContactRoles' => ContractContactRole.getSObjectType(),
  //   'CaseContactRoles' => CaseContactRole.getSObjectType()
  // };

  private static final Map<String, Schema.SObjectField> RELATION_FIELD = new Map<String, Schema.SObjectField> {
    'AccountContactRoles' => AccountContactRole.Role,
    'OpportunityContactRoles' => OpportunityContactRole.Role,
    'ContractContactRoles' => ContractContactRole.Role,
    'CaseContactRoles' => CaseContactRole.Role
  };


  // ContactRoleを持ってる オブジェクトか
  public static Boolean isEnableContactRole(Schema.SObjectType otype) {
    return OTYPE_RELATION.containsKey(otype);
  }

  @TestVisible
  private static String primary {
    get {
      if (primary == null) {
        primary = AccountContactRole.IsPrimary.getDescribe().getLabel() + ' '; // 主 + 半角スペース
      }
      return primary;
    }
    set;
  }

  // ロールのAPI名とラベルのマップを取得
  @TestVisible
  private static Map<String, String> getRoleApi2Label(String relationName) {
    Map<String, String> result = new Map<String, String>();
    // Schema.SObjectType otype = RELATION_OTYPE.get(relationName);
    if (RELATION_FIELD.containsKey(relationName)) {
      List<Schema.PicklistEntry> pls = RELATION_FIELD.get(relationName).getDescribe().getPicklistValues();
      for (Schema.PicklistEntry pl : pls) {
        result.put(pl.getValue(), pl.getLabel());
      }
    }
    return result;
  }

  public with sharing virtual class ContactRoleFormatter {
    private String relationName;
    private Map<String, String> api2label;
    public ContactRoleFormatter(String relationName) {
      this.relationName = relationName;
      api2label = getRoleApi2Label(relationName);
    }

    public String getRelationName() {
      return this.relationName;
    }

    public virtual String make(Contact cont) {
      SObject[] rels = cont.getSObjects(this.relationName);
      if (rels ==null) {
        return '';
      }
      List<String> roles = new List<String>();
      for (SObject rel : rels) {
        String role = (String)rel.get('Role');
        if (String.isBlank(role) && !this.api2label.containsKey(role)) {
          continue;
        }
        roles.add(this.api2label.get(role));
      }
      return String.join(roles, ', ');
    }
  }

  // ラベル に役職とか所有者とかつけるときのフォーマッタ
  public class WithPrimaryContactRoleFormatter extends ContactRoleFormatter {
    public WithPrimaryContactRoleFormatter(String relationName) {
      super(relationName);
    }
    public override String make(Contact cont) {
      SObject[] rels = cont.getSObjects(this.relationName);
      if (rels ==null) {
        return '';
      }
      List<String> roles = new List<String>();
      for (SObject rel : rels) {
        String role = (String)rel.get('Role');
        if (String.isBlank(role) && !this.api2label.containsKey(role)) {
          continue;
        }
        role = this.api2label.get(role);
        Boolean p = (Boolean)rel.get('IsPrimary');
        if (p != false) {
          role = primary + role;
        }
        roles.add(role);
      }
      return String.join(roles, ', ');
    }
  }

  @TestVisible
  private static ContactRoleFormatter instance;

  public static String makeContactRole(Contact cont) {
    return instance.make(cont);
  }

  public static String getContactRoleField() {
    if (instance == null) {
      return null;
    }
    return instance.getRelationName();
  }

  public static void createFormatter(Schema.SObjectType otype) {
    if (ROLE_WITH_PRIMARY.contains(otype)) {
      instance = new WithPrimaryContactRoleFormatter(OTYPE_RELATION.get(otype));
    }
    else if (OTYPE_RELATION.containsKey(otype)) {
      instance = new ContactRoleFormatter(OTYPE_RELATION.get(otype));
    }
  }


}