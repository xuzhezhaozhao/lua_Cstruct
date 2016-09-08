**lua 内置的数据结构 table 对内存的使用率不高, 有些应用场景下, 可能会有很多个 table, 但每个 table 中的字段都是一样的, 由于 table 底层是 hash 表实现, 内存浪费比较严重，这个时候希望能够在 C/C++ 中分配一块连续内存存储这些 table 以提高内存利用率, 另外还希望可以在 lua 中定义结构, 并且方便的访问结构字段. 本程序库提供了接口解决这些问题.**

Authors: zhezhao xu (zhezhao@gmail.com)

NOTES
-----


该程序库基于 lua5.1 开发, clib.c 的头文件包含为 lua5.1/ 目录, 如果需要用于 lua5.2 / 5.3, 稍作修改就可以了(clib.c 中 luaopen_clib 函数用的 luaL_register 函数, 这个函数在 5.2 / 5.3 中不能用, 改成对应的函数就可以了)



Features
-----
  * 用 lua 的语法定义数据结构
  * 结构中可以定义 number(整数或浮点), string (变长), bool 等基本类型的字段
  * 结构支持嵌套
  * 用 C 语言的 malloc 函数分配结构数组的内存 
  * 数组大小动态自动调整
  * 访问字段的方式非常简便, 与访问 lua table 字段的方式类似
  * 高效的内存使用率
  * 由用户管理结构数组的内存





在 lua 中定义数据结构
-----


定义数据结构方法非常简单, 如我想定义如下的结构:

  ```
  struct student {
	  int id;
	  string name;
	  double score;
	  bool good;
  };
  ```

lua 代码为：

  ```
  student = { id = "number", name = "string", score = "number", good = "bool" }
  ```

基本语法就是，定义一个表，表中 key 为结构的字段，对应 value 为字段的数据类型，基本数据类型有 number，string， bool 三种, 其中number类型可以表示整数和浮点数，string 为变长字符串类型，内部实现时保存的是一个指针.




### 嵌套的数据结构
现在我要在 student 结构中增加一个字段，address, 这个字段也是一个结构，其结构定义如下：

  ```
  struct address {
	string city;
	string street;
	int room;
  };

  struct student {
	  int id;
	  string name;
	  double score;
	  bool good;
	  struct address addr;
  };
  ```

lua 代码为：

  ```
  -- 先定义 address 结构
  address = {city = "string", street = "string", room = "number"}
  -- 在 student 中嵌套 address 结构
  student = { id = "number", name = "string", score = "number", good = "bool", addr = address }
  ```


创建结构数组
-----

在 lua 中定义好结构之后, 下面创建结构数组, `make` 编译代码，在当前目录会生成 clib.so 文件. 使用时只需要 `require "cs"` 即可. 创建好的结构数组的大小是动态调整的.

利用 `cs` package 中提供的 `create` 来创建结构数组:
  ```
  require "cs"
  address = {city = "string", street = "string", room = "number"}
  student = { id = "number", name = "string", score = "number", good = "bool", addr = address }
  size = 20 -- 初始创建数组的大小
  -- create 函数放回对应的结构数组 array, array 是 table 类型, array 中的字段与 student 中的一致的, 包括嵌套结构, 即 array.id, array.addr.city 都是存在的
  array = cs.create(student, size)		-- 如果省略 size 参数则默认为 1
  ```
这样就创建了一个初始大小为 20 的数组, .


访问结构数组
------

有两种方法可以访问结构数组:

### 1. get & set 函数
可以用 cs package 提供的 get & set 来读取和设置结构数组中的对应字段:
  ```
  -- 读取第1个元素 id 字段的值
  -- get 函数有两个参数，第一个为访问元素的下标(1起始), 第二个参数为访问字段
  cs.get(1, array.id)	-- 此时 get 将返回 nil, 因为还没有设置过该字段的值

  -- 设置第1个元素 id 字段的值为 1001
  -- set 函数有三个参数，前两个与 get 函数相同，第三个为待设置的值
  cs.set(1, array.id, 1001)

  cs.get(1, array.id)	-- 此时 get 将返回 1001

  -- 字符串类型
  cs.set(1, array.name, "Zhang San")
  cs.get(1, array.name)

  -- 当访问下标大于当前数组大小时，数组会动态增大
  cs.set(30, array.addr.city, "Beijing") -- 30大于数组大小20, 数组大小将增大为 30
  cs.get(30, array.addr.city)	-- 返回 "Beijing"
  ```

### 2. dot 访问方式
用 get & set 函数访问还是比较麻烦，下面提供了另一种更方便的访问方式:
  ```
  array.id[2] = 1002	-- 设置第二个元素 id 字段值为 1002
  array.id[2] 			-- 读取第一个元素 id 字段的值, 返回 1002

  array.addr.city[2] = "Shang Hai"
  array.addr.city[2]
  ```

基本语法就是先指定需要访问的字段，然后加中括号, 中括号中的值为访问的元素下标, 这种访问方式不会引入额外内存.


释放结构数组的内存
------
由 `cs.create` 创建的数组使用的内存是由 C 的 `malloc` 分配的, 在 lua 中是 `light userdata`类型, 需要用户手动 `free`, 否则可能造成内存泄露, 调用 `cs.free` 函数即可释放数组内存.

  ```
  cs.free(array)
  ```
