// 部署名を分割して返す。
public with sharing class SB_Ot_DepartmentParser {

  public interface DepartmentParser {
    List<String> parse(String dept, List<String> previousNodes);
  }

  // 前の 部署階層（ブランチ）と比べて、上部の層が同一だったら、その配下にする  ComparisionParser はこれだけ
  private static List<String> comparisionParse(String dept, List<String> previousNodes) {
    List<String> result = new List<String>();
    if (String.isBlank(dept)) {
      return result;
    }
    if (previousNodes == null || previousNodes.isEmpty()) {
      result.addAll(dept.trim().split('\\r*\\n'));   // 改行では分ける
      return result;
    }
    String[] remains = dept.trim().split('\\r*\\n');    // 改行で分けてから比較する
    Integer indexPrv = 0;
    for (String remain : remains) {
      for (; indexPrv < previousNodes.size(); indexPrv++) {
        String node = previousNodes[indexPrv];
        // 同一の層で 前のと同じ
        if (remain == node) {
          result.add(node);
          remain = '';      // 残りなし
        }
        else if (remain.startsWithIgnoreCase(node)) {
          // 同一の層で 前のと同じ だが 下位の層がある。
          result.add(node);
          remain = remain.removeStartIgnoreCase(node).trim();
        }
        else {
          // 同一の層で 前のと違う部分があった → ここで終わり
          indexPrv = previousNodes.size(); // もう前のと比べない
          break;
        }
        if (String.isBlank(remain)) {
          // 残りがなければ、次の層を調べる。
          break;
        }
      }
      if (String.isNotBlank(remain)) {
        // 残ったのを追加。残った行も順に追加
        result.add(remain);
      }
    }
    return result;
  }

  private class NoopParser implements DepartmentParser {
    public List<String> parse(String dept, List<String> previousNodes) {
      List<String> result = new List<String>();
      if (String.isNotBlank(dept)) {
        result.add(dept);
      }
      return result;
    }
  }

  private class SeparaterParser implements DepartmentParser {
    public List<String> parse(String dept, List<String> previousNodes) {
      if (String.isNotBlank(dept) && dept.isAsciiPrintable()) {
        // 英語のみなら
        return comparisionParse(dept, previousNodes);
      }
      List<String> result = new List<String>();
      if (String.isBlank(dept)) {
        return result;
      }
      String[] ss = dept.split(SB_Ot_Global.otConfig.DepartmentParserSeparater__c); // 
      // String[] ss = dept.split('[\\s\\n]'); // 
      String sub = '';
      String remain = dept.trim();
      for (Integer n=0; n < ss.size(); n++) {
        if (String.isNotBlank(sub)) {
          sub += remain.substringBefore(ss[n]);  // ??? + セパレータ
        }
        sub +=  + ss[n] ; // + ss[n]
        remain = remain.substringAfter(ss[n]); // 残り
        // if (String.isNotBlank(remain) && !ss[n].isAsciiPrintable() && ss[n].length()!=1 && (n<ss.size()-1 && ss[n+1].length()!=1)) {
          // 途中で、英数字でない、かつ 1文字でない かつ 次が1文字でない なら そこで区切る
        if (String.isNotBlank(remain) && !ss[n].isAsciiPrintable() && ss[n].length()!=1
                  && (n<ss.size()-1 && ss[n+1].length()!=1 && !ss[n+1].startsWith('兼'))) {
          // 途中で、英数字でない、かつ 1文字ででない かつ 次が1文字でない かつ 次は兼ではじまらない なら そこで区切る  '社長室 兼企画室 兼IR室' は1つのノードにする
          result.add(sub);
          sub = '';
        }
        else if (String.isBlank(remain)) {
          // 最後
          result.add(sub);
        }
      }
      return result;
    }
  }

  // 改行でわける
  private class LineParser implements DepartmentParser {
    public List<String> parse(String dept, List<String> previousNodes) {
      List<String> result = new List<String>();
      if (String.isBlank(dept)) {
        return result;
      }
      // String[] ss = dept.split('\r\n|\n');  // \r\n のがある
      String[] ss = dept.split('\\r*\\n');  // \r\n のがある
      Integer n =0;
      for (; n< ss.size(); n++) {
        if (previousNodes != null && n < previousNodes.size()) {
          if (ss[n] == previousNodes[n]) {
            result.add(ss[n]);
          }
          else if (ss[n] != previousNodes[n]) {
            if (ss[n].startsWith(previousNodes[n])) {
              result.add(previousNodes[n]);
              result.add(ss[n].removeStart(previousNodes[n]).trim());
            }
            else {
              result.add(ss[n]);
            }
            n++;
            break;
          }
        }
        else {
          result.add(ss[n]);
          n++;
          break;
        }
      }
      for (;n<ss.size(); n++) {
        result.add(ss[n]);
      }
      return result;
    }
  }

  // 前のブランチと比べて、部署名文字列に余りがあれば、余り文字列部分は配下のノードにする。
  private class ComparisionParser implements DepartmentParser {
    public List<String> parse(String dept, List<String> previousNodes) {
      return comparisionParse(dept, previousNodes);
    }
  }


  // 正規表現で分割する。
  //  全部ASCII か 空白で区切る 正規表現: ^[\u0000-\u007F]*$|\s
  private class RegexParser implements DepartmentParser {
    public List<String> parse(String dept, List<String> previousNodes) {
      List<String> result = new List<String>();
      if (String.isBlank(dept)) {
        return result;
      }
      // '.+社|.+支社|.+支局|.+事業部|.+本部|.+部門|.+事業所|.+営業部|.+営業所|.+出張所|.+部|.+室|.+課|.+係|.+グループ'
      Pattern p = Pattern.compile(SB_Ot_Global.otConfig.DepartmentParserRegex__c);
      Matcher m = p.matcher(dept.trim());
      Integer s =0;
      while(m.find()){ // 検索(find)し、マッチする部分文字列がある限り繰り返す
        for (Integer j = 0; j <= m.groupCount(); j++) {
          String div = dept.substring(s, m.end(j));
          if (String.isNotBlank(div)) {
            result.add(div.trim()); // 全部トリムしないと最上位の部署のみの名刺とその配下の部署が存在し、
          }
          s = m.end(j);
        }
      }
      if (dept.length() > s) {
        String last = dept.substring(s).trim();
        if (String.isNotBlank(last)) { // 複数行の場合に改行だけくるかも
          result.add(last);
        }
      }
      return result;
    }
  }


//       List<String> result = new List<String>();
//       String dept = 'プロダクト事業部 営業部 SV営業課';
// //      String dept = 'Productivity and Business Processes';
// //      Pattern p = Pattern.compile('^\\p{ASCII}*$');
//       Pattern p = Pattern.compile('^[\\u0000-\\u007F]*$|\\s');
//       Matcher m = p.matcher(dept);
//       Integer s =0;
//       while(m.find()){ // 検索(find)し、マッチする部分文字列がある限り繰り返す
//         for (Integer j = 0; j <= m.groupCount(); j++) {
//           String div = dept.substring(s, m.end(j));
//           if (String.isBlank(div) == false)
//           result.add(div.trim()); // 全部トリムしないと最上位の部署のみの名刺とその配下の部署が存在し、
//           s = m.end(j);
//         }
//       }
//       if (dept.length() > s) {
//         result.add(dept.substring(s).trim());
//       }
//     for (String r : result) {
//         System.debug(r);
//     }


//   public enum DepartmentParser { Separator,  // 空白で区切って階層化する。ただし、英数字のみの語は他に連結する。区切ったノード名で長さ比較する(OrderBYしておく)
//                               Comparision,   // OrderBYしておいて、前レコードと比較して長い部分を階層化する。
//                               Regex,      // 正規表現
//                               Noop }      // 部署項目の値を分割しないでそのまま使う

  // private static DepartmentParser instance;

  // public static DepartmentParser getParser(SB_Ot_OrgTreeConfig.DepartmentParser type) {
  //   if (instance != null) {
  //     return instance;
  //   }
  //   if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Separator) {
  //     instance = new SB_Ot_DepartmentParser.SeparaterParser();
  //   }
  //   else if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Comparision) {
  //     instance = new SB_Ot_DepartmentParser.ComparisionParser();
  //   }
  //   else if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Regex) {
  //     instance = new SB_Ot_DepartmentParser.RegexParser();
  //   }
  //   else {
  //     instance = new SB_Ot_DepartmentParser.NoopParser();
  //   }
  //   return instance;
  // }

  public static DepartmentParser createParser(SB_Ot_OrgTreeConfig.DepartmentParser type) {
    DepartmentParser result;
    if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Separator) {
      result = new SB_Ot_DepartmentParser.SeparaterParser();
    }
    else if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Line) {
      result = new SB_Ot_DepartmentParser.LineParser();
    }
    else if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Comparision) {
      result = new SB_Ot_DepartmentParser.ComparisionParser();
    }
    else if (type == SB_Ot_OrgTreeConfig.DepartmentParser.Regex) {
      result = new SB_Ot_DepartmentParser.RegexParser();
    }
    else {
      result = new SB_Ot_DepartmentParser.NoopParser();
    }
    return result;
  }




}