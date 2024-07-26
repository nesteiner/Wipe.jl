# Wipe.jl

## 介绍

这个 `Wipe.jl` 是参考 [cargo wipe](https://github.com/mihai-dinculescu/cargo-wipe) 这个库做的一个 **JUlia** 实现，已完成所有功能

## Usage

这是个库，不是可执行程序，也不是命令行程序，如果你需要像 `cargo wipe rust -w` 那样使用的话，请这样使用

```bash
julia /path/to/Wipe.jl/src/main.jl rust -w
```

看起来很麻烦，对吧，所以我推荐使用其中的 `runwipe` 函数调用

## 代码实现解析

具体的代码实现可以看 [这篇文章](https://discourse.juliacn.com/t/topic/7825)