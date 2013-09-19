Kenmou_API
==========

2ch(ニュー速嫌儲)のAPI( ˇ౪ˇ )

## How to use

勢いは1分に1回アクセスぐらいが良い

```
ikioi = Ikioi_API.new

ikioi.datfiles(10).each do |dat|
  thread = Thread.new(dat)
  print thread.title
  print thread.find_id("ID")                                                                    
end
```