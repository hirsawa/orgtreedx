/**
 *  SB_Oto_RecordOwnersLwcController
 *  同じ人の名刺を持つユーザ Lightning Web Component の　コントローラ
 *
 *  @author sawano
 *  @Version1 v1.1 2019.11.xx
 *
 **/
public with sharing class SB_Oto_RecordOwnersLwcController {

  @AuraEnabled(cacheable=true)
  public static SB_Oto_RecordOwnersBuilder.GetRecordOwnersResponse getUsersHavingContacts(
        Id targetId, // アカウント or コンタクト のレコードID
        // Boolean excludeMe,    // 自分を除外する
        // Boolean includeCurrentOwner,  // このレコード所有者を含める
        Boolean includeInactiveUser,  // 無効なユーザも含める
        Boolean includeAccountOwner,  // 取引先の所有者を含む
        Boolean accountAssociation, // 親・子取引先の所有者を含める
        Boolean showLastModifiedDate, // 最終更新日を表示する
        String sortField, // 並び替え項目
        Boolean sortAsc,   // 昇順
        String titleFields,  // 所属役職等の表示項目
        String fields) {       // ユーザの表示項目 ToDo

    SB_Oto_RecordOwnersBuilder builder = new SB_Oto_RecordOwnersBuilder(
        targetId, // アカウント or コンタクト のレコードID
        // excludeMe,    // 自分を除外する
        // includeCurrentOwner,  // このレコード所有者を含める
        includeInactiveUser,  // 無効なユーザも含める
        includeAccountOwner,  // 取引先の所有者を含む
        accountAssociation, // 親・子取引先の所有者を含める
        showLastModifiedDate, // 最終更新日を表示する
        sortField, // 並び替え項目
        sortAsc,   // 昇順
        titleFields,  // 所属役職等の表示項目
        fields);       // ユーザの表示項目 ToDo
    return builder.create();
  }
}