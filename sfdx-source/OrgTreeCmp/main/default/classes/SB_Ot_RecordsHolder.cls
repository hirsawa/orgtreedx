/**
 *
 *  SB_Ot_RecordsHolder
 *  選択されたレコードから、同じ組織のレコードを収集保持するクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx
 *
 **/
public with sharing class SB_Ot_RecordsHolder {
  public class SB_Ot_RecordsHolderException extends Exception {}

  public interface RecordsHolder {
    void create(Id targetId);
    void create(String orgName);
    // void updateLabel();
  }

  private static final String QUERY_TEMPL_TARGET = 'SELECT Id, {0} FROM {1} WHERE Id=:targetId LIMIT 1';
  private static final String QUERY_TEMPL_WOL = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}';

  // public class MultiOrgRecordsHolder implements RecordsHolder {
  //   public List<SObject> members { get; private set; }
  //   private SB_Ot_OrgTreeConfig treeConfig;
  //   private SB_Ot_SObjectConfig sobjConfig;
  //   public SingleObjectRecordsHolder() {
  //     this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
  //   }
  //   public SingleObjectRecordsHolder(SObjectType otype) {
  //     this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
  //     this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
  //   }
  //   public void create(Id targetId) {
  //     try {
  //       this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(targetId.getSObjectType());
  //       String targetQuery = String.format(QUERY_TEMPL_TARGET, new String[] { sobjConfig.orgField, sobjConfig.getSObjectName()});
  //       System.debug(targetQuery);
  //       SObject targetObj = Database.query(targetQuery);
  //       // 組織名
  //       this.name = (String)targetObj.get(this.sobjConfig.orgField);
  //       create(this.name);
  //     }
  //     catch(Exception e) {
  //       throw new SB_Ot_RecordsHolderException('Invalid record Id: ' + targetId);
  //     }
  //   }
  //   public void create(String orgName) {
  //     try {
  //       this.name = orgName;
  //       this.label = this.name; // 一旦は会社名のみ
  //       String fields = String.join(new List<String>(this.sobjConfig.getQueryFields()), ', ');
  //       // Wehere 句
  //       List<String> conditions = new List<String>();
  //       conditions.add(String.format('{0}=:name', new String[] { this.sobjConfig.orgField }));
  //       if (String.isNotBlank(this.sobjConfig.whereExpression)) {
  //         conditions.add(this.sobjConfig.whereExpression);
  //       }
  //       String condition = String.join(conditions, ' AND ');
  //       // Order By
  //       String orderby = String.join(this.sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
  //       String query = String.format(QUERY_TEMPL_WOL,
  //                 new String[] { fields, this.sobjConfig.getSObjectName(), condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
  //       System.debug(query);
  //       this.members = Database.query(query);
  //     }
  //     catch(Exception e) {
  //       throw new SB_Ot_RecordsHolderException('faild to query organization records: ' + orgName);
  //     }
  //   }
  // } // public class MultiOrgRecordsHolder implements RecordsHolder


  public class SingleObjectRecordsHolder implements RecordsHolder {
    public String name { get; private set; }    // 組織名
    public String label { get; private set; }   // 組織名の表示ラベル
    public List<SObject> members { get; private set; }
    private SB_Ot_OrgTreeConfig treeConfig;
    private SB_Ot_SObjectConfig sobjConfig;
    public SingleObjectRecordsHolder() {
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
    }
    public SingleObjectRecordsHolder(SObjectType otype) {
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
    }
    public void create(Id targetId) {
      try {
        this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(targetId.getSObjectType());
      }
      catch(Exception e) {
        throw new SB_Ot_RecordsHolderException('Invalid record Id: ' + targetId);
      }
      String targetQuery = String.format(QUERY_TEMPL_TARGET, new String[] { sobjConfig.orgField, sobjConfig.getSObjectName()});
      System.debug(targetQuery);
      SObject targetObj = Database.query(targetQuery);
      // 組織名
      this.name = (String)targetObj.get(this.sobjConfig.orgField);
      if (String.isBlank(this.name) && targetId.getSObjectType() != User.getSObjectType()) {
        // 組織名がない
        Map<String, Schema.SObjectField > fMap = this.sobjConfig.otype.getDescribe().fields.getMap();
        // {0} は空です
        throw new SB_Ot_RecordsHolderException(String.format(System.Label.SB_Ot_Msg_ValueIsNull, new String[] { fMap.get(this.sobjConfig.orgField).getDescribe().getLabel() }));
      }
      create(this.name);
    }

    public void create(String orgName) {
      try {
        this.name = orgName;
        this.label = makeLabel(orgName);
        String fields = String.join(new List<String>(this.sobjConfig.getQueryFields()), ', ');
        // Wehere 句
        List<String> conditions = new List<String>();
        conditions.addAll(this.sobjConfig.whereExpressions);
        String condition = conditions.isEmpty() ? 'Id!=null' : String.join(conditions, ' AND ');
        // Order By
        String orderby = String.join(this.sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
        String query = String.format(QUERY_TEMPL_WOL,
                  new String[] { fields, this.sobjConfig.getSObjectName(), condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
        System.debug(query);
        this.members = Database.query(query);
      }
      catch(Exception e) {
        throw new SB_Ot_RecordsHolderException('faild to query organization records: ' + orgName);
      }
    }

    // // label の組織名 に オブジェクト名を追加
    // public void updateLabel() {
    //   this.label = String.format('{0} ({1})', new String[] { this.label, this.sobjConfig.getSObjectLabel() });
    // }
    private String makeLabel(String name) {
      String orgName = this.sobjConfig.isRootLabelUserOrg() ? UserInfo.getOrganizationName() : (String.isNotBlank(this.name) ? this.name : '');
      return  String.format('{0} ({1})', new String[] { orgName, this.sobjConfig.getSObjectLabel() });
    }
  }

  // // 指定のレコードIDと違うオブジェクトで階層を作る
  // public class AltSingleObjectRecordsHolder implements RecordsHolder {
  //   public String name { get; private set; }
  //   public List<SObject> members { get; private set; }
  //   private SB_Ot_OrgTreeConfig treeConfig;
  //   private SB_Ot_SObjectConfig sobjConfig;
  //   public AltSingleObjectRecordsHolder() {
  //     this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
  //   }
  //   public AltSingleObjectRecordsHolder(SObjectType otype) {
  //     this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
  //     this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(otype);
  //   }
  //   public void create(Id targetId) {
  //     try {
  //       this.sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(targetId.getSObjectType());
  //       String targetQuery = String.format(QUERY_TEMPL_TARGET, new String[] { sobjConfig.orgField, sobjConfig.getSObjectName()});
  //       System.debug(targetQuery);
  //       SObject targetObj = Database.query(targetQuery);
  //       // 組織名
  //       this.name = (String)targetObj.get(this.sobjConfig.orgField);
  //       if (String.isBlank(this.name)) {
  //         // 組織名がない
  //         Map<String, Schema.SObjectField > fMap = this.sobjConfig.otype.getDescribe().fields.getMap();
  //         throw new SB_Ot_RecordsHolderException(String.format('{0}がありません。', new String[] { fMap.get(this.sobjConfig.orgField).getDescribe().getLabel() }));
  //       }
  //       create(this.name);
  //     }
  //     catch(Exception e) {
  //       throw new SB_Ot_RecordsHolderException('Invalid record Id: ' + targetId);
  //     }
  //   }

  //   public void create(String orgName) {
  //     try {
  //       String fields = String.join(new List<String>(this.sobjConfig.getQueryFields()), ', ');
  //       // Wehere 句
  //       List<String> conditions = new List<String>();
  //       conditions.add(String.format('{0}=:name', new String[] { this.sobjConfig.orgField }));
  //       if (String.isNotBlank(this.sobjConfig.whereExpression)) {
  //         conditions.add(this.sobjConfig.whereExpression);
  //       }
  //       String condition = String.join(conditions, ' AND ');
  //       // Order By
  //       String orderby = String.join(this.sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
  //       String query = String.format(QUERY_TEMPL_WOL,
  //                 new String[] { fields, this.sobjConfig.getSObjectName(), condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
  //       System.debug(query);
  //       this.members = Database.query(query);
  //     }
  //     catch(Exception e) {
  //       throw new SB_Ot_RecordsHolderException('faild to query organization records: ' + orgName);
  //     }
  //   }
  // }



  // アカウントの親アカウントを遡る用のSOQL
  private static final String QUERY_ACCOUNT_PARENTS = 'SELECT Id, Name, Parent.Id, Parent.Parent.Id, Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Parent.Id FROM Account WHERE Id=:acntId';
  private static final String QUERY_ACCOUNT_BRANCHES = 'SELECT {0} FROM Account WHERE {1} ORDER BY {2} LIMIT {3}';
  private static final String QUERY_ACCOUNT_ORGNAME = 'SELECT {0} FROM Account WHERE {1} ORDER BY ParentId, LastModifiedDate DESC LIMIT {2}';
  private static final String QUERY_1ACCOUNT = 'SELECT {0} FROM Account WHERE Id=:rootAccountId';

  public virtual class AccountsRecordsHolder implements RecordsHolder {
    public Id rootAccountId { get; private set; }
    public List<Account> acnts { get; private set; }  // 表示中のレコードに関連する全アカウント AccountWhere__c にはマッチしてる。
    public Set<Id> matchedAcntIds { get; private set; } // 対象のオブジェクトの条件を含め合致している アカウント のIDs
    public List<Contact> conts { get; private set; }
    private SB_Ot_OrgTreeConfig treeConfig;
    private Id targetId;
    public Boolean hideContactRoleCol { get; private set; } // 該当のオブイェクトに対する取引先責任者の役割レコードがないので、列指定があっても 取引先責任者の役割列を隠す

    public AccountsRecordsHolder() {
      this.rootAccountId = null;
      this.targetId = null;
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      this.hideContactRoleCol = false;
    }

    public virtual void create(Id targetId) {
      this.targetId = targetId;
      // 最上位の アカウント ID を得る
      resolveRootAccountFromId(targetId);
      // ルートからの全てのアカウントを得る。
      createAccountList();
      // 全てのアカウントのコンタクトを収集
      createContactList();
    }

    public virtual void create(String orgName) {
      try {
        // 組織名を元に 最上位の アカウント ID を得る
        resolveRootAccountFromOrgName(orgName);
        // ルートからの全てのアカウントを得る。
        createAccountList();
        // 全てのアカウントのコンタクトを収集
        createContactList();
      }
      catch(Exception e) {
        // 該当の組織名のアカウントがなかった とか
        this.acnts = new List<Account>();
        this.conts = new List<Contact>();
      }
    }

    //  最上位の アカウント ID を得る
    private virtual void resolveRootAccountFromId(Id targetId) {
      SObjectType otype = targetId.getSObjectType();
      // ルートのアカウントを求める
      if (otype == Account.sObjectType) {
        resolveRootAccountFromAccount(targetId);
      }
      else {
        resolveRootAccountFromContact(targetId);
      }
    }

    // 選択されたアカウントのIdから 最上位の アカウント ID を得る
    private void resolveRootAccountFromAccount(Id acntId) {
      List<Account> acnts = Database.query(QUERY_ACCOUNT_PARENTS);
      if (acnts.isEmpty() ) {
        throw new SB_Ot_RecordsHolderException('Invalid Account Id: ' + acntId);
      }
      SObject obj = acnts.get(0);
      do {
        this.rootAccountId = obj.Id;
        if (obj.getPopulatedFieldsAsMap().containsKey('Parent') == false) {
          break;
        }
        obj = obj.getSObject('Parent');
      } while (obj != null);

      System.debug(LoggingLevel.INFO, 'rootAccountId: ' + this.rootAccountId);
    }

    // 選択されたコンタクトのIdから 最上位の アカウント ID を得る
    private void resolveRootAccountFromContact(Id contId) {
      List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :contId];
      if (conts.isEmpty() ) {
        throw new SB_Ot_RecordsHolderException('Invalid Contact Id: ' + contId);
      }
      if (conts[0].AccountId != null)  {
        // アカウントのIdから 最上位の アカウント ID を得る
        resolveRootAccountFromAccount(conts[0].AccountId);
      }
      // else {
      //   // return;
      //   throw new SB_Ot_RecordsHolderException(System.Label.SB_Ot_Text_NotHaveAccount);
      // }
    }

    // 組織名を元に 最上位の アカウント ID を得る
    private virtual void resolveRootAccountFromOrgName(String orgName) {
      String query = makeRootAccountQuerybyOrgName();
      System.debug(LoggingLevel.INFO, query);
      List<Account> acnts = Database.query(query);
      if (acnts.isEmpty()) {
        throw new SB_Ot_RecordsHolderException('No match orgname account.');
      }
      if (acnts[0].ParentId == null) {
        // この組織名のが ルートだった
        this.rootAccountId = acnts[0].Id;
      }
      else {
        // この組織名のは ルートでない。
        resolveRootAccountFromAccount(acnts[0].Id);
      }
    }

    // ルートからの配下のアカウントを照会して AccountItem 階層 を作成
    // ブランチのアカウントを得る
    private virtual void createAccountList() {
      if (this.rootAccountId == null) {
        this.acnts = new List<Account>();
        this.matchedAcntIds = new Set<Id>();
        return;
      }
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.sObjectType);
      Set<String> cols = new Set<String>();
      cols.addAll(sobjConfig.getQueryFields());
      cols.add('ParentId');
      cols.add('ownerid');
      cols.add('lastmodifieddate');// 所有者LWC用
      cols.add('site');// 所有者LWCのレコードのラベル用
      String fields = String.join(new List<String>(cols), ', ');
      List<String> conditions = new List<String> { '(Id=:rootAccountId OR Parent.Id=:rootAccountId OR Parent.Parent.Id=:rootAccountId OR Parent.Parent.Parent.Id=:rootAccountId OR Parent.Parent.Parent.Parent.Id=:rootAccountId OR Parent.Parent.Parent.Parent.Parent.Id=:rootAccountId)' };
      // if(String.isNotBlank(SB_Ot_Global.otConfig.AccountWhere__c)) {
      //   conditions.add(SB_Ot_Global.otConfig.AccountWhere__c);
      // }
      // conditions.addAll(sobjConfig.whereExpressions);
      String condition = String.join(conditions, ' AND ');
      // Order By
      String orderby = String.join(sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
      String query = String.format(QUERY_ACCOUNT_BRANCHES, new String[]{ fields, condition, orderby, String.valueOf(this.treeConfig.maxRecs) });
      System.debug(LoggingLevel.INFO, 'createAccountList: ' + query);
      this.acnts = Database.query(query);
      // 合致してるアカウントのうち、対象のオブジェクトの条件にもマッチするアカウントを探す。IDのSetを作る。
      conditions.clear();
      conditions.add('Id in :acnts');
      conditions.addAll(sobjConfig.whereExpressions);
      query = String.format('SELECT Id, Name FROM Account WHERE {0} LIMIT {1}', new String[]{ String.join(conditions, ' AND '), String.valueOf(this.treeConfig.maxRecs) });
      Map<Id, SObject> matchedAccounts = new Map<Id, SObject> (Database.query(query));
      this.matchedAcntIds = new Set<Id> (matchedAccounts.keySet());
    }

    // ルート アカウント以下のアカウント配下のコンタクトを得る。
    protected virtual void createContactList() {
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.sObjectType);
      Set<String> cols = new Set<String>();
      Id pageRecId = this.treeConfig.pageRecordId;
      cols.addAll(sobjConfig.getQueryFields());
      cols.add('accountid');
      cols.add('ownerid');
      cols.add('lastmodifieddate'); // 所有者LWCの用
      cols.add('department');// 所有者LWCのレコードのラベル用
      cols.add('title');// 所有者LWCのレコードのラベル用
      if (sobjConfig.showContactRole) {
        cols.add('(SELECT Id, Role, IsPrimary, AccountId FROM AccountContactRoles WHERE AccountId IN :acnts)');    // 取引先責任者の役割
        if (pageRecId!=null) {
          if (pageRecId.getSobjectType() == Opportunity.getSObjectType()) {
            cols.add('(SELECT Id, Role, IsPrimary FROM OpportunityContactRoles WHERE OpportunityId=:pageRecId)');   // 商談の取引先責任者の役割
          }
          else if (pageRecId.getSobjectType() == Case.getSObjectType()) {
            cols.add('(SELECT Id, Role FROM CaseContactRoles WHERE CasesId=:pageRecId)');   // 商談の取引先責任者の役割
          }
          else if (pageRecId.getSobjectType() == Contract.getSObjectType()) {
            cols.add('(SELECT Id, Role, IsPrimary FROM ContractContactRoles WHERE ContractId=:pageRecId)');   // 商談の取引先責任者の役割
          }
        }
      }
      String fields = String.join(new List<String>(cols), ', ');
      List<String> conditions = new List<String>();
      if (!this.acnts.isEmpty()) {
        conditions.add('AccountId IN :acnts');
      }
      else if (this.targetId != null && this.targetId.getSObjectType() == Contact.getSObjectType()) {
        conditions.add('Id = :targetId');
      }
      conditions.addAll(sobjConfig.whereExpressions);
      String condition = String.join(conditions, ' AND ');
      String orderby = 'AccountId ASC NULLS LAST, ' + String.join(sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
      String query = String.format(QUERY_TEMPL_WOL,
                new String[] { fields, 'Contact', condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
      System.debug(LoggingLevel.INFO, 'createContactList: ' + query);
      List<Contact> conts = Database.query(query);
      // 最新のレコードのみにする
      if (sobjConfig.onlyLatest) {
        this.conts = pickupLatestContacts(conts);
      }
      else {
        this.conts = conts;
      }
      if (sobjConfig.showContactRole && SB_Ot_Global.otConfig.GridShowContactRoleColumnOnlyWhenData__c) {
        // 取引先責任者の役割レコードあるかないか判定
        this.hideContactRoleCol = isNoContactRoleRecords(pageRecId);
      }
    }

    // SV_ORGTREE-8 グリッドで取引先責任者の役割列の指定があっても、データがなければ表示しないことを可能とする
    private Boolean isNoContactRoleRecords(Id pageRecId) {
      String query;
      SObjecttype otype = pageRecId != null ? pageRecId.getSObjectType() : Account.getSObjectType();
      if (otype == Opportunity.getSObjectType()) {
        query = 'SELECT Id FROM OpportunityContactRole WHERE OpportunityId=:pageRecId AND ContactId IN :conts LIMIT 2';
      }
      else if (otype == Case.getSObjectType()) {
        query = 'SELECT Id FROM CaseContactRole WHERE CasesId=:pageRecId AND ContactId IN :conts LIMIT 2';
      }
      else if (otype == Contract.getSObjectType()) {
        query = 'SELECT Id FROM ContractContactRole WHERE ContractId=:pageRecId AND ContactId IN :conts LIMIT 2';
      }
      else {
        query = 'SELECT Id FROM AccountContactRole WHERE AccountId IN :acnts AND ContactId IN :conts LIMIT 2';
      }
      return Database.query(query).isEmpty();
    }

    //  最終更新日が最新のもののみにする
    protected List<Contact> pickupLatestContacts(List<Contact> conts) {
      List<Contact> result = new List<Contact>();
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.sObjectType);
      Map<String, Integer> cKey2Index = new Map<String, Integer> ();
      for (Contact cont : conts) {
        String cKey = cont.Name + (String)cont.get(sobjConfig.emailField);
        if (cKey2Index.containsKey(cKey)) {
          Integer index = cKey2Index.get(cKey);
          Contact last = result.get(index);
          if (last.LastModifiedDate < cont.LastModifiedDate) {
            // 後のほうが新しかった
            result.set(index, cont);
          }
        }
        else {
          cKey2Index.put(cKey, result.size());
          result.add(cont);
        }
      }
      return result;
    }

     // 組織名から アカウントを抽出するクエリを作成
    protected String makeRootAccountQuerybyOrgName() {
      // String result;
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType());
      // 取り出す項目
      List<String> fields = new List<String>();
      fields.add(sobjConfig.orgField);       // 組織名
      fields.add('id');
      fields.add('parentid');
      String field = String.join(fields, ', ');
      // Wehere 句
      List<String> conditions = new List<String>();
      conditions.add(String.format('{0}=:orgName', new String[]{ sobjConfig.orgField })); // 組織名
      // 追加の検索条件
      conditions.addAll(sobjConfig.whereExpressions);
      String condition = String.join(conditions, ' AND ');
      return String.format(QUERY_ACCOUNT_ORGNAME,
                new String[] { field, condition, String.valueOf(this.treeConfig.maxRecs)});

    }

    // label の組織名 に オブジェクト名を追加
    public void updateLabel() {
      // this.label = String.format('{0} ({1})', new String[] { this.label, this.sobjConfig.getSObjectLabel() });
    }

  } // public virtual class AccountsRecordsHolder implements RecordsHolder

  public class SingleAccountRecordsHolder extends AccountsRecordsHolder {
    public override void create(Id targetId) {
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      //  最上位の アカウント ID を得る
      resolveRootAccountFromId(targetId);
      // ルートからの全てのアカウントを得る。
      createAccountList();
      // 全てのアカウントのコンタクトを収集
      createContactList();
    }

    public override void create(String orgName) {
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      //  最上位の アカウント ID を得る
      resolveRootAccountFromOrgName(orgName);
      // ルートからの全てのアカウントを得る。
      createAccountList();
      // 全てのアカウントのコンタクトを収集
      createContactList();
    }

    private override void resolveRootAccountFromId(Id targetId) {
      SObjectType otype = targetId.getSObjectType();
      // (ルートの)アカウントを求める
      if (otype == Account.sObjectType) {
        this.rootAccountId = targetId;
      }
      else {
        Contact cont = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :targetId LIMIT 1];
        this.rootAccountId = cont.AccountId;
      }
    }

    // 組織名を元に (ルートの)アカウント ID を得る
    private override void resolveRootAccountFromOrgName(String orgName) {
      String query = makeRootAccountQuerybyOrgName();
      System.debug(LoggingLevel.INFO, query);
      List<Account> acnts = Database.query(query);
      if (acnts.isEmpty()) {
        throw new SB_Ot_RecordsHolderException('No match orgname account.');
      }
      // 闇雲にソートされた最初のやつで
      this.rootAccountId = acnts[0].Id;
    }

    // アカウントの項目情報を得る
    private override void createAccountList() {
      System.debug(this.rootAccountId);
      if (this.rootAccountId == null) {
        this.acnts = new List<Account>();
        this.matchedAcntIds = new Set<Id>();
        return;
      }
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.sObjectType);
      Set<String> cols = new Set<String>();
      cols.addAll(sobjConfig.getQueryFields());
      cols.add('ParentId');
      cols.add('ownerid');
      cols.add('lastmodifieddate');// 所有者LWC用
      cols.add('site');// 所有者LWCのレコードのラベル用
      String fields = String.join(new List<String>(cols), ', ');
      // Order By
      String orderby = String.join(sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
      String query = String.format(QUERY_1ACCOUNT, new String[]{ fields });
      System.debug(LoggingLevel.INFO, 'createAccountList: ' + query);
      this.acnts = Database.query(query);
      // 合致してるアカウントのうち、対象のオブジェクトの条件にもマッチするアカウントを探す。IDのSetを作る。
      List<String> conditions = new List<String> { 'Id=:rootAccountId' };
      conditions.addAll(sobjConfig.whereExpressions);
      query = String.format('SELECT Id, Name FROM Account WHERE {0}', new String[]{ String.join(conditions, ' AND ') });
      Map<Id, SObject> matchedAccounts = new Map<Id, SObject> (Database.query(query));
      this.matchedAcntIds = new Set<Id> (matchedAccounts.keySet());
    }

    // // 同一アカウント配下のコンタクトを得る。
    // private override void createContactList() {
    //   SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.sObjectType);
    //   Set<String> cols = new Set<String>();
    //   cols.addAll(sobjConfig.getQueryFields());
    //   cols.add('AccountId');
    //   cols.add('ownerid');
    //   cols.add('lastmodifieddate'); // 所有者LWCの用
    //   cols.add('department');// 所有者LWCのレコードのラベル用
    //   cols.add('title');// 所有者LWCのレコードのラベル用
    //   String fields = String.join(new List<String>(cols), ', ');
    //   List<String> conditions = new List<String> { 'AccountId IN :acnts' };
    //   conditions.addAll(sobjConfig.whereExpressions);
    //   String condition = String.join(conditions, ' AND ');
    //   String orderby = String.join(sobjConfig.getOrderByFields(), ' ASC NULLS LAST, ');
    //   String query = String.format(QUERY_TEMPL_WOL,
    //             new String[] { fields, 'Contact', condition, orderBy, String.valueOf(this.treeConfig.maxRecs)});
    //   System.debug(LoggingLevel.INFO, 'createContactList: ' + query);
    //   this.conts = Database.query(query);
    // }

  } // public class SingleAccountRecordsHolder extends AccountsRecordsHolder

  // アカウントへの参照がないコンタクト用 コンタクト１つだけ持ってる
  public class SoloContactHolder extends AccountsRecordsHolder {
    private Id targetId;
    public override void create(Id targetId) {
      this.targetId = targetId;
      this.treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      //
      this.acnts = new List<Account>();
      // コンタクト
      createContactList();
    }
    public override void create(String orgName) {}

    protected override void createContactList() {
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.sObjectType);
      Id pageRecId = this.treeConfig.pageRecordId;
      Set<String> cols = new Set<String>();
      cols.addAll(sobjConfig.getQueryFields());
      cols.add('accountid');
      cols.add('ownerid');
      cols.add('lastmodifieddate'); // 所有者LWCの用
      cols.add('department');// 所有者LWCのレコードのラベル用
      cols.add('title');// 所有者LWCのレコードのラベル用
      if (sobjConfig.showContactRole) {
        cols.add('(SELECT Id, Role, IsPrimary, AccountId FROM AccountContactRoles WHERE AccountId IN :acnts)');    // 商談の取引先責任者の役割
        if (pageRecId!=null) {
          if (pageRecId.getSobjectType() == Opportunity.getSObjectType()) {
            cols.add('(SELECT Id, Role, IsPrimary FROM OpportunityContactRoles WHERE OpportunityId=:pageRecId)');   // 商談の取引先責任者の役割
          }
          else if (pageRecId.getSobjectType() == Case.getSObjectType()) {
            cols.add('(SELECT Id, Role FROM CaseContactRoles WHERE CasesId=:pageRecId)');   // 商談の取引先責任者の役割
          }
          else if (pageRecId.getSobjectType() == Contract.getSObjectType()) {
            cols.add('(SELECT Id, Role, IsPrimary FROM ContractContactRoles WHERE ContractId=:pageRecId)');   // 商談の取引先責任者の役割
          }
        }
      }
      String fields = String.join(new List<String>(cols), ', ');
      String query = String.format('SELECT {0} FROM {1} WHERE Id=:targetId',
                new String[] { fields, 'Contact', 'Id=:targetId'});
      System.debug(LoggingLevel.INFO, 'createContactList: ' + query);
      this.conts = Database.query(query);
    }
  }


  public static SB_Ot_RecordsHolder.RecordsHolder createHolder(SObjectType otype, Object val) {
    SB_Ot_RecordsHolder.RecordsHolder result;
    SB_Ot_OrgTreeConfig treeConfig = SB_Ot_OrgTreeConfig.getInstance();

    if (otype == null && val instanceOf Id && ((Id)val).getSobjectType() == Contact.sObjectType) {
      // コンタクトで、AccoutIdがNULLのケース
      result = new SB_Ot_RecordsHolder.SoloContactHolder();
    }
    else if (otype == Account.sObjectType || otype == Contact.sObjectType) {
      if (treeConfig.accountAssociation) {
        // アカウントの親子関係を取り込む
        result = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
      }
      else {
        // 該当のアカウントだけ
        result = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
      }
    }
    else {
      result = new SB_Ot_RecordsHolder.SingleObjectRecordsHolder(otype);
    }
    // result.create(val instanceOf Id ? (Id)val : (String)val);
    if (val instanceOf Id) {
      result.create((Id)val);
    }
    else {
      result.create((String)val);
    }
    // result.updateLabel();
    // if (holder.members.isEmpty()) {
    //   String oName = this.otype.getDescribe().getLabel();
    //   throw new SB_Ot_OrgTreeFactoryException(String.format(Label.SB_Ot_Msg_NoAltRecord, new String[]{ holder.label, oName }));
    // }
    return result;
  }

}