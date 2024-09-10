
module todolist_addr::todolist {
    // Errors
    const E_NOT_INITIALIZED: u64 = 1;
    const ETASK_DOESNT_EXIST: u64 = 2;
    const ETASK_IS_COMPLETED: u64 = 3;

    use aptos_framework::event;
    use std::string::String;
    use std::signer;
    use aptos_std::table::{Self, Table}; // This one we already have, need to modify it
    use aptos_framework::account;
    use std::vector;


    struct TodoList has key {
        tasks: Table<u64, Task>,
        set_task_event: event::EventHandle<Task>,
        task_counter: u64
    }

    struct Task has store, drop, copy {
        task_id: u64,
        address:address,
        content: String,
        completed: bool,
    }

    public entry fun create_vector(){
        // 创建一个二维向量
        let mut vv: vector<vector<u8>> = Vector::empty(); // 创建空向量
        let v1: vector<u8> = Vector::empty(); // 第一个子向量
        let v2: vector<u8> = Vector::empty(); // 第二个子向量

        // 向子向量中添加元素
        Vector::push_back(&mut v1, 10);
        Vector::push_back(&mut v1, 20);

        Vector::push_back(&mut v2, 30);
        Vector::push_back(&mut v2, 40);

        // 将子向量加入二维向量
        Vector::push_back(&mut vv, v1);
        Vector::push_back(&mut vv, v2);

        // 断言长度是否为2（vv 中包含 2 个子向量）
        assert(Vector::length(&vv) == 2, 0);
    }



}