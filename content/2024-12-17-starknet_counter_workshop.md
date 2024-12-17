+++
title = "Starknet开发实战之counter-workshop学习笔记"
date= 2024-12-17T11:14:00+08:00
[taxonomies]
tags = ["Starknet","Cairo"]
categories = ["Starknet","Cairo"]
+++
# Starknet开发实战之counter-workshop学习笔记

## 实操

```bash
10998  git clone git@github.com:starknet-edu/counter-workshop.git
10999  cd counter-workshop/
11000  scarb --version
11002  asdf current
11003  asdf install scarb 2.8.5
11005  asdf install starknet-foundry latest
11007  asdf install starknet-foundry 0.33.0
11009  git checkout -b step1 origin/step1
11010  c
11011* scarb init --name workshop
11012  snforge --version
11013  asdf list
11014  asdf install scarb latest
11017  asdf local starknet-foundry 0.35.0
11018  asdf local scarb 2.9.2
11019  asdf current
11020* scarb init --name workshop
11021* scarb build


counter-workshop on  step1 via 🅒 base 
➜ scarb init --name workshop
✔ Which test runner do you want to set up? · Starknet Foundry (default)
warn: file `/Users/qiaopengjun/Code/starknet-code/cairo/counter-workshop/.gitignore` already exists in this directory, ensure following patterns are ignored:

    target

✔ Which test runner do you want to set up? · Starknet Foundry (default)
    Updating git repository https://github.com/foundry-rs/starknet-foundry
Created `workshop` package.
warn: no changes have to be made
warn: no changes have to be made
Created package.

counter-workshop on  step1 via 🅒 base took 30.3s 
➜ scarb init --name workshop
✔ Which test runner do you want to set up? · Starknet Foundry (default)
error: `scarb init` cannot be run on existing Scarb packages

counter-workshop on  step1 [!] via 🅒 base took 14.3s 
➜ scarb build               

   Compiling workshop v0.1.0 (/Users/qiaopengjun/Code/starknet-code/cairo/counter-workshop/Scarb.toml)
    Finished `dev` profile target(s) in 4 seconds



11037  git clone git@github.com:qiaopengjun5162/counter-workshop.git
11038  cd counter-workshop/
11039  git checkout -b step1 origin/step1
11040  c
11041  scarb init --name workshop
11042  asdf current
11043  asdf local scarb 2.9.2
11044  asdf local starknet-foundry 0.35.0
11045  scarb init --name workshop
11046  scarb build\n
11047  git status 
11048  git add .
11049* touch content/2024-12-17-qps_tps.md
11050  git commit -m "step 1"
11051  gp
11052  ls -a
11053  git status 
11054  ga
11055  git commit -m "finished step 1"
11056  gp
11057  git checkout -b step2 origin/step2\n
11058  asdf local starknet-foundry 0.35.0
11059  asdf local scarb 2.9.2
11060  scarb build\n
11061  scarb init --name workshop
11062  scarb test
11063  mcd src
11064  touch lib.rs
11065  touch counter.cairo
11066  cd ..
11067  scarb test
11068  scarb build\n
11069  scarb test
11070  git status 
11071  ga
11072  git commit -m "finished step 2"
11073  gp
11074  git checkout -b step3 origin/step3\n
11075  asdf local scarb 2.9.2
11076  asdf local starknet-foundry 0.35.0
11077  scarb init --name workshop
11078  mcd src
11079  touch counter.cairo
11080  touch lib.cairo
11081  scarb test
11082  cd ..
11083  scarb test
11084  git status 
11085  ga
11086  git commit -m "finished step 3"
11087  gp
11088  git checkout -b step4 origin/step4\n
11089  asdf local starknet-foundry 0.35.0
11090  asdf local scarb 2.9.2
11091  scarb init --name workshop
11092  mcd src
11093  touch lib.cairo
11094  touch counter.cairo
11095  cd ..
11096  scarb test
11097  git status 
11098  ga
11099  git commit -m "finished step 4"
11100  gp
11101  git checkout -b step5 origin/step5\n
11102  asdf local scarb 2.9.2
11103  asdf local starknet-foundry 0.35.0
11104  scarb init --name workshop
11105  touch src/counter.cairo
11106  scarb test
11107  git status 
11108  scarb test
11109  ga
11110  git commit -m "finished step 5"
11111  gp
11112  git checkout -b step6 origin/step6\n
11113  asdf local starknet-foundry 0.35.0
11114  asdf local scarb 2.9.2
11115  scarb init --name workshop
11116  touch src/counter.cairo
11117  scarb test
11118  git status 
11119  ga
11120  git commit -m "finished step 6"
11121  gp
11122  git checkout -b step7 origin/step7\n
11123  asdf local scarb 2.9.2
11124  asdf local starknet-foundry 0.35.0
11125  scarb init --name workshop
11126  touch src/counter.cairo
11127  scarb build\n
11128  scarb test\n
11129  git status 
11130  ga
11131  git commit -m "finished step 7"
11132  gp
11133  git checkout -b step8 origin/step8\n
11134  asdf local starknet-foundry 0.35.0
11135  asdf local scarb 2.9.2
11136  scarb init --name workshop
11137  touch src/counter.cairo
11138  scarb test\n
11139  git status 
11140  ga
11141  git commit -m "finished step 8"
11142  gp
11143  git checkout -b step9 origin/step9\n
11144  asdf local scarb 2.9.2
11145  asdf local starknet-foundry 0.35.0
11146  scarb init --name workshop
11147  touch src/counter.cairo
11148  scarb test\n
11149  scarb build\n
11150  rm -rf target
11151  scarb build\n
11152  scarb test\n
11153  git status 
11154  git commit -m "finished step 9"
11155  git status 
11156  ga
11157  git commit -m "finished step 9"
11158  gp
11159  git checkout -b step10 origin/step10\n
11160  asdf local starknet-foundry 0.35.0
11161  asdf local scarb 2.9.2
11162  scarb init --name workshop
11163  touch src/counter.cairo
11164  scarb test\n
11165  git status 
11166  ga
11167  git commit -m "finished step 10"
11168  gp
11169  git checkout -b step11 origin/step11\n
11170  asdf local scarb 2.9.2
11171  asdf local starknet-foundry 0.35.0
11172  scarb init --name workshop
11173  touch src/counter.cairo
11174  scarb test\n
11175  rm -rf target
11176  scarb test\n
11177  scarb build
11178  scarb test\n
11179  git status 
11180  ga
11181  git commit -m "finished step 11"
11182  gp
11183  git checkout -b step12 origin/step12\n
11184  asdf local starknet-foundry 0.35.0
11185  asdf local scarb 2.9.2
11186  scarb init --name workshop
11187  touch src/counter.cairo
11188  scarb test\n
11189  scarb build
11190  scarb test\n
11191  scarb build
11192  scarb test\n
11193  scarb build
11194  scarb add openzeppelin_utils@0.19.0
11195  scarb build
11196  scarb add openzeppelin_utils@0.15.4
11197  scarb build
11198  scarb test\n
11199  scarb build
11200* git status 
11201* ga
11202* git commit -m "chore: add new rust posts"
11203* git status 
11204* ga
11205* git commit -m "chore: add new rust posts"
11206* gp
11207  scarb build
11208  rm -rf target
11209  scarb build
11210  scarb test\n
11211  scarb build
11212  scarb test\n
11213  scarb --version snforge --version
11214  snforge --version\n
11215  asdf local scarb 2.8.5
11216  asdf local starknet-foundry 0.33.0
11217  rm -rf target
11218  scarb build
11219  scarb test\n
11220  git status 
11221  ga
11222  git commit -m "finished step 12"
11223  gp
11224  git checkout -b step13 origin/step13
11225  scarb init --name workshop
11226  touch src/counter.cairo
11227  scarb build
11228  scarb test\n
11229  git status 
11230  ga
11231  git commit -m "finished step 13"
11232  gp
11233  git checkout -b step14 origin/step14\n
11234  scarb init --name workshop
11235  touch src/counter.cairo
11236  scarb build
11237  scarb test\n
11238  git status 
11239  ga
11240  git commit -m "finished step 14"
11241  gp
11242  git checkout -b step15-js origin/step15-js
11243  scarb init --name workshop
11244  touch src/counter.cairo
11245  scarb build
11246  rm -rf node_modules package-lock.json
11247  pnpm install
11248* pnpm self-update
11249  touch .env
11250  pnpm run deploy
11251* c
```

## 代码

```rust
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState);
}

#[starknet::interface]
trait IKillSwitch<TContractState> {
    fn is_active(self: @TContractState) -> bool;
}

#[starknet::contract]
pub mod counter_contract {
    use super::ICounter;
    use starknet::ContractAddress;
    use super::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};
    use openzeppelin_access::ownable::{OwnableComponent};
    // use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: ContractAddress,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u32, 
        kill_switch_address: ContractAddress, initial_owner: ContractAddress) {
        self.counter.write(initial_value);
        self.kill_switch.write(kill_switch_address);
        self.ownable.initializer(initial_owner);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        #[flat]
        OwnableEvent: OwnableComponent::Event,

    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        pub value: u32,
    }

    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState)  {
            self.ownable.assert_only_owner();
            let result = IKillSwitchDispatcher { contract_address: self.kill_switch.read() };

            assert!(!result.is_active(), "Kill Switch is active");

            let new_counter = self.counter.read() + 1;
            self.counter.write(new_counter);
            self.emit(CounterIncreased { value: new_counter });
        }
    }
}

```

![starknet counter workshop](/images/starknet_counter_workshop.png)
合约地址： 0x037eb187a87b7dcc23067daab8626c73ce29eb1d06eda6a845edb0ed15f8991f
![starknet contract](/images/starknet_contract.png)

## 参考

- <https://github.com/starknet-edu/counter-workshop>
- <https://sepolia.voyager.online/contract/0x037eb187a87b7dcc23067daab8626c73ce29eb1d06eda6a845edb0ed15f8991f#writeContract>
