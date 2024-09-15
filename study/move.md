# Move 学习



## 概念



### Package

Move是一种用于编写智能合约的语言-在区块链上存储和运行的程序。一个程序被组织成一个包。一个包发布在区块链上，并由一个地址标识。可以通过发送调用其函数的事务来与已发布的包进行交互。它也可以作为其他包的依赖项。

```rust
package 0x...
    module a
        struct A1
        fun hello_world()
    module b
        struct B1
        fun hello_package()

```

#### Package Structure

在本地，包是一个包含`Move.toml`文件和`sources`目录的目录。`toml`文件-称为“包清单”-包含有关包的元数据，而`sources`目录包含模块的源代码。软件包通常看起来像这样：

```shell
sources/
    my_module.move
    another_module.move
    ...
tests/
    ...
examples/
    using_my_module.move
Move.toml

```

`tests`目录是可选的，包含包的测试。放在`测试`目录中的代码不会发布在链上，只在测试中可用。`examples`目录可用于代码示例，也不会在链上发布。



#### Published Package

在开发过程中，包没有地址，需要设置为`0x0`。一旦一个包被发布，它就会在区块链上获得一个**唯一的地址**，其中包含其模块的字节码。已发布的包变得*不可变*，可以通过发送事务进行交互。







### Package Manifest

```toml
[package]
// 这个部分用于描述包。本节中的所有字段都没有发布到chain上，但它们用于工具和发布管理;它们还指定了编译器的Move版本。
name = "my_project" //导入时包的名称;
version = "0.0.0"
edition = "2024" //Move语言的版本;目前，唯一有效的值是2024。

[dependencies]
//用于指定项目的依赖项。每个依赖项都被指定为一个键-值对，其中键是依赖项的名称，值是依赖项规范。依赖项规范可以是git仓库URL或本地目录的路径。å
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }

[addresses]
// 部分用于为地址添加别名。可以在此部分中指定任何地址，然后在代码中用作别名。例如，如果将alice =“0xA11CE”添加到此部分，则可以在代码中将alice用作0xA11CE。
std =  "0x1"
alice = "0xA11CE"

[dev-addresses]
//与[addresses]相同，但仅适用于测试和开发模式。重要的是要注意，这是不可能在这一节中引入新的别名，只有覆盖现有的。
alice = "0xB0B"
```



## 语法

### Model

Model是Move中代码组织的基本单位。模块用于分组和隔离代码，默认情况下，模块的所有成员都是模块的私有成员。



#### Module declaration

模块是使用`module`关键字声明的，后面跟着包地址、模块名称和花括号`{}`内的模块主体。模块名应该是`snake_case`-所有的单词之间带下划线的小写字母。模块名称在包中必须是唯一的。

```rust
module book::my_module {
    // module body
}
```

模块地址可以指定为两种：地址*文字*（不需要`@`前缀）或[包清单](https://move-book.com/concepts/manifest.html)中指定的命名地址。在下面的示例中，两者是相同的，因为`Move.toml`的`[addresses]`部分中有一条`book =“0x 0”`记录。

```rust
module 0x0::address_literal { /* ... */ }
module book::named_address { /* ... */ }
```

```toml
# Move.toml
[addresses]
book = "0x0"
```





### Comments

注释是添加注释或记录代码的一种方式。它们被编译器忽略，不会导致Move字节码。您可以使用注释来解释代码的作用，为自己或其他开发人员添加注释，临时删除代码的一部分，或生成文档。移动中有三种类型的注释：行注释、块注释和文档注释。

```rust
/// Module has documentation!
module book::comments_line {
    fun some_function() {
        // this is a comment line
    }
  
     fun /* you can comment everywhere */ go_wild() {
        /* here
           there
           everywhere */ let a = 10;
        let b = /* even here */ 10; /* and again */
        a + b;
    }
  
    /// This function does something!
    /// And it's documented!
    fun do_something() {}
}
```



### Primitive Types

基本类型

Move有许多内置的基本类型。它们是构成所有其他类型的基础。基本类型是：

- Booleans 布尔值
- Unsigned Integers 无符号整数
- Address 地址



#### Variables and assignment

变量使用`let`关键字声明。默认情况下，它们是不可变的，但可以使用`let mut`关键字将其变为可变的。`let mut`语句的语法是：

```rust
let <variable_name>[: <type>]  = <expression>;
let mut <variable_name>[: <type>] = <expression>;


let x: bool = true;
let mut y: u8 = 42;
```

#### Integer Types

整数类型

- `u8` - 8-bit
- `u16` - 16-bit
- `u32` - 32-bit
- `u64` - 64-bit
- `u128` - 128-bit
- `u256` - 256-bit

与布尔类型不同，整数类型需要被推断。在大多数情况下，编译器将从值中推断类型，通常默认为`u64`。但是，有时编译器无法推断类型，需要显式的类型批注。它可以在赋值过程中提供，也可以通过使用类型后缀提供。

```rust
let x: u8 = 42;
let y: u16 = 42;
// ...
let z: u256 = 42;

// Both are equivalent
let x: u8 = 42;
let x = 42u8;
```



Move支持整数类型之间的显式转换。它的语法是：

```rust
<expression> as <type>
let z = 2 * (x as u16);
let y: u16 = x as u16;
```



Move不支持上溢/下溢，导致值超出类型范围的操作将引发运行时错误。这是一个安全功能，以防止意外的行为。





#### Address Type

为了表示地址，Move使用了一种特殊的类型，称为`address`。它是一个32字节的值，可用于表示区块链上的任何地址。地址以两种语法形式使用：以`0x为`前缀的十六进制地址和命名地址。

```rust
// address literal
let value: address = @0x1;

// named address registered in Move.toml
let value = @std;
let other = @sui;

```



### Struct

Move的类型系统在定义自定义类型时非常出色。用户定义的类型可以根据应用程序的特定需求进行定制。不仅在数据层面，而且在其行为方面。

若要定义自定义类型，可以使用`struct`关键字后跟类型名称。在名称之后，您可以定义结构的字段。每个字段都使用`field_name：field_type`语法定义。字段定义必须用逗号分隔。字段可以是任何类型，包括其他结构。

```rust
/// A struct representing an artist.
public struct Artist {
    /// The name of the artist.
    name: String,
}

/// A struct representing a music record.
public struct Record {
    /// The title of the record.
    title: String,
    /// The artist of the record. Uses the `Artist` type.
    artist: Artist,
    /// The year the record was released.
    year: u16,
    /// Whether the record is a debut album.
    is_debut: bool,
    /// The edition of the record.
    edition: Option<u16>,
}
```

默认情况下，结构是私有的，这意味着它们不能在定义它们的模块之外导入和使用。它们的字段也是私有的，不能从模块外部访问。



#### Create and use an instance

我们描述了结构*定义是*如何工作的。现在让我们看看如何初始化一个结构体并使用它。一个结构体可以使用 `struct_name { field1: value1, field2: value2, ... }` 语法初始化。可以按任何顺序初始化这些字段，并且必须设置所有字段。

```rust
let mut artist = Artist {
    name: b"The Beatles".to_string()
};
```



#### Unpacking a struct

解包一个结构意味着将它解构到它的字段中。这是通过使用`let`关键字后跟结构名称和字段名称来完成的。



```rust
// Unpack the `Artist` struct and create a new variable `name`
// with the value of the `name` field.
let Artist { name } = artist;


// 在上面的例子中，我们解压缩Artist结构，并创建一个新的变量name，其值为name字段。由于未使用变量，编译器将发出警告。若要隐藏此警告，可以使用下划线_来指示该变量未被有意使用。
let Artist { name: _ } = artist;
```





### Abilities: Introduction

Abilities一种允许类型进行某些行为的方式。它们是结构声明的一部分，定义结构实例允许的行为。

在结构定义中，使用`has`关键字后跟一个能力列表来设置能力。能力之间用逗号隔开。Move支持4种功能：`复制`、`删除`、`键`和`存储`，每种功能都用于定义结构实例的特定行为。

```rust
/// This struct has the `copy` and `drop` abilities.
struct VeryAble has copy, drop {
    // field: Type1,
    // field2: Type2,
    // ...
}
```

除了引用之外，所有内置类型都具有`复制`、`删除`和`存储`功能。引用具有`复制`和`删除`功能。

- copy 允许复制结构
- drop 允许*删除*或*丢弃*结构
- key 允许将结构体用作存储中的键
- store 允许将结构体*存储*在具有*key*能力的结构体





没有能力的结构不能被丢弃、复制或存储在存储器中。我们称这样的结构为*Hot Potato*。这是一个笑话，但它也是一个很好的方式来记住，一个没有能力的结构就像一个烫手山芋-它只能被传递，需要特殊的处理。Hot Potato是Move中最强大的模式之



#### Abilities: Drop

`drop`功能是其中最简单的功能，它允许*忽略*或*丢弃*结构的实例。在许多编程语言中，这种行为被认为是默认的。但是，在Move中，不允许忽略没有`drop`能力的结构。这是Move语言的一个安全特性，它确保所有资产都得到正确处理。尝试忽略没有`删除`功能的结构将导致编译错误。

```rust
module book::drop_ability {
    /// This struct has the `drop` ability.
    public struct IgnoreMe has drop {
        a: u8,
        b: u8,
    }

    /// This struct does not have the `drop` ability.
    public struct NoDrop {}

    #[test]
    // Create an instance of the `IgnoreMe` struct and ignore it.
    // Even though we constructed the instance, we don't need to unpack it.
    fun test_ignore() {
        let no_drop = NoDrop {};
        let _ = IgnoreMe { a: 1, b: 2 }; // no need to unpack

        // The value must be unpacked for the code to compile.
        let NoDrop {} = no_drop; // OK
    }
}
```

Move中的所有基本类型都具有`drop`能力。这包括：

- bool  布尔
- integers 无符号整数
- vector 向量
- address 地址



### Importing Modules

Move通过允许模块导入实现了高度的模块化和代码重用。同一个包中的模块可以相互导入，新的包可以依赖于已经存在的包并使用它们的模块。本节将介绍导入模块的基础知识以及如何在自己的代码中使用它们。

```rust
// File: sources/module_two.move
module book::module_two {
    use book::module_one; // importing module_one from the same package

    /// Calls the `new` function from the `module_one` module.
    public fun create_and_ignore() {
        let _ = module_one::new();
    }
}

```

在同一个包中定义的模块可以相互导入。`use`关键字后面是模块路径，它由包地址（或别名）和模块名组成，以`：：`分隔。



#### Importing Members

从模块导入特定成员。当你只需要一个函数或一个模块中的一个类型时，这很有用。语法与导入模块的语法相同，但在模块路径后添加成员名称。

```rust
module book::more_imports {
    use book::module_one::new;       // imports the `new` function from the `module_one` module
    use book::module_one::Character; // importing the `Character` struct from the `module_one` module

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        new()
    }
}
```



#### Grouping Imports

导入可以使用大括号`{}`分组到单个`use`语句中。当您需要从同一模块导入多个成员时，这很有用。Move允许对来自同一模块和同一包的导入进行分组。

```rust
module book::grouped_imports {
    // imports the `new` function and the `Character` struct from
    /// the `module_one` module
    use book::module_one::{new, Character};

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        new()
    }
}
```

单个函数导入在Move中不太常见，因为函数名称可能会重叠并导致混淆。建议的做法是导入整个模块并使用模块路径访问函数。类型具有唯一的名称，应单独导入。

要在组导入中导入成员和模块本身，可以使用`Self`关键字。`Self`关键字引用模块本身，可用于导入模块及其成员。

```rust
module book::self_imports {
    // imports the `Character` struct, and the `module_one` module
    use book::module_one::{Self, Character};

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        module_one::new()
    }
}
```

从不同模块导入多个成员时，可能会发生名称冲突。例如，如果导入两个模块，而这两个模块都有一个同名的函数，则需要使用模块路径来访问该函数。也可以在不同的包中使用相同名称的模块。为了解决冲突并避免歧义，Move提供了`as`关键字来重命名导入的成员。

```rust
module book::conflict_resolution {
    // `as` can be placed after any import, including group imports
    use book::module_one::{Self as mod, Character as Char};

    /// Calls the `new` function from the `module_one` module.
    public fun create(): Char {
        mod::new()
    }
}
```

#### Adding an External Dependency



`Move.toml`文件中

```rust
[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
Local = { local = "../my_other_package" }

```



```rust
module book::imports {
    use std::string; // std = 0x1, string is a module in the standard library
    use sui::coin;   // sui = 0x2, coin is a module in the Sui Framework
}
```



### Standard Library

了解常用的标准库

| Module                                                       | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [std::string](https://docs.sui.io/references/framework/move-stdlib/string) | Provides basic string operations                             |
| [std::ascii](https://docs.sui.io/references/framework/move-stdlib/ascii) | Provides basic ASCII operations                              |
| [std::option](https://docs.sui.io/references/framework/move-stdlib/option) | Implements an `Option<T>`                                    |
| [std::vector](https://docs.sui.io/references/framework/move-stdlib/vector) | Native operations on the vector type                         |
| [std::bcs](https://docs.sui.io/references/framework/move-stdlib/bcs) | Contains the `bcs::to_bytes()` function                      |
| [std::address](https://docs.sui.io/references/framework/move-stdlib/address) | Contains a single `address::length` function                 |
| [std::type_name](https://docs.sui.io/references/framework/move-stdlib/type_name) | Allows runtime *type reflection*                             |
| std::hash                                                    | Hashing functions: `sha2_256` and `sha3_256`                 |
| std::debug                                                   | Contains debugging functions, which are available in only in test mode |
| std::bit_vector                                              | Provides operations on bit vectors                           |
| std::fixed_point32                                           | Provides the `FixedPoint32` type                             |



### Vector

理解为一个动态数组

使用`vector`关键字以及尖括号中的元素类型来定义`vector`类型。元素的类型可以是任何有效的Move类型，包括其他向量。Move有一个vector literal语法，允许您使用`vector`关键字后跟包含元素的方括号（或者对于空vector没有元素）来创建vector。

```rust
// An empty vector of bool elements.
let empty: vector<bool> = vector[];

// A vector of u8 elements.
let v: vector<u8> = vector[10, 20, 30];

// A vector of vector<u8> elements.
let vv: vector<vector<u8>> = vector[
    vector[10, 20],
    vector[30, 40]
];

```



#### Vector operations

- `push_back`: Adds an element to the end of the vector.
- `pop_back`: Removes the last element from the vector.
- `length`: Returns the number of elements in the vector.
- `is_empty`: Returns true if the vector is empty.
- `remove`: Removes an element at a given index.



### Option

Option是一种表示可选值的类型，该值可能存在，也可能不存在。

```rust
struct Option<Element> has copy, drop, store {
    vec: vector<Element>
}
```

`Option`是一个泛型类型，它接受一个类型参数`Element`。它有一个单一的领域`vec`这是一`个``向量`的元素。向量的长度可以为0或1，这用于表示值的存在或不存在。





### String

虽然Move没有内置的类型来表示字符串，但它[在标准库](https://move-book.com/move-basics/standard-library.html)中有两个标准的字符串实现。`std：：string`模块为UTF-8编码的字符串定义了`String`类型和方法，第二个模块`std：：asktop`提供了ASCII`String`类型及其方法。

无论你使用哪种类型的字符串，重要的是要知道字符串只是字节。



#### Creating a String

```rust
// the module is `std::string` and the type is `String`
use std::string::{Self, String};

// strings are normally created using the `utf8` function
// type declaration is not necessary, we put it here for clarity
let hello: String = string::utf8(b"Hello");

// The `.to_string()` alias on the `vector<u8>` is more convenient
let hello = b"Hello".to_string();

```





UTF8 String提供了许多处理字符串的方法。字符串上最常见的操作是：串联，切片和获取长度。此外，对于自定义字符串操作，可以使用`bytes（）`方法获取底层字节向量。





### Control Flow

和一般语法的控制流都差不多

- [`if` and `if-else`](https://move-book.com/move-basics/control-flow.html#conditional-statements) - making decisions on whether to execute a block of code
- [`loop` and `while` loops](https://move-book.com/move-basics/control-flow.html#repeating-statements-with-loops) - repeating a block of code
- [`break` and `continue` statements](https://move-book.com/move-basics/control-flow.html#exiting-a-loop-early) - exiting a loop early
- [`return`](https://move-book.com/move-basics/control-flow.html#return) statement - exiting a function early



### Constants

常量是在模块级别定义的不可变值。它们通常用作为整个模块中使用的静态值命名的一种方式。例如，如果一个产品有一个默认价格，你可以为它定义一个常量，常量存储在模块的字节码中，每次使用时，值都会被复制。

```rust
/// Price of the item used at the shop.
const ITEM_PRICE: u64 = 100;

/// Error constant.
const EItemNotFound: u64 = 1;

```

一个常见用例是定义一组在整个代码库中使用的常量。但是由于常量是模块私有的，它们不能从其他模块访问。解决这个问题的一种方法是定义一个导出常量的“config”模块。

```rust
module book::config {
    const ITEM_PRICE: u64 = 100;
    const TAX_RATE: u64 = 10;
    const SHIPPING_COST: u64 = 5;

    /// Returns the price of an item.
    public fun item_price(): u64 { ITEM_PRICE }
    /// Returns the tax rate.
    public fun tax_rate(): u64 { TAX_RATE }
    /// Returns the shipping cost.
    public fun shipping_cost(): u64 { SHIPPING_COST }
}
```



### function

函数是Move程序的构建块。它们从用户事务和其他函数调用，并将可执行代码分组为可重用单元。函数可以接受参数并返回值。它们是在模块级别用fun关键字声明的。就像任何其他模块成员一样，默认情况下它们是私有的，只能从模块内部访问。



```rust
module book::math {

    public fun add(a: u64, b: u64): u64 {
        a + b
    }

    #[test]
    fun test_add() {
        let sum = add(1, 2);
        assert!(sum == 3, 0);
    }
}
```



#### Multiple return values

```rust
fun get_name_and_age(): (vector<u8>, u8) {
    (b"John", 25)
}
//如果任何声明的值需要声明为可变的，则将mut关键字放在变量名之前：
let (mut name, age) = get_name_and_age();
// 如果某些参数未被使用，则可以使用_符号忽略它们：
let (_, age) = get_name_and_age();
```





### Struct Methods

Move语法支持*接收器语法*，它允许定义可以在结构的实例上调用的方法。这与其他编程语言中的方法语法类似。这是一种方便的方法来定义函数，这些函数对结构的字段进行操作。



如果函数的第一个参数是模块内部的结构，则可以使用`。`操作符.如果函数使用来自另一个模块的结构体，则方法默认不会与该结构体关联。在这种情况下，可以使用标准函数调用语法调用函数。

```rust
module book::hero {
    /// A struct representing a hero.
    public struct Hero has drop {
        health: u8,
        mana: u8,
    }

    /// Create a new Hero.
    public fun new(): Hero { Hero { health: 100, mana: 100 } }

    /// A method which casts a spell, consuming mana.
    public fun heal_spell(hero: &mut Hero) {
        hero.health = hero.health + 10;
        hero.mana = hero.mana - 10;
    }

    /// A method which returns the health of the hero.
    public fun health(hero: &Hero): u8 { hero.health }

    /// A method which returns the mana of the hero.
    public fun mana(hero: &Hero): u8 { hero.mana }

    #[test]
    // Test the methods of the `Hero` struct.
    fun test_methods() {
        let mut hero = new();
        hero.heal_spell();

        assert!(hero.health() == 110, 1);
        assert!(hero.mana() == 90, 2);
    }
}

```



### Visibility Modifiers



#### Internal Visibility

在模块中定义的函数或结构如果没有可见性修饰符，则该模块是*私有的*。不能从其他模块调用它。





#### Public Visibility

公共可见

通过在`fun`或`struct`关键字之前添加`public`关键字，可以使结构或函数成为*公共的*。



```rust
module book::public_visibility {
    // This function can be called from other modules
    public fun public() { /* ... */ }
}
```

一个公共函数可以从其他模块导入和调用。

```rust
module book::try_calling_public {
    use book::public_visibility;

    // Different module -> can call public()
    fun try_calling_public() {
        public_visibility::public();
    }
}
```



#### Package Visibility

Move 2024引入了*包可见性*修改器。具有*包可见性*的函数可以从同一个包中的任何模块调用。不能从其他包调用它。

```rust
module book::package_visibility {
    public(package) fun package_only() { /* ... */ }
}

//可以从同一个包中的任何模块调用包函数：
module book::try_calling_package {
    use book::package_visibility;

    // Same package `book` -> can call package_only()
    fun try_calling_package() {
        package_visibility::package_only();
    }
}
```



### Ownership and Scope

作用域和生命周期

作用域是变量有效的代码范围，所有者是此变量所属的作用域。一旦所有者作用域结束，变量将被删除。这是Move中的一个基本概念，了解它的工作原理非常重要。





### Abilities: Copy



```rust
public struct Copyable has copy {}

```



Types with the copy

- bool
- unsigned integers
- vector
- address



All of the types defined in the standard library

- Option
- String
- TypeName



### References

引用

`&mut`引用允许改变值，并且函数可以花费这些费用。

```rust
    /// Use the metro pass card at the turnstile to enter the metro.
    public fun enter_metro(card: &mut Card) {
        assert!(card.uses > 0, ENoUses);
        card.uses = card.uses - 1;
    }
```









### Generics

泛型可用于在不同的输入数据类型上定义函数和结构。这种语言特性有时被称为*参数多态性*。在Move中，我们经常将术语泛型与类型参数和类型实参互换使用。

泛型通常用在库代码中，比如vector中，用来声明在任何可能的实例化（满足指定的约束）上工作的代码。在其他框架中，泛型代码有时可以用于以许多不同的方式与全局存储进行交互，这些方式仍然共享相同的实现。



#### Generic Structs

```rust
module 0x42::example {
  struct Foo<T> has copy, drop { x: T }
 
  struct Bar<T1, T2> has copy, drop {
    x: T1,
    y: vector<T2>,
  }
}
```









### Type Reflection



类型反射在标准库模块std：：type_name中实现。简单地说，它给出了一个函数get<T>（），该函数返回类型T的名称。

```rust
module book::type_reflection {
    use std::ascii::String;
    use std::type_name::{Self, TypeName};

    /// A function that returns the name of the type `T` and its module and address.
    public fun do_i_know_you<T>(): (String, String, String) {
        let type_name: TypeName = type_name::get<T>();

        // there's a way to borrow
        let str: &String = type_name.borrow_string();

        let module_name: String = type_name.get_module();
        let address_str: String = type_name.get_address();

        // and a way to consume the value
        let str = type_name.into_string();

        (str, module_name, address_str)
    }

    #[test_only]
    public struct MyType {}

    #[test]
    fun test_type_reflection() {
        let (type_name, module_name, _address_str) = do_i_know_you<MyType>();

        //
        assert!(module_name == b"type_reflection".to_ascii_string(), 1);
    }
}
```





## Aptos Stdlib



### Account

账户模块

```rust
module MyModule {
    use aptos_framework::account;

    public fun create_account(addr: address) {
        account::create_account(addr);
    }
}
```







## Object  model

对象模型

它通过将资源（resources）和模块（modules）作为不可变和安全的对象，使得智能合约编写和执行更加安全和高效



### resources

- 资源的唯一性：每个资源都是唯一的，且只能存在一个实例。资源的类型必须用 has key 标注，保证资源的存储与管理符合区块链上的严格约束。
- 资源的不可复制性：资源对象无法复制，这意味着如果资源被转移，它不再存在于原来的位置。这保证了资产不会被意外地复制或复制攻击。
- 资源的所有权：资源总是由某个账户拥有，只有该账户可以访问和操控它。通过 Move 的 signer 类型，可以限制某些操作只能由特定账户来执行。

```move
module stdlibDemo::ResourceExample {
    // 定义一个资源类型
    struct MyResource has key {
        value: u64,
    }

    // 创建资源并将其存储在调用者账户下
    public fun create_resource(account: &signer, value: u64) {
        move_to(account, MyResource { value });
    }

    // 获取资源的值
    public fun get_resource_value(account: address): u64 {
        let resource = borrow_global<MyResource>(account);
        resource.value
    }

    // 销毁资源
    public fun destroy_resource(account: &signer) {
        let resource = move_from<MyResource>(signer::address_of(account));
        // 销毁资源
        destroy resource;
    }
}
```





