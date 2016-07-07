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

# 定期執行工作 cron job

cron job 教學：[cron jobs 的使用](http://kalug.linux.org.tw/~lloyd/LLoyd_Hand_Book/book/cron-jobs.html)

# 使用 sidekiq-cron 定期執行 worker

官網連結：[ondrejbartas/sidekiq-cron: Scheduler / Cron for Sidekiq jobs](https://github.com/ondrejbartas/sidekiq-cron)

1. `gem 'sidekiq-cron'`
2. `$ bundle install`

### 使用 yml 管理定期執行的工作

1. 增加 `config/initializers/sidekiq.rb`

```ruby
schedule_file = "config/schedule.yml"

if File.exists?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
```

2. 增加並設定 `config/schedule.yml`

```yml
sidekiq_demo_job:
  cron: "*/1 * * * *"
  class: "MyTestWorker" # 需對應到你的 worker
  queue: default        # 優先權設定，詳細請看官網說明
```

### 加上 sidekiq-cron 的 Web UI

1. 在 `routes.rb` 的 `require 'sidekiq/web'` 下面加上 `require 'sidekiq/cron/web'`
2. 重開 sidekiq 及 rails server，檢查 sidekiq Web UI，應該會在上方增加一個 `Cron` 的按鈕
3. 因為在你的電腦每個專案的 sidekiq 都會使用同一個 redis，所以如果你之前有用過 sidekiq-cron，可能會在 Web UI 的 Cron 裡面發現之前的 worker，請先把它們刪除再測試，不然在 sidekiq server 會出現找不到 worker 的錯誤。
4. 在 Cron 的 UI 裡面有一個 `EnqueueNow` 的按鈕可以手動執行 Worker ，可以很方便的測試 Cron job
5. 自己測看看吧。
