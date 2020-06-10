/**
 *
 *  SB_Ot_OrgTreeFactory
 *    クライアントにわたす 階層ノードs を作るコアのクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.0      2019.03.xx
 *
 */
public with sharing class SB_Ot_OrgTreeFactory {

  public class SB_Ot_OrgTreeFactoryException extends Exception {}

  private static SB_Ot_OrgTreeConfig treeConfig {
    get {
      if (treeConfig==null) {
        treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      }
      return treeConfig;
    }
    private set;
  }

  // 表示するツリーの形式
  public enum TreeType {
     tree,      // ツリー
     treeGrid   // ツリーグリッド
  }

  @TestVisible
  public virtual class OrgItemsFactory {
    protected Id targetId;
    @TestVisible protected SB_Ot_DepartmentParser.DepartmentParser deptParser;
    @TestVisible protected SB_Ot_OrgTreeItem.ItemBuilder itemBuilder;
    public Integer allBranchs { get; protected set; }  //  Accountのとき用 Accountの数
    public Integer allStaff { get; protected set; }  //  実際の要素数
    public Integer fillStaff { get; protected set; }  // 実際の処理できた要素数
    public Set<String> hideFields { get; protected set; }  //  Gridで、Account,Contactのとき用 取引先責任者の役割のレコードがないので、列を表示しない

    public void addHideField(String f) {
      if (this.hideFields == null) {
        this.hideFields = new Set<String>();
      }
      this.hideFields.add(f);
    }

    public OrgItemsFactory() {}
    public OrgItemsFactory(Id targetId, TreeType type) {
      this.targetId = targetId;
      this.deptParser = SB_Ot_DepartmentParser.createParser(treeConfig.deptParser);
      if (type == TreeType.treeGrid) {
        this.itemBuilder = new SB_Ot_OrgTreeItem.GridItemBuilder();
      }
      else {
        this.itemBuilder = new SB_Ot_OrgTreeItem.TreeItemBuilder();
      }
    }

    // ルートノードを作る レコードのないノード作る
    protected SB_Ot_OrgTreeItem.Item createRootItem(String label) {
      return this.itemBuilder.createRootItem(label);
    }
    // オブジェクトの ノードを作る
    protected SB_Ot_OrgTreeItem.Item createItem(SObject obj) {
      return this.itemBuilder.createItem(obj);
    }
    protected SB_Ot_OrgTreeItem.Item createItem(Account acnt) { // アカウントのノードを作る
      return this.itemBuilder.createItem(acnt);
    }

    // 他のオブジェクトで階層作るときは overide する。
    protected virtual SB_Ot_RecordsHolder.RecordsHolder createHolder() {
      return SB_Ot_RecordsHolder.createHolder(this.targetId.getSObjectType(), this.targetId);
    }

    // 複数オブジェクトで作る場合は overide する。
    public virtual List<SB_Ot_OrgTreeItem.Item> create() {
      List<SB_Ot_OrgTreeItem.Item> result = new List<SB_Ot_OrgTreeItem.Item>();

      SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder = (SB_Ot_RecordsHolder.SingleObjectRecordsHolder)createHolder();

      // ルートノードのインスタンス化
      SB_Ot_OrgTreeItem.Item rootItem = createRootItem(holder.label);
      createItems(holder, rootItem);
      result.add(rootItem);
      rootItem.finalize();
      return result;
    }

    protected void createItems(SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder, SB_Ot_OrgTreeItem.Item rootItem) {
      String currentDept;
      List<String> previousBranch = new List<String>();
      List<String> currentBranch = new List<String>();
      Integer maxTime = Limits.getLimitCpuTime() - SB_Ot_Global.otConfig.TimeoutMargin__c.intValue();  // 諦める期限
      Integer staffCnt = 0;
      // for (SObject obj: holder.members) {
      for (; staffCnt < holder.members.size(); staffCnt++) {
        SObject obj = holder.members.get(staffCnt);
          // 末端ノード作成
        SB_Ot_OrgTreeItem.Item item = createItem(obj);
        if (obj.id == this.targetId) {
          item.setSelected();
        }
        if (String.isNotBlank(item.org) || String.isNotBlank(item.dept)) { // v1.0.2 2019.04.19 所属がNULLってありえる。
          String shrinkedDept = item.org + item.dept.replaceAll('[\\s\\r\\n　]', '');  // 空白改行を除いた文字列
          if (shrinkedDept != currentDept) {   // 部署が変わった？
            currentDept = shrinkedDept;
            currentBranch.clear();
            System.debug(LoggingLevel.INFO, 'currentDept: ' + currentDept);
            if (String.isNotBlank(item.org)) {
              currentBranch.add(item.org);
            }
            if (String.isNotBlank(item.dept)) {
              currentBranch.addAll(deptParser.parse(item.dept, previousBranch));
              previousBranch.clear();
              previousBranch.addAll(currentBranch);
            }
          }
        }
        else if (!currentBranch.isEmpty())  {  // v1.0.3 2019.04.19 最初のがNULLだったら
          currentBranch.clear();
        }
        // ルートノードにブランチを指定してノードを追加
        System.debug(LoggingLevel.INFO, item.label);
        rootItem.addItem(currentBranch, item);
        if (maxTime < Limits.getCpuTime()) {
          System.debug('CPU Limit time. Count: ' +  staffCnt);
          maxTime -= Limits.getCpuTime();
          break;
        }
      }
      this.allBranchs = 1;
      this.allStaff = holder.members.size();
      this.fillStaff = staffCnt;
    }

  } // private virtual class OrgItemsFactory {

  // 選択レコードと別のオブジェクトで階層を作る
  private class AltOrgItemsFactory extends OrgItemsFactory {
    private SObjectType otype;
    public AltOrgItemsFactory(Id targetId, SObjectType otype, TreeType type) {
      super(targetId, type);
      this.otype = otype;
    }
    protected override SB_Ot_RecordsHolder.RecordsHolder createHolder() {
      List<SObjectType> otypes = new List<SObjectType>{ this.otype };
      SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, this.targetId);
      detector.run();
      Object val = detector.getConnectionValue(this.otype); //
      return SB_Ot_RecordsHolder.createHolder(this.otype, val);
    }
  }     // private class AltOrgItemsFactory extends OrgItemsFactory {

  private virtual class AccountOrgItemsFactory extends OrgItemsFactory {
    private Map<Id, SB_Ot_OrgTreeItem.Item> acntMap;
    public AccountOrgItemsFactory(Id targetId, TreeType type) {
      super(targetId, type);
      this.acntMap = new Map<Id, SB_Ot_OrgTreeItem.Item>();
    }

    protected virtual override SB_Ot_RecordsHolder.RecordsHolder createHolder() {
      return SB_Ot_RecordsHolder.createHolder(this.targetId.getSobjectType(), this.targetId);
    }

    public virtual override List<SB_Ot_OrgTreeItem.Item> create() {
      List<SB_Ot_OrgTreeItem.Item> result = new List<SB_Ot_OrgTreeItem.Item>();
      // Enterprise org = new Enterprise();
      SB_Ot_RecordsHolder.AccountsRecordsHolder holder = (SB_Ot_RecordsHolder.AccountsRecordsHolder)createHolder();
      // if (holder.acnts.isEmpty()) {
      //   return result;
      // }
      SB_Ot_OrgTreeItem.Item rootItem = createAcountContactImtes(holder);
      result.add(rootItem);
      rootItem.finalize();
      return result;
    }

    protected SB_Ot_OrgTreeItem.Item createAcountContactImtes(SB_Ot_RecordsHolder.AccountsRecordsHolder holder) {
      Set<Id> haveChildren = new Set<Id>(); // 子取引先のいる取引先たちのID
      // アカウントのITEMを作成
      for (Account acnt : holder.acnts) {
        SB_Ot_OrgTreeItem.Item item = createItem(acnt);
        if (this.targetId == acnt.Id) {
          item.setSelected();
        }
        this.acntMap.put(acnt.Id, item);
        if (acnt.ParentId != null) { // 親がいるとき親IDをとっておく、NULLでもいれてもいいけど、
          haveChildren.add(acnt.ParentId);
        }
      }
      if (holder.acnts.isEmpty()) {
        SB_Ot_OrgTreeItem.Item item = createRootItem(System.Label.SB_Ot_Text_NotHaveAccount);  // 取引先の指定なし
        this.acntMap.put(null, item);
      }
      // コンタクトのITEM作成
      String currentDept;
      List<String> currentBranch;
      String currentAcntId;
      Integer maxTime = Limits.getLimitCpuTime() - SB_Ot_Global.otConfig.TimeoutMargin__c.intValue();  // 諦める期限
      Integer staffCnt = 0;
      // for (Contact cont : holder.conts) {
      for (; staffCnt < holder.conts.size(); staffCnt++) {
        Contact cont = holder.conts.get(staffCnt);
        // 末端ノード作成
        SB_Ot_OrgTreeItem.Item item = createItem(cont);
        if (this.targetId == cont.Id) {
          item.setSelected();
        }
        if (cont.AccountId != currentAcntId || item.dept != currentDept) {
          currentAcntId = cont.AccountId;
          currentDept = item.dept;
          currentBranch  = deptParser.parse(currentDept, currentBranch);
        }
        SB_Ot_OrgTreeItem.Item acntItem = this.acntMap.get(cont.AccountId);
        // アカウントにコンタクトを追加
        acntItem.addItem(currentBranch, item);
        if (maxTime < Limits.getCpuTime()) {
          System.debug('CPU Limit time. Count: ' +  staffCnt);
          maxTime -= Limits.getCpuTime();
          break;
        }
      }
      // アカウントの階層を解決 と、期日と対象の条件 にあわなくて、配下のないアカウントを排除
      for (Account acnt : holder.acnts) {
        if (acnt.ParentId != null && this.acntMap.containsKey(acnt.ParentId)) {
          SB_Ot_OrgTreeItem.Item parent = this.acntMap.get(acnt.ParentId);
          SB_Ot_OrgTreeItem.Item branch = this.acntMap.get(acnt.Id);
          if (!branch.items.isEmpty() ||
            haveChildren.contains(acnt.Id) ||   // 子取引先だけいる場合
            // (SB_Ot_Global.otConfig.AccountDateRange__c == 0 && SB_Ot_Global.otConfig.AccountOtherCondition__c == 0) &&// カスタム設定の 期日の範囲、対象レコードの条件 どちらもなく
            holder.matchedAcntIds.contains(acnt.Id)) {
            // 配下がある(コンタクトがいる か 子取引先がいる) か
            // 呼び出し条件の 期日の範囲、対象レコードの条件 に合致すれば、
            // 階層に加える。→ つまり、 配下がなく、期日の範囲、対象レコードの条件 にあわければ、階層に加えない
            parent.addBranch(branch);
          }
        }
      }

      // ルートノードの
      SB_Ot_OrgTreeItem.Item rootItem = this.acntMap.get(holder.rootAccountId);
      if(rootItem.items.isEmpty() && !holder.matchedAcntIds.contains(holder.rootAccountId)) {
        // ルートの取引先、配下がない、かつ、自身が条件にあってない → 何も表示しない
        throw new SB_Ot_OrgTreeFactoryException(System.Label.SB_Ot_Msg_NoAvailableRecords);
      }
      this.allBranchs = holder.acnts.size();
      this.allStaff = holder.conts.size();
      this.fillStaff = staffCnt;
      if (holder.hideContactRoleCol) {
        this.addHideField('contactrole');
      }
      return rootItem;
    }

  }     // private virtual class AccountOrgItemsFactory extends OrgItemsFactory

  // 選択レコードと別のオブジェクトで階層を作る
  private class AltAccountOrgItemsFactory extends AccountOrgItemsFactory {
    private SObjectType otype;

    public AltAccountOrgItemsFactory(Id targetId, SObjectType otype, TreeType type) {
      super(targetId, type);
      System.assert(otype==Account.getSObjectType());// Accountのはず。
      this.otype = otype;
    }

    protected override SB_Ot_RecordsHolder.RecordsHolder createHolder() {
      List<SObjectType> otypes = new List<SObjectType>{ this.otype };
      SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, this.targetId);
      detector.run();
      Object val = detector.getConnectionValue(this.otype); //
      SB_Ot_RecordsHolder.AccountsRecordsHolder holder;
      if (val !=null) {
        holder =
            (SB_Ot_RecordsHolder.AccountsRecordsHolder)SB_Ot_RecordsHolder.createHolder(Account.getSobjectType(), val);
        if (holder.acnts.isEmpty()) {
          String oName = Account.getSObjectType().getDescribe().getLabel();
          throw new SB_Ot_OrgTreeFactoryException(String.format(Label.SB_Ot_Msg_NoAltRecord, new String[]{ (String)val, oName }));
        }
      }
      else if (this.targetId.getSobjectType() == Contact.getSObjectType()){
        // Contact のAccountIdがNULLのとき
        holder =
            (SB_Ot_RecordsHolder.AccountsRecordsHolder)SB_Ot_RecordsHolder.createHolder(null, this.targetId);
      }
      return holder;
    }
  }   // private class AltAccountOrgItemsFactory extends AccountOrgItemsFactory {

  // 複数オブジェクトから階層を作る
  private class MultiOrgItemsFactory extends AccountOrgItemsFactory {
    private List<SObjectType> srcOtypes;
    private SB_Ot_MultiObjectConfig multiConfig;

    public MultiOrgItemsFactory(Id targetId, List<SObjectType> srcOtypes, TreeType type) {
      super(targetId, type);
      this.srcOtypes = new List<SObjectType>();
      this.srcOtypes.addAll(srcOtypes);
      this.multiConfig = SB_Ot_MultiObjectConfig.getInstance();
    }

    public override List<SB_Ot_OrgTreeItem.Item> create() {
      List<SB_Ot_OrgTreeItem.Item> result = new List<SB_Ot_OrgTreeItem.Item>();

      SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(this.srcOtypes, this.targetId);
      detector.run();
      SB_Ot_OrgTreeItem.Item rootItem;
      // Account, Contact を先に処理
      if (this.srcOtypes.contains(Account.getSObjectType())) {
        Object val = detector.getConnectionValue(Account.getSObjectType());
        SB_Ot_RecordsHolder.AccountsRecordsHolder holder =
            (SB_Ot_RecordsHolder.AccountsRecordsHolder)SB_Ot_RecordsHolder.createHolder(Account.getSObjectType(), val);
        rootItem = createAcountContactImtes(holder);
        // Account, Contact をリストから抜いとく。
        this.srcOtypes.remove(this.srcOtypes.indexOf(Account.getSObjectType()));
        this.srcOtypes.remove(this.srcOtypes.indexOf(Contact.getSObjectType()));
      }
      for (Schema.SObjectType otype : this.srcOtypes) {
        Object val = detector.getConnectionValue(otype);
        SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder =
          (SB_Ot_RecordsHolder.SingleObjectRecordsHolder)SB_Ot_RecordsHolder.createHolder(otype, val);
        if (rootItem == null) {
          rootItem = createRootItem(holder.label);
        }
        createItems(holder, rootItem);
      }
      result.add(rootItem);
      return result;
    }

  } // private class MultiOrgItemsFactory extends OrgItemsFactory {
    public static OrgItemsFactory createOrgItemsFactory(Id targetId, Schema.SObjectType otype, TreeType mode) {
      return null;
    }


  // 対象のレコードIDから グリッド ITEM を作るクラスを インスタンス化して返す
  public static OrgItemsFactory createOrgItemsFactory(Id targetId, Schema.SObjectType otype, SB_Ot_OrgTreeConfig.ItemDisplayMode mode) {
    OrgItemsFactory result = null;
    TreeType type = mode == SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree ? TreeType.tree : TreeType.treeGrid;
    if (targetId.getSobjectType() == Account.sObjectType || targetId.getSobjectType() == Contact.sObjectType) {
      result = new AccountOrgItemsFactory(targetId, type);
    }
    else {
      result = new OrgItemsFactory(targetId, type);
    }
    // if (targetId.getSobjectType() == otype) {
    //   // 選択レコードで階層を作る
    //   if (otype == Account.sObjectType || otype == Contact.sObjectType) {
    //     result = new AccountOrgItemsFactory(targetId, type);
    //   }
    //   else {
    //     result = new OrgItemsFactory(targetId, type);
    //   }
    // }
    // else if (otype != null) {
    //   // 選択レコードと別のオブジェクトで階層を作る
    //   if (otype == Account.sObjectType) {
    //     result = new AltAccountOrgItemsFactory(targetId, otype, type);
    //   }
    //   else {
    //     result = new AltOrgItemsFactory(targetId, otype, type);
    //   }
    // }
    // else {
    //   // 複数オブジェクトで階層をつくる
    //   List<SObjectType> srcOtypes = SB_Ot_MultiObjectConfig.getInstance().getSObjectTypeList(SB_Ot_MultiObjectConfig.MULTI_OBJECT_SYMBOL);
    //   result = new MultiOrgItemsFactory(targetId, srcOtypes, type);
    // }
    return result;
  }

  /**
  *  アカウント・コンタクト、リード、カスタムオブジェクト 同一組織 の階層表現の作成
  **/
  // ツリー形状の組織階層　の ノード のリストを返す
  //  sourceObject: レコードを収集する 構築するオブジェクトの指定 null ならIDと一緒
  @TestVisible // テストだけ
  private static List<SB_Ot_OrgTreeItem.Item> createOrgTreeItems(String targetId, Schema.SObjectType otype) {
    OrgItemsFactory factory = createOrgItemsFactory(targetId, otype,  SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree);
    return (List<SB_Ot_OrgTreeItem.Item>)factory.create();
  }

  // ツリーグリッド形状の組織階層　の ノード のリストを返す
  //  sourceObject: レコードを収集する 構築するオブジェクトの指定 null ならIDと一緒
  @TestVisible // テストだけ
  private static List<SB_Ot_OrgTreeItem.Item> createOrgGridItems(String targetId, Schema.SObjectType otype) {
    OrgItemsFactory factory = createOrgItemsFactory(targetId, otype, SB_Ot_OrgTreeConfig.ItemDisplayMode.Grid);
    return (List<SB_Ot_OrgTreeItem.Item>)factory.create();
  }

}