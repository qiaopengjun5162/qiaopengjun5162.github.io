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
```

## 参考

- <https://github.com/starknet-edu/counter-workshop>
