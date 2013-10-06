Kenmou_API
==========

2ch(ニュー速嫌儲)のAPI( ˇ౪ˇ )

## How to use

勢い情報は1分に1回アクセスぐらいにとどめておくこと

```
ikioi = Ikioi.new

ikioi.datfile
=> "1234244324.dat"

ikioi.details
=>{"rank"=>"1",
   "url"=>"engawa.2ch.net/poverty/1381073407/",
   "title"=>"【速報】アニメDVD・BDの売り上げを見守るスレ13917 ",
   "res"=>"1001",
   "ikioi"=>"20223"}

thread = Thread.new("1234244324.dat")

thread.res
=> {"number"=>1,
   "name"=>"番組の途中ですがアフィサイトへの転載は禁止です",
   "date"=>"2013/10/07(月) 00:30:07.81 ID:P0Y/yhN+0 BE:1063741853-2BP(1260)",
   "text"=>"本文"}

thread.find_id("ID")

thread.to_res(res_number)
```