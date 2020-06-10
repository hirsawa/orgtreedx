public with sharing class SB_Ot_TitleOrderMaker {

  @TestVisible
  private static Map<String, Integer> titleOrder {
    get {
      if (titleOrder == null) {
        titleOrder = new Map<String, Integer>();
        String[] ss = Label.SB_Ot_TitleOrder.split('[,\\s]+');
        for (Integer n=0; n < ss.size(); n++) {
          titleOrder.put(ss[n], n);
        }
      }
      return titleOrder;
    }
    private set;
  }

  @TestVisible
  private static final Map<String, Integer> TITLE_ORDER_MAP = new Map<String, Integer> {
    '会長' => 0,
    '社長' => 1,
    'CEO' => 2,
    '副社長' => 3,
    'COO' => 4,
    '専務' => 5,
    '常務' => 7,
    '事業部長' => 9,
    '本部長' => 11,
    '部長' => 13,
    '副部長' => 14,
    'チームマネージャ' => 15,
    'チームマネージャー' => 15,
    'シニアマネージャ' => 17,
    'シニアマネージャー' => 17,
    '次長' => 19,
    '局長' => 21,
    'マネージャ' => 23,
    'マネージャー' => 23,
    '室長' => 25,
    '副室長' => 26,
    'グループ長' => 28,
    'グループリーダ' => 30,
    'グループリーダー' => 30,
    '課長' => 32,
    '参事' => 34,
    '副課長' => 34,
    '課長補佐' => 35,
    'チームリーダ' => 37,
    'チームリーダー' => 37,
    '主幹' => 39,
    '副主幹' => 40,
    '主査' => 41,
    '副主査' => 42,
    '係長' => 43,
    '副係長' => 44,
    '主任' => 45,
    '副主任' => 46,
    'チーフ' => 47,
    'チームサブリーダ' => 49,
    'チームサブリーダー' => 49
  };

  // 役職の順位ぎめ
  public static Integer getTitleOrder(String title) {
    if (String.isBlank(title)) {
      // 役職はない
      return 999;
    }
    else if (TITLE_ORDER_MAP.containsKey(title)) {
      return TITLE_ORDER_MAP.get(title);
    }
    for (String t : TITLE_ORDER_MAP.keySet()) {
      if (title.startsWith('副') && title.endsWith(t)) {
        return TITLE_ORDER_MAP.get(t)+1;
      }
      if (title.endsWith(t)) {
        return TITLE_ORDER_MAP.get(t);
      }
      if (title.endsWith(t+'代理')) {
        return TITLE_ORDER_MAP.get(t)+1;
      }
    }
    if (title.startsWith('副')) {
      // その他の 副 で始まる役職
      return TITLE_ORDER_MAP.size()+1;
    }
    if (title.endsWith('長')) {
      // その他の 長 で終わる役職
      return TITLE_ORDER_MAP.size();
    }
    if (title.endsWith('代理')) {
      // その他の 代理 で終わる役職
      return TITLE_ORDER_MAP.size()+1;
    }
    // 役職はあるにはある
    return 990;
  }

}