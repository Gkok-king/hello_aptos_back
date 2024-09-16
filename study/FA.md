# Aptos Fungible Asset (FA) Standard

## 概念

相当于以太坊的ERC20

Aptos 可替代资产标准（也称为“可替代资产”或“FA”）提供了一种标准的、类型安全的方式来定义 Move 生态系统中的可替代资产。它是`coin`模块的现代替代品，允许针对任何用例无缝铸造、转移和定制可替代资产



它通过使用两个move对象来实现这一点：

- `Object<Metadata>` - 这表示有关可替代资产本身的详细信息，包括`name` 、 `symbol`和`decimals`等信息。
- `Object<FungibleStore>` - 存储此帐户拥有的可替代资产单位的计数。可替代资产可以与具有相同元数据的任何其他可替代资产互换。一个帐户*可以*为一项同质资产拥有多个`FungibleStore` ，但这仅适用于高级用例。



Metadata管创造

FungibleStore 管持有



## 如何创造

1. 建一个不可删除的对象来拥有新创建的同质资产`Metadata` 。
2. 生成`Ref`以启用任何所需的权限。
3. 铸造并转移



示例代码

```move
public fun create_primary_store_enabled_fungible_asset(
    constructor_ref: &ConstructorRef,
    // This ensures total supply does not surpass this limit - however, 
    // Setting this will prevent any parallel execution of mint and burn.
    maximum_supply: Option<u128>,
    // The fields below here are purely metadata and have no impact on-chain.
    name: String,
    symbol: String,
    decimals: u8,
    icon_uri: String,
    project_uri: String,
)
```







