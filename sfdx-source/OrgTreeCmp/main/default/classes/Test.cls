public class Test {


  public abstract class Base {
    public String name;
    public Base(String name) {
      this.name = name;
      this.children = new List<Base>();
    }
    public List<Base> children;
    public void addChild(String name) {
      children.add(create(name));
    }
    public abstract Base create(String name);
  }

  public class Hyper extends Base{
    private Integer order;
    public Hyper(String name) {
      super(name);
      this.order = 0;
    }
    // public override addChild(String name) {
    //   this.children
    // }
    public override Base create(String name) {
      return new Hyper(name);
    }
  }


}