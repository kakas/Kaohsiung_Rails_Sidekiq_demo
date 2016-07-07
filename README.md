# 注意事項

這個 Demo 使用

`ruby 2.2.0`

`rails 4.2.3`

`$` 表示要在命令列輸入指令

# 事前準備

1. 安裝 redis 資料庫，`$ brew install redis`
2. 啟動 redis 資料庫，`$ brew services start redis`
3. 若需要其他資訊可以輸入，`$ brew info redis`

# 使用 sidekiq 及增加第一個 work

官方網站：
[mperham/sidekiq: Simple, efficient background processing for Ruby](https://github.com/mperham/sidekiq)

1. `gem 'sidekiq'`
2. `$ bundle install`
3. 增加 workers 資料夾及測試用 worker，`app/workers/my_test_worker.rb`
4. 記得 worker.rb 要存檔

```ruby
class MyTestWorker

  include Sidekiq::Worker

  def perform
    puts "do something"
  end

end
```

# 測試 sidekiq worker

1. 在 iterm 開一個新的 tab 輸入 `$ sidekiq`，啟動 sidekiq 伺服器
2. 再開一個 tab，輸入 `$ rails console`
3. 增加工作給 sidekiq，`> MyTestWorker.perform_async`
4. 如下所示，sidekiq server 有印出 `do something` 表示成功

#### rails console
```
Loading development environment (Rails 4.2.3)
2.2.0 :001 > MyTestWorker.perform_async
 => "c5627145a59889bca376c69c"
```

#### sidekiq server
```
2016-07-07T03:08:50.466Z 22213 TID-ov8zu6vu0 MyTestWorker JID-c5627145a59889bca376c69c INFO: start
do something
2016-07-07T03:08:50.467Z 22213 TID-ov8zu6vu0 MyTestWorker JID-c5627145a59889bca376c69c INFO: done: 0.0 sec
```

# 加上 Web UI

官網教學連結：[Monitoring · mperham/sidekiq Wiki](https://github.com/mperham/sidekiq/wiki/Monitoring)，可以對照著看

1. `gem 'sinatra', :require => false`，（PS：rails 5.0.0 要改成 `gem 'sinatra', github: 'sinatra'`）
2. `$ bundle install`
3. 修改 `routes.rb`

```ruby
require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' # 可以隨意指定，譬如 '/QQ/sidekiq' 也可以
end
```

4. 關閉 sidekiq server。（PS：到 sidekiq server 的 tab 按 `ctrl + c` 即可把 sidekiq server 關閉）
5. 開新 tab 啟動 rails server，`$ rails s`
6. 網址輸入你剛剛設定的位址，譬如：`http://localhost:3000/sidekiq`
7. 進去後如果有看到很炫炮的 sidekiq 後台表示成功。[示意圖](https://raw.githubusercontent.com/mperham/sidekiq/master/examples/web-ui.png)
8. 測試：進 `rails console` 增加幾個 worker、檢查 Web UI Enqueued 數量是否增加、啟動 sidekiq server，自行發揮。
